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

Map<int, String> chordMap = {
  1: "C Major",
  2: "D Minor",
  3: "E Minor",
  4: "F Major",
  5: "G Major",
  6: "A Minor",
  7: "B Dim",
};

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

  get letterKey {
    return chordMap[this.key];
  }

  get readableYear {
    if (this.year == "0") {
      return "Year Unknown";
    }
    return this.year;
  }

  static Song fromJson(Map<String, dynamic> json) {
    return Song(
        title: (json["title"] as Map).values.toList()[0],
        artistName: (json["artist_name"] as Map).values.toList()[0],
        key: (json["key"] as Map).values.toList()[0],
        year: (json["year"] as Map).values.toList()[0]);
  }
}
