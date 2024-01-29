# -----------------IMPORTS--------------------------------------------
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import pyspark.sql.functions as func

#------------------SESSION_CREATION-------------------------------------
# spark = SparkSession.builder.remote(
#     "sc://spark-head5.eemcs.utwente.nl:4040"
# ).getOrCreate()

spark = SparkSession.builder.appName("MSD-data_analysis").getOrCreate()
sc = spark.sparkContext

#set log level to remove redundant logging messages
sc.setLogLevel("ERROR")

#------------------PREDICTION_DATA----------------------------------------
# read the data from the HDFS
df_predict = spark.read.parquet("/user/s2549182/MBD/genre_predictions_[A-E]")

# export the dataFrame to the HDFS
df_predict.write.parquet(path="/user/s2549182/MBD/genre_predictions", mode="overwrite")

#------------------YEAR_DATA----------------------------------------
# read the data from the HDFS
df_yearly = spark.read.csv("/user/s2549182/MBD/year_distributions_[A-E]")

# export the dataFrame to the HDFS
df_yearly.write.csv(path="/user/s2549182/MBD/year_distributions", mode="overwrite")