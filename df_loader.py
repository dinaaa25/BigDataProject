#-------------IMPORTS----------------------------------------------
from pyspark.sql import SparkSession

#-------------CREATE_SPARK_SESSION-----------------------------------
# spark: spark = (
# SparkSession.builder.appName("SongProject")
# .master("http://spark-head5.eemcs.utwente.nl:4040")
# .getOrCreate()
# )

# spark = SparkSession.builder.remote(
#     "sc://spark-head5.eemcs.utwente.nl:4040"
# ).getOrCreate()

spark = SparkSession.builder.appName("MSD-df_load").getOrCreate()
sc = spark.sparkContext

#set log level to remove redundant logging messages
sc.setLogLevel("ERROR")

#--------------PATHS_TO_DATA--------------------------------
genre_path = "/user/s2345846/project/msd_tagtraum_cd2.cls"
song_path = "/data/doina/OSCD-MillionSongDataset/output_" #*.csv"

#--------------DATAFRAME_LOADING---------------------------
class DataFrameLoader:
    """
    Loads the starting dataframe from the given hdfs datasets
    It has 2 columns:
    id - the unique id of the song
    genre - the genre taken from the genre_path
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
        returns a list with the unique genre types
        """
        genreData = self.load_genre_df(genre_path)
        distinctDF = genreData.select("genre").distinct()
        return distinctDF.rdd.map(lambda x: x.genre).collect()

    def load_song_df(self, path: str):
        """
        returns the df with all attributes from the song dataset
        """
        return spark.read.options(header=True, quote='"', escape='"').csv(path)

    def join_dataframes(self, partial_song_path, useAllTracks=True):
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
        songData = self.load_song_df(partial_song_path)

        # optionally select only a few columns to keep
        #songData = songData.select("track_id")
        return songData.join(genreData, songData.track_id == genreData.id, joinType)

dataframeloader = DataFrameLoader()

#------------------PREVIEW_DATA-------------------------------------------------
"""
Preview the result of the genre df
"""
#df_genre = dataframeloader.load_genre_df(genre_path)
#df_genre.sort("id").show(10)

"""
Preview the result of the joined df
"""
# df_joined = dataframeloader.join_dataframes(useAllTracks=False)
# df_joined.count()
# #df_joined.show(10)

"""
Preview the result of the song df
"""
#df_song = dataframeloader.load_song_df(song_path).select("artist_terms").sort("artist_terms")
#df_song.show(10)

#------------------SAVE_DATAFRAME--------------------------------------------
"""
Export a dataframe containing the song id and corresponding genres to parquet files 
"""
for p in range(5):
    song_path_full = song_path + (str(chr(ord('A') + p)) + ".csv")
    df_for_ml = dataframeloader.join_dataframes(song_path_full, useAllTracks=False)
    print(df_for_ml.count()) #-> 38367, 36618, 35955, 35724, 35241 tracks in the sets

    #df_for_ml = df_joined
    save_folder = "/user/s2549182/MBD/id_genres_" + str(chr(ord('A') + p))
    df_for_ml.write.parquet(path=save_folder, mode="overwrite")