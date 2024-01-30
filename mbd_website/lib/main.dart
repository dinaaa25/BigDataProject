import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mbd_website/presentation/selection_page/song_picker_page.dart';
import 'package:mbd_website/injection.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());

  configureInjection(
    Environment.prod,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
        primaryColor: spotifyBlack, // Spotify Black
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: spotifyGreen), // Spotify Green
        scaffoldBackgroundColor: const Color(0xFF191414), // Background color
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF191414), // AppBar color
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: spotifyGreen, // FAB color
          foregroundColor: Colors.white,
        ));
    themeData = themeData.copyWith(
      textTheme: GoogleFonts.kanitTextTheme(themeData.textTheme),
    );
    return MaterialApp(
      title: 'Mapify',
      theme: themeData,
      home: SongPickerPage(),
    );
  }
}

const spotifyGreen = Color(0xFF1DB954);
const spotifyBlack = Color(0xFF191414);
