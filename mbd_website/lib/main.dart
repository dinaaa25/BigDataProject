import 'package:flutter/material.dart';
import 'package:mbd_website/presentation/selection_page/song_picker_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bubble Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SongPickerPage(),
    );
  }
}



