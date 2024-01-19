import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_song_event.dart';
part 'get_song_state.dart';
part 'get_song_bloc.freezed.dart';

class GetSongBloc extends Bloc<GetSongEvent, GetSongState> {
  GetSongBloc() : super(_Initial()) {
    on<GetSongEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
