from pyspark.sql import SparkSession

# spark: spark = (
# SparkSession.builder.appName("SongProject")
# .master("http://spark-head5.eemcs.utwente.nl:4040")
# .getOrCreate()
# )

spark = SparkSession.builder.remote(
    "sc://spark-head5.eemcs.utwente.nl:4040"
).getOrCreate()

"""
paths to data on hdfs
"""
genre_path = "/user/s2345846/project/msd_tagtraum_cd2.cls"
song_path = "/data/doina/OSCD-MillionSongDataset/output_*.csv"


class DataFrameLoader:
    """
    Loads the starting dataframe from the given hdfs datasets
    """

    def load_genre_df(self, path: str):
        """
        returns the df with all attributes from the genre dataset
        """
        return (
            spark.sparkContext.textFile(path)
            .zipWithIndex()
            .filter(lambda row: row[1] >= 7)
            .map(lambda row: row[0])
            .map(lambda x: x.split("\t"))
            .map(lambda x: (x[0], x[1]))
            .toDF(["id", "genre"])
        )

    def load_genre_types_df(self):
        """
        returns a list with the unique genretypes
        """
        genreData = self.load_genre_df(genre_path)
        distinctDF = genreData.select("genre").distinct()
        return distinctDF.rdd.map(lambda x: x.genre).collect()

    def load_song_df(self, path: str):
        """
        returns the df with all attributes from the song dataset
        """
        return spark.read.options(header=True, quote='"', escape='"').csv(path)

    def join_dataframes(self, useAllTracks=True):
        """
        joins the genre df and the song df based on the track_id
        one song has many tracks
        useAllTracks = True keeps the songs with no matching genre lable in the joined table
        useAllTracks = False keeps only the songs with a matching genre lable via track_id in the joined table
        """
        joinType = "left"
        if not useAllTracks:
            joinType = "inner"

        genreData = self.load_genre_df(genre_path)
        songData = self.load_song_df(song_path)
        return songData.join(genreData, songData.track_id == genreData.id, joinType)


"""
preview the result of the genre df

"""

dataframeloader = DataFrameLoader()

rdd1 = dataframeloader.load_genre_df(genre_path)
df = rdd1.toDF("id", "genre")
df.show()
