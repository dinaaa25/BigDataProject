// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:mbd_website/application/get_song_bloc/get_song_bloc.dart'
    as _i5;
import 'package:mbd_website/domain/i_get_song_repo.dart' as _i3;
import 'package:mbd_website/infrastructure/get_song_repo.dart' as _i4;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.IGetSongRepo>(() => _i4.GetSongRepo());
    gh.factory<_i5.GetSongBloc>(() => _i5.GetSongBloc(gh<_i3.IGetSongRepo>()));
    return this;
  }
}
