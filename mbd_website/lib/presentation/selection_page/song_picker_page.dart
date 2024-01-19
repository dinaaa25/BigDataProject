import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:mbd_website/application/get_song_bloc/get_song_bloc.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbd_website/injection.dart';
import 'package:mbd_website/main.dart';
import 'package:get_it/get_it.dart';
import 'package:mbd_website/presentation/selection_page/widgets/song_pop_up_dialog.dart';

class SongPickerPage extends StatelessWidget {
  const SongPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Picker'),
      ),
      body: const BubbleScreen(),
    );
  }
}

class BubbleScreen extends StatefulWidget {
  const BubbleScreen({super.key});

  @override
  _BubbleScreenState createState() => _BubbleScreenState();
}

class _BubbleScreenState extends State<BubbleScreen> {
  final GlobalKey containerKey = GlobalKey();

  final List<String> genres = [
    'Jazz',
    'Pop',
    // 'Rock',
    // 'Latin',
    // 'Classical',
    // 'Metal'
  ];

  final List<String> inactiveGenres = [
    'Country',
    'Hip Hop',
    'R&B',
    'Electronic',
    'Folk',
    'Blues',
    'Reggae',
    'Punk',
    'Disco',
    'Funk',
    'Soul',
    'Techno',
    'Gospel',
    'Opera',
    'Ska',
    'New Age',
    'Ambient',
    'Industrial',
    'Grunge',
    'Dance',
    'Dubstep',
    'Drum and Bass',
    'Trance',
    'House',
    'Garage',
    'Hardcore',
    'Hardstyle',
  ];

  List<double> percentages = [];

  // The logic to find the nearest point on the circle and add a bubble
  void onBubbleDroppedInBox(
    String genre,
    Offset droppedPosition,
    Offset circleCenter,
    double circleRadius,
  ) {
    print('bubble dropped in box');
    // Convert the dropped position to an angle
    double dropAngle = math.atan2(droppedPosition.dy - circleCenter.dy,
        droppedPosition.dx - circleCenter.dx);

    // Normalize the angle
    dropAngle = (dropAngle < 0) ? (2 * math.pi + dropAngle) : dropAngle;

    // This is a simple way to add the genre to the active list for now
    // You will need more complex logic to place it correctly
    if (!genres.contains(genre)) {
      setState(() {
        percentages = [];
        genres.add(genre);
        inactiveGenres.remove(genre); // Remove the genre from inactive list
      });
    }
  }

