import 'package:dartz/dartz.dart';
import 'package:mbd_website/domain/failures.dart';
import 'package:mbd_website/domain/objects.dart';

abstract class IGetSongRepo {
  Future<Either<Failure, Song>> getSong(List<String> genres, List<double> percentages);
}
