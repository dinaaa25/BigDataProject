import 'dart:ui';

class Bubble {
  final String genre;
  final Color color;
  final int xPosition;
  final int yPosition;

  const Bubble(
      {required this.genre,
      required this.color,
      required this.xPosition,
      required this.yPosition});
}

class Song {
  final String title;
  final Map<String, double> genrePercentages;

  const Song({required this.title, required this.genrePercentages});
}
