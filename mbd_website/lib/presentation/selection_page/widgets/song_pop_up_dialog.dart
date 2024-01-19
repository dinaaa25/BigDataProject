import 'package:flutter/material.dart';
import 'package:mbd_website/domain/objects.dart';
import 'package:mbd_website/main.dart';

class SongPopUpDialog extends StatelessWidget {
  final Song song; // The title of the song
  // Map of genres and their percentages

  const SongPopUpDialog({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.2),
      insetPadding: EdgeInsets.zero, // Ensures the dialog covers full screen
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.5, // 50% width of the screen
        height: MediaQuery.of(context).size.height *
            0.5, // 50% height of the screen
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0), // Optional: rounded corners
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                song.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: song.genrePercentages.length,
                itemBuilder: (context, index) {
                  String genre = song.genrePercentages.keys.elementAt(index);
                  double percentage = song.genrePercentages[genre]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          genre,
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(), // You can adjust the space by using SizedBox instead of Spacer
                        Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  // Add play button logic here
                },
                child: const Text('Play'),
                style: ElevatedButton.styleFrom(
                  primary: spotifyGreen,
                  onPrimary: Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}
