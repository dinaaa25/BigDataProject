# -----------------IMPORTS--------------------------------------------
from pyspark.sql import SparkSession
from pyspark.sql.functions import row_number, lit, max, collect_list, cast
import pyspark.sql.functions as func
import pyspark.sql.types as type
from pyspark.sql.window import Window

import numpy as np

from pyspark.ml import Pipeline
from pyspark.ml.feature import VectorAssembler, StringIndexer, IndexToString
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.tuning import ParamGridBuilder, CrossValidator
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

#------------------SESSION_CREATION-------------------------------------
# spark = SparkSession.builder.remote(
#     "sc://spark-head5.eemcs.utwente.nl:4040"
# ).getOrCreate()

spark = SparkSession.builder.appName("MSD-random_forrest").getOrCreate()
sc = spark.sparkContext

#set log level to remove redundant logging messages
sc.setLogLevel("ERROR")


#------------------DATA_PREPROCESSING----------------------------------------
# read the data from the HDFS
df_init = spark.read.parquet("/user/s2549182/MBD/id_genres")

# limit the number of entries - debugging only
#df_init = df_init.limit(1000)

# set features to be used for predictions
pred_features = ["danceability", "duration", "energy", "key", "loudness", "tempo", "year", "artist_playmeid"]

# set class labels column
label_col = "genre"

def df_processing(df):
    """
        Prepare the dataFrame for further processing
        by converting the feature columns to numeric input
        It contains all the features for prediction and corresponding class,
        where the rows are indexed by track_id
    """
    # add any columns to keep which are not prediction_features
    add_cols = ["track_id", "genre"]
    df_extra = df.select(add_cols)

    # select only feature columns, then replace NaN values with 0
    df_features = df.select(pred_features).fillna(0)

    # cast all feature columns to numeric values
    df_features = df_features.select(*(df_features[f].cast("float").alias(f) for f in pred_features))

    # join the features, track_id and genre
    # this is done by creating a joining index and appending it to each dataFrame
    w = Window().orderBy(lit("X"))
    df_extra = df_extra.withColumn('rand_id', row_number().over(w))
    df_features = df_features.withColumn('rand_id', row_number().over(w))
    # join the dataFrames and drop the index
    df_input = df_extra.join(df_features, on=['rand_id']).drop('rand_id')

    # uncomment to preview the returned DataFrame
    #df_input.show(10)

    return df_input


# convert non-numerical values to label indices
# currently, only the class column requires indexing
class_indexer = StringIndexer(inputCol = label_col, outputCol = "label")

# create the dataFrame to be passed for further processing
# it contains the features for prediction, indexed by track_id
df_input = df_processing(df_init)

#------------------MODEL_PREPARATION----------------------------------------
# seed definition
cust_seed = 42

# create the features column as required by the RandomForrestClassifier
# includes all the features to be considered for predictions
assembler = VectorAssembler(inputCols = pred_features, outputCol = "features")

# define the classifier
rf_classifier = RandomForestClassifier(featuresCol = "features", labelCol = "label",
                                       seed = cust_seed)

# split the dataFrame for training
df_train, df_test = df_input.randomSplit([.75, .25], cust_seed)

#------------------PIPELINES---------------------------------------------------
tune_pipeline = Pipeline(stages = [class_indexer, assembler, rf_classifier])

#------------------MODEL_TUNING-------------------------------------------------
# Build hyperparameter tuning grid for numTrees and maxDepth
tune_grid = ParamGridBuilder() \
    .addGrid(rf_classifier.numTrees, [int(x) for x in np.linspace(start = 3, stop = 45, num = 3)]) \
    .addGrid(rf_classifier.maxDepth, [int(x) for x in np.linspace(start = 2, stop = 25, num = 3)]) \
    .build()

# cross validator for selecting the best parameters (i.e. model)
cross_val = CrossValidator(estimator=tune_pipeline,
                          estimatorParamMaps=tune_grid,
                          evaluator=MulticlassClassificationEvaluator(),
                          numFolds=3, seed = cust_seed)

#-------------------TRAINING_and_TESTING--------------------------------------
# fit the (best) model OR
rf_model = cross_val.fit(df_train)
# fit a default RandomForrest model, using the tuning_pipeline
#rf_model = tune_pipeline.fit(df_train)

# save predictions
rf_predictions = rf_model.transform(df_test)

# with all probabilities in array format
to_array_udf = func.udf(lambda vector: vector.toArray().tolist(), type.ArrayType(type.FloatType()))

rf_predictions = rf_predictions.withColumn("probabilities_array", to_array_udf("probability"))

# uncomment to preview results
#rf_predictions.select(["track_id", "label", "probability", "prediction"]).show(10)

#-------------------EVALUATION----------------------------------------------
# assess the prediction accuracy
rf_eval = MulticlassClassificationEvaluator(labelCol="label", predictionCol="prediction", metricName="accuracy")
accuracy = rf_eval.evaluate(rf_predictions)
print("Test set accuracy = {:.2f}".format(accuracy))

# saving the best model parameters
best_rf = rf_model.bestModel.stages[2]

# metadata = "Random forrest parameters:\n Trees: "
# metadata = metadata + str(best_rf.getNumTrees) + "\n Maximum depth: "
# metadat = metadata + str(best_rf.getOrDefault('maxDepth')) + "\n Feature importances: "
#
# # saving feature importances
# metadata += str(best_rf.featureImportances)
#
# # save the metadata to a text file on the HDFS
# sc.parallelize(metadata).saveAsTextFile(path="/user/s2549182/MBD/metadata_A.txt")

#-------------------STORE_PREDICTIONS-----------------------------------------
# save predictions to DataFrame, with each genre as a column
# first, we extract the genres and labels
genre_labels = rf_predictions.select(["genre", "label"]).distinct().orderBy("label")
all_genres = genre_labels.collect()

# save the genres and labels as arrays
genres = [row.genre for row in all_genres]
labels = [l for l in range(len(genres))]

# save a tree-like structure of the RandomForrest
path_string = best_rf.toDebugString
for i, feat in enumerate(pred_features):
    path_string = path_string.replace('feature ' + str(i), feat)
#print(path_string)

# define a udf to create add a column with the predicted genre
genre_udf = func.udf(lambda p: genres[int(p)])

# create 1 column with the probabilities for each genre
# add the track id and the given and predicted genre for each track
df_probs = rf_predictions.select("track_id", "genre", "label",
                                 genre_udf(rf_predictions.label).alias("predicted_genre"),
                                 *(rf_predictions.probabilities_array[l].alias(genres[l]) for l in labels))

# add a flag for predictions matching initial genre labelling
df_probs = df_probs.withColumn("matched_labels", (df_probs.genre == df_probs.predicted_genre))

df_yearly = rf_predictions.select("year", genre_udf(rf_predictions.label).alias("pred_genre")).\
                                 groupBy("year").agg(collect_list("pred_genre").alias("all_genres").cast("string")).sort("year")

df_yearly.write.csv(path="/user/s2549182/MBD/year_distributions", mode="overwrite")

# uncomment to preview dataFrame that will be saved to parquet files
# this will be accessed by the server to extract genre probabilities
#df_probs.show(5)

# export all probabilities for predicitons in parquet files for later access
df_probs.write.parquet(path="/user/s2549182/MBD/genre_predictions", mode="overwrite")
