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
  final String? artistName;
  final String? key;
  final String? year;
  final Map<String, double> genrePercentages;

  const Song(
      {required this.title,
      this.genrePercentages = const {},
      this.year,
      this.key,
      this.artistName});

  static Song fromJson(Map<String, dynamic> json) {
    return Song(
        title: json["title"][0],
        artistName: json["artist_name"][0],
        key: json["key"][0],
        year: json["year"][0]);
  }
}
