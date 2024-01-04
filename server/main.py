from fastapi import FastAPI

import sys

sys.path.append("..")

from df_loader import DataFrameLoader

app = FastAPI()

dataframeloader = DataFrameLoader()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/genretypes")
def getGenreTypes():
    return ["rock", "pop"]


@app.get("/genreCoordinates")
def getGenreCoordinates():
    return {"rock": (2, 1), "pop": (3, 4)}


@app.get("/sampleOfSongs")
def getSampleOfSongs():
    return ["jingle bells", "frosty the snowman"]


@app.get("/songCoordinates")
def getSongCoordinates():
    return {"jingle bells": (2, 1), "frosty the snowman": (3, 4)}
