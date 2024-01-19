part of 'get_song_bloc.dart';

@freezed
class GetSongState with _$GetSongState {
  //states
  // loading
  // loadsuccess
  // loadfailure

  const factory GetSongState.initial() = _Initial;
  const factory GetSongState.loading() = _Loading;
  const factory GetSongState.loadSuccess(Song song) = _LoadSuccess;
  const factory GetSongState.loadFailure(Failure failure) = _LoadFailure;
}
