part of 'get_song_bloc.dart';

@freezed
class GetSongEvent with _$GetSongEvent {
  const factory GetSongEvent.clickRegistered({
    required List<String> genres,
    required List<double> percentages,
  }) = _ClickRegistered;
}