  // Logic to handle dragging a genre out of the container
  void onBubbleDraggedOutOfBox(
    String genre,
    int index,
  ) {
    setState(() {
      percentages = [];
      inactiveGenres.add(genre);
      genres.remove(genre);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming the container for the bubbles is a square
    final double containerWidth = MediaQuery.of(context).size.width * 0.4;
    final double containerHeight = MediaQuery.of(context).size.height * 0.8;
    final Offset center = Offset(containerWidth / 2, containerHeight / 2);
    final double circleRadius =
        containerWidth / 3; // The radius is half the width of the container
    const double bubbleDiameter = 100;

    List<Offset> bubblePositions = [];

    List<Widget> positionedBubbles = genres.asMap().entries.map((entry) {
      int index = entry.key;
      String genre = entry.value;

      const double startAngle = -math.pi / 2;
      // Calculate position for each bubble
      final double angle = startAngle + (2 * math.pi / genres.length) * index;
      // Calculate the bubble's center point based on the center of the container
      final double x = center.dx +
          circleRadius * math.cos(angle); // Adjust for the size of the bubble
      final double y = center.dy +
          circleRadius * math.sin(angle); // Adjust for the size of the bubble

      //set the bubblePositions
      // the position should be the place of the bubble which is closest to the center, so a point on the edge of the bubble
      final originalDistanceToCenter = Offset(x, y).distance;

      final adjustedDistance = originalDistanceToCenter - (bubbleDiameter);

      final factorOfDistanceFromCenter =
          adjustedDistance / originalDistanceToCenter;

      final edgePointX =
          center.dx + (x - center.dx) * factorOfDistanceFromCenter;
      final edgePointY =
          center.dy + (y - center.dy) * factorOfDistanceFromCenter;
      bubblePositions.add(Offset(edgePointX, edgePointY));
      final bool usePercentages = percentages.length == genres.length;

      return Positioned(
        left: x - bubbleDiameter / 2,
        top: y - bubbleDiameter / 2,
        child: DraggableBubble(
          genre: genre,
          diameter: bubbleDiameter,
          onBubbleDroppedInBox: onBubbleDroppedInBox,
          circleCenter: center,
          circleRadius: circleRadius,
          percentage: usePercentages ? percentages[index] : null,
          index: index,
          onBubbleDraggedOutOfBox: onBubbleDraggedOutOfBox,
          isActive: true,
        ),
      );
    }).toList();

    return Scaffold(
      body: BlocProvider(
        create: (context) => getIt<GetSongBloc>(),
        child: Builder(
          // this stack is used to make an overlay when there is a result
          builder: (context) => BlocListener<GetSongBloc, GetSongState>(
            listener: (context, state) => state.maybeMap(
                orElse: () => {},
                loadFailure: (value) =>
                    FlushbarHelper.createError(message: 'Something went wrong')
                        .show(context),
                loadSuccess: (value) {
                  return showDialog(
                      context: context,
                      builder: (context) => SongPopUpDialog(song: value.song));
                }),
            child: BlocBuilder<GetSongBloc, GetSongState>(
              builder: (context, state) {
                return DragTarget(
                  onWillAccept: (data) {
                    if (data == 'true') {
                      return true;
                    } else {
                      return false;
                    }
                  },
                  builder: (context, candidateData, rejectedData) =>
                      Stack(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Inactive genres list
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: inactiveGenres.length,
                            itemBuilder: (context, index) {
                              return DraggableBubble(
                                genre: inactiveGenres[index],
                                diameter: 70,
                                onBubbleDroppedInBox: onBubbleDroppedInBox,
                                circleCenter: center,
                                circleRadius: circleRadius,
                                onBubbleDraggedOutOfBox: onBubbleDraggedOutOfBox,
                                percentage: null,
                                index: null,
                                isActive: false,
                              );
                            },
                          ),
                        ),
                        // Draggable bubbles area
                        GestureDetector(
                          onTapUp: (details) {
                            // Obtain the local position of the tap
                            final RenderBox box = containerKey.currentContext!
                                .findRenderObject() as RenderBox;
                            final Offset localPosition =
                                box.globalToLocal(details.globalPosition);

                            List<double> inverseDistances = [];

                            for (int i = 0; i < bubblePositions.length; i++) {
                              inverseDistances.add(1 /
                                  ((localPosition - bubblePositions[i])
                                      .distance));
                            }

                            final totalInverseDistance =
                                inverseDistances.reduce((a, b) => a + b);

                            //divide each inverse distance by the total inverse distance
                            final percentages = inverseDistances
                                .map((e) => e / totalInverseDistance)
                                .toList();

                            setState(() {
                              this.percentages = percentages;
                            });
                          },
                          child: DragTarget<String>(
                            onWillAccept: (data) {
                              if (data == 'true') {
                                return false;
                              } else {
                                return true;
                              }
                            },
                            builder: (BuildContext context,
                                    List<String?> candidateData,
                                    List<dynamic> rejectedData) =>
                                Container(
                              key: containerKey,
                              width: containerWidth,
                              height: MediaQuery.of(context).size.height * 0.8,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Stack(children: [
                                Stack(
                                  children: positionedBubbles,
                                ),
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: FloatingActionButton(
                                    child: const Text('Search'),
                                    onPressed: () => {
                                      context.read<GetSongBloc>().add(
                                            GetSongEvent.clickRegistered(
                                              genres: genres,
                                              percentages: percentages,
                                            ),
                                          )
                                    },
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    state.maybeMap(
                        orElse: () => Container(),
                        loading: (value) {
                          return Center(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.white.withOpacity(0.2),
                              child: const Center(
                                // Center the CircularProgressIndicator
                                child: SizedBox(
                                  width:
                                      50, // Width of the CircularProgressIndicator
                                  height:
                                      50, // Height of the CircularProgressIndicator
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DraggableBubble extends StatelessWidget {
  final String genre;
  final double diameter;
  final Offset circleCenter;
  final double circleRadius;
  final double? percentage;
  final int? index;
  final Function onBubbleDraggedOutOfBox;
  final bool isActive;

  final Function onBubbleDroppedInBox;

  const DraggableBubble({
    Key? key,
    required this.genre,
    required this.diameter,
    required this.onBubbleDroppedInBox,
    required this.onBubbleDraggedOutOfBox,
    required this.circleCenter,
    required this.circleRadius,
    required this.percentage,
    required this.index,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      onDragEnd: (details) {
        if (details.wasAccepted) {
          onBubbleDroppedInBox(
              genre, details.offset, circleCenter, circleRadius);
          if (isActive) {
            onBubbleDraggedOutOfBox(
              genre,
              index!,
            );
          }
        }
      },
      data: '$isActive',
      feedback: BubbleWidget(
        genre: genre,
        diameter: diameter,
        percentage: percentage,
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: BubbleWidget(
          genre: genre,
          diameter: diameter,
          percentage: percentage,
        ),
      ),
      child: BubbleWidget(
        genre: genre,
        diameter: diameter,
        percentage: percentage,
      ),
    );
  }
}

class BubbleWidget extends StatelessWidget {
  final String genre;
  final double diameter;
  final double? percentage;

  const BubbleWidget({
    Key? key,
    required this.genre,
    required this.diameter,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = percentage != null ? (percentage! * 100).toStringAsFixed(1) : '';
    final pString = percentage != null ? '$p%' : '';
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: spotifyGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$genre $pString',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
