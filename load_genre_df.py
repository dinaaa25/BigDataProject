from pyspark.sql import SparkSession 

spark = SparkSession.builder.getOrCreate()

def load_genre_df(path: str):
    return spark.sparkContext.textFile(path).zipWithIndex().filter(lambda row: row[1] >= 7).map(lambda row: row[0]).map(lambda x: x.split("\t")).map(lambda x: (x[0], x[1])) 

rdd1 = load_genre_df("/user/s2345846/project/msd_tagtraum_cd2.cls")
df = rdd1.toDF(["id", "genre"])
df.show()
