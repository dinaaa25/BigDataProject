import 'dart:convert';
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mbd_website/domain/failures.dart';
import 'package:mbd_website/domain/i_get_song_repo.dart';
import 'package:mbd_website/domain/objects.dart';

@LazySingleton(as: IGetSongRepo)
class GetSongRepo implements IGetSongRepo {
  Dio songApi = Dio(BaseOptions(baseUrl: "http://167.71.6.210/"));

  @override
  Future<Either<Failure, Song>> getSong(
      List<String> genres, List<double> percentages) async {
    Map genreMap = {"genres": {}};
    for (var i = 0; i < genres.length; i++) {
      genreMap["genres"][genres[i]] = percentages[i];
    }
    var res = await songApi.get("/predicted_song", data: genreMap);
    if (res.statusCode == 200) {
      Song mySong = Song.fromJson(res.data);
      Either<Failure, Song> song = Right(mySong);
      return song;
    }

    Either<Failure, Song> failure = Left(Failure.songNotFound());
    return failure;
  }
}
