import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    'Rock',
    'Latin',
    'Classical',
    'Metal'
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

  // The logic to find the nearest point on the circle and add a bubble
  void onBubbleDroppedInBox(String genre, Offset droppedPosition,
      Offset circleCenter, double circleRadius) {
    print('bubble dropped in box');
    // Convert the dropped position to an angle
    double dropAngle = math.atan2(droppedPosition.dy - circleCenter.dy,
        droppedPosition.dx - circleCenter.dx);

    // Normalize the angle
    dropAngle = (dropAngle < 0) ? (2 * math.pi + dropAngle) : dropAngle;

    // This is a simple way to add the genre to the active list for now
    // You will need more complex logic to place it correctly
    setState(() {
      genres.add(genre);
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

    List<Map<String, double>> bubblePositions = [];

    List<Widget> positionedBubbles = genres.asMap().entries.map((entry) {
      int index = entry.key;
      String genre = entry.value;

      const double startAngle = -math.pi / 2;
      // Calculate position for each bubble
      final double angle = startAngle + (2 * math.pi / genres.length) * index;
      // Calculate the bubble's center point based on the center of the container
      final double x = center.dx +
          circleRadius * math.cos(angle) -
          bubbleDiameter / 2; // Adjust for the size of the bubble
      final double y = center.dy +
          circleRadius * math.sin(angle) -
          bubbleDiameter / 2; // Adjust for the size of the bubble

      //set the bubblePositions
      bubblePositions.add({'x': x, 'y': y});

      return Positioned(
        left: x,
        top: y,
        child: DraggableBubble(
          genre: genre,
          diameter: bubbleDiameter,
          onBubbleDroppedInBox: onBubbleDroppedInBox,
          circleCenter: center,
          circleRadius: circleRadius,
        ),
      );
    }).toList();

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Inactive genres list
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.8,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  );
                },
              ),
            ),
            // Draggable bubbles area
            GestureDetector(
              onTapUp: (details) {
                // Obtain the local position of the tap
                final RenderBox box = containerKey.currentContext!.findRenderObject() as RenderBox;
                final Offset localPosition =
                    box.globalToLocal(details.globalPosition);

                // Calculate the offset from the center
                final Offset offsetFromCenter = localPosition - center;

                // If you need just the distance from the center
                final double distanceFromCenter = offsetFromCenter.distance;

                
              },
              child: Container(
                key: containerKey,
                width: containerWidth,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                  children: positionedBubbles,
                ),
              ),
            ),
          ],
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

  final Function onBubbleDroppedInBox;

  const DraggableBubble({
    Key? key,
    required this.genre,
    required this.diameter,
    required this.onBubbleDroppedInBox,
    required this.circleCenter,
    required this.circleRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      onDragEnd: (details) {
        print('drag end');
        onBubbleDroppedInBox(genre, details.offset, circleCenter, circleRadius);
      },
      data: genre,
      feedback: BubbleWidget(genre: genre, diameter: diameter),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: BubbleWidget(genre: genre, diameter: diameter),
      ),
      child: BubbleWidget(genre: genre, diameter: diameter),
    );
  }
}

class BubbleWidget extends StatelessWidget {
  final String genre;
  final double diameter;

  const BubbleWidget({
    Key? key,
    required this.genre,
    required this.diameter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        genre,
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
