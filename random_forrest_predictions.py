# -----------------IMPORTS--------------------------------------------
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import pyspark.sql.functions as func
import pyspark.sql.types as type

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

spark = SparkSession.builder.appName("MSD-random_forrest_visualise").getOrCreate()
sc = spark.sparkContext

#set log level to remove redundant logging messages
sc.setLogLevel("ERROR")


#------------------DATA_PREPROCESSING----------------------------------------
# set the dataset part to work with (options: *, letters from "A"-"E", combinations)
part = "A"

# read the data from the HDFS
df_input = spark.read.parquet("/user/s2549182/MBD/id_genres_" + part)

# limit the number of entries - debugging only
#df_input = df_input.limit(25000)

# set features to be used for predictions
pred_features = ["danceability", "duration", "energy", "key", "loudness", "tempo", "year", "artist_playmeid"]

# set class labels column
label_col = "genre"

# convert non-numerical values to label indices
# currently, only the class column requires indexing
class_indexer = StringIndexer(inputCol = label_col, outputCol = "label")

# create the dataFrame to be passed for further processing
# it contains the features for prediction, indexed by track_id
#df_input = df_processing(df_init)

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
#df_train, df_test = df_input.randomSplit([.75, .25], cust_seed)
df_train = df_input

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

#-------------------TRAINING_and_SAVING--------------------------------------
# fit the (best) model OR
rf_model = cross_val.fit(df_train)
# fit a default RandomForrest model, using the tuning_pipeline
#rf_model = tune_pipeline.fit(df_train)

# saving the best model (parameters)
best_rf = rf_model.bestModel.stages[2]

metadata = "Random forrest parameters:\n Trees: "
metadata = metadata + str(best_rf.getNumTrees) + "\n Maximum depth: "
metadata = metadata + str(best_rf.getOrDefault('maxDepth')) + "\n Feature importances: "

# saving feature importances
metadata += str(best_rf.featureImportances)

# save a tree-like structure of the RandomForrest
path_string = best_rf.toDebugString
for i, feature in enumerate(pred_features):
    path_string = path_string.replace('feature ' + str(i), feature)
metadata += path_string

# save the metadata to a text file on the HDFS
sc.parallelize(metadata).coalesce(1).saveAsTextFile(path="/user/s2549182/MBD/metadata_"+ part)

#-------------------MAKING_PREDICTIONS-------------------------------------
# set the dataset part to work with (options: *, letters from "A"-"E", combinations)
for part in ["B", "C", "D", "E"]:

    # read the data from the HDFS
    df_predict = spark.read.parquet("/user/s2549182/MBD/id_genres_" + part)

    # save predictions
    rf_predictions = rf_model.transform(df_predict)

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
    #best_rf = rf_model.bestModel.stages[2]

    #-------------------STORE_METADATA-----------------------------------------
    # save predictions to DataFrame, with each genre as a column
    # first, we extract the genres and labels
    genre_labels = rf_predictions.select(["genre", "label"]).distinct().orderBy("label")
    all_genres = genre_labels.collect()

    # save the genres and labels as arrays
    genres = [row.genre for row in all_genres]
    labels = [l for l in range(len(genres))]

    #-------------------STORE_YEAR_ANALYSIS-----------------------------------------
    # define a udf to create add a column with the predicted genre
    genre_udf = func.udf(lambda p: genres[int(p)])

    # store the count for each genre per year
    # it can be arranged in a few formations, depending on the (un)commented lines below
    # storage is done in a csv file for convenience of further processing
    df_yearly = rf_predictions.select("year", genre_udf(rf_predictions.label).alias("pred_genre")).filter((col("year") != 0.0)).\
                                     groupBy("year", "pred_genre").agg(count("*").alias("number_tracks")).sort("year")
                                     #groupBy("year").agg(collect_list("pred_genre").alias("genres"), collect_list("number_tracks").alias("tracks")).sort("year")

    df_yearly_arranged = df_yearly.groupBy("year").pivot("pred_genre").sum("number_tracks").fillna(0).sort("year")

    # export the dataFrame to the HDFS
    df_yearly_arranged.write.csv(path="/user/s2549182/MBD/year_distributions_" + part, mode="overwrite")

    #-------------------STORE_PREDICTIONS-----------------------------------------
    # create 1 column with the probabilities for each genre
    # add the track id and the given and predicted genre for each track
    df_probs = rf_predictions.select("track_id", "genre", "label",
                                     genre_udf(rf_predictions.label).alias("predicted_genre"),
                                     *(rf_predictions.probabilities_array[l].alias(genres[l]) for l in labels))

    # add a flag for predictions matching initial genre labelling
    df_probs = df_probs.withColumn("matched_labels", (df_probs.genre == df_probs.predicted_genre))

    # uncomment to preview dataFrame that will be saved to parquet files
    # this will be accessed by the server to extract genre probabilities
    #df_probs.show(5)

    # export all probabilities for predicitons in parquet files for later access
    df_probs.write.parquet(path="/user/s2549182/MBD/genre_predictions_" + part, mode="overwrite")
