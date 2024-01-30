import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mbd_website/domain/failures.dart';
import 'package:mbd_website/domain/i_get_song_repo.dart';
import 'package:mbd_website/domain/objects.dart';

var baseGenre = {
  "genres": {
    "Rock": 0.0,
    "Electronic": 0.0,
    "Pop": 0.0,
    "Jazz": 0.0,
    "RnB": 0.0,
    "Rap": 0.0,
    "Metal": 0.0,
    "Country": 0.0,
    "Blues": 0.0,
    "Reggae": 0.0,
    "Folk": 0.0,
    "Punk": 0.0,
    "Latin": 0.0,
    "World": 0.0,
    "New Age": 0.0
  }
};

@LazySingleton(as: IGetSongRepo)
class GetSongRepo implements IGetSongRepo {
  Dio songApi = Dio(BaseOptions(baseUrl: "http://167.71.6.210/"));

  @override
  Future<Either<Failure, Song>> getSong(
      List<String> genres, List<double> percentages) async {
    Map userGenres = Map.of(baseGenre);
    for (var i = 0; i < genres.length; i++) {
      userGenres["genres"]?[genres[i]] = percentages[i];
    }

    var res = await songApi.post("/predicted_song", data: userGenres);
    if (res.statusCode == 200) {
      try {
        Song mySong = Song.fromJson(res.data);
        Either<Failure, Song> song = Right(mySong);
        return song;
      } catch (e, stack) {
        return Left(Failure.songNotFound());
      }
    }

    Either<Failure, Song> failure = Left(Failure.songNotFound());
    return failure;
  }
}
