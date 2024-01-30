import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:mbd_website/domain/objects.dart';
import 'package:mbd_website/main.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: Color(0xFF292524),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "By ${song.artistName} - ${song.year}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 25,
                    color: Color(0xFFA1A1AA),
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                "Release: ${song.readableYear}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    color: Color(0xFFA1A1AA),
                    fontWeight: FontWeight.bold),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 18, color: Colors.white),
                        ),
                        const Spacer(), // You can adjust the space by using SizedBox instead of Spacer
                        Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    // Add play button logic here
                    final queryParameters = {
                      'search_query': "${song.title} ${song.artistName}",
                    };
                    Uri youtubeLink =
                        Uri.https("youtube.com", "/results", queryParameters);

                    print(youtubeLink.toString());
                    launchUrl(youtubeLink);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFF43F5E),
                    onPrimary: Colors.white,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Iconify(
                          Carbon.logo_youtube,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Play on Youtube',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                        )
                      ])),
            ),
          ],
        ),
      ),
    );
  }
}
