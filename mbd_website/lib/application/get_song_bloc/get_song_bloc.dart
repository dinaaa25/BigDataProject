import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mbd_website/domain/failures.dart';
import 'package:mbd_website/domain/i_get_song_repo.dart';
import 'package:mbd_website/domain/objects.dart';

part 'get_song_event.dart';
part 'get_song_state.dart';
part 'get_song_bloc.freezed.dart';

@injectable
class GetSongBloc extends Bloc<GetSongEvent, GetSongState> {
  final IGetSongRepo _getSongRepo;
  GetSongBloc(this._getSongRepo) : super(const _Initial()) {
    on<_ClickRegistered>((event, emit) async {
      emit(const GetSongState.loading());
      final genres = event.genres;
      final percentages = event.percentages;
      var result = await this._getSongRepo.getSong(genres, percentages);

      result.fold((l) => emit(GetSongState.loadFailure(l as Failure)),
          (r) => emit(GetSongState.loadSuccess(r as Song)));

      // final failureOrSong = await _getSongRepo.getSong(genres, percentages);

      // failureOrSong.fold(
      //   (failure) => emit(GetSongState.loadFailure(failure)),
      //   (song) => emit(GetSongState.loadSuccess(song)),
      // );
    });
  }
}
