import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mbd_website/presentation/selection_page/song_picker_page.dart';
import 'package:mbd_website/injection.dart';

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
    return MaterialApp(
      title: 'My Bubble Diary',
      theme: ThemeData(
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
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
          // Define other text styles if needed
        ),
        // Additional customizations can go here
      ),
      home: SongPickerPage(),
    );
  }
}

const spotifyGreen = Color(0xFF1DB954);
const spotifyBlack = Color(0xFF191414);
