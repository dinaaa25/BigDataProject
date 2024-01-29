from fastapi import Body, FastAPI

import sys
import pandas
from pydantic import BaseModel
from typing import Dict, Optional, Annotated, List

sys.path.append("..")

app = FastAPI()

results = pandas.read_parquet("../results.parquet")
songs = pandas.read_csv("../songNames.csv")


def getSongByPercentages(percentages):
    diffSum = 0
    track_id = 0
    for i, row in results.iterrows():
        localSum = 0
        for percentage in percentages:
            diff = (row[percentage] - percentages[percentage]) ** 2
            localSum = localSum + diff

        if i == 0:
            diffSum = localSum

        if diffSum > localSum:
            diffSum = localSum
            track_id = row["track_id"]

    songData = songs[songs["track_id"] == track_id]
    return songData


@app.get("/genres")
def getGenres() -> List[str]:
    """
    returns all available genres
    """
    return list(results.columns[4:])


class GenreData(BaseModel):
    genres: Dict[str, float]


@app.post("/predicted_song")
def getPredictedSong(
    genre_data: Annotated[
        GenreData,
        Body(
            examples=[
                {
                    "genres": {
                        "Rock": 0.1,
                        "Electronic": 0.1,
                        "Pop": 0.1,
                        "Jazz": 0.1,
                        "RnB": 0.1,
                        "Rap": 0.1,
                        "Metal": 0.1,
                        "Country": 0.1,
                        "Blues": 0.1,
                        "Reggae": 0.1,
                        "Folk": 0.1,
                        "Punk": 0.1,
                        "Latin": 0.1,
                        "World": 0.1,
                        "New Age": 0.1,
                    },
                }
            ],
        ),
    ],
):
    return getSongByPercentages(genre_data.genres)
