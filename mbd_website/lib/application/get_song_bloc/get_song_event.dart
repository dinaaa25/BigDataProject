part of 'get_song_bloc.dart';

@freezed
class GetSongEvent with _$GetSongEvent {
  const factory GetSongEvent.started() = _Started;
}