import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mbd_website/domain/failures.dart';
import 'package:mbd_website/domain/i_get_song_repo.dart';
import 'package:mbd_website/domain/objects.dart';

@LazySingleton(as: IGetSongRepo)
class GetSongRepo implements IGetSongRepo {
  @override
  Future<Either<Failure, Song>> getSong(List<String> genres, List<double> percentages) {
    // TODO: implement getSong
    throw UnimplementedError();
  }
  
}