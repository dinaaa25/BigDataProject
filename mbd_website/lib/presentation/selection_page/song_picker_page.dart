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

class BubbleScreen extends StatelessWidget {
  const BubbleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate the diameter for the circle based on the screen size
    final double diameter =
        MediaQuery.of(context).size.width * 0.4; // 80% of the screen width
    final double radius = diameter / 2;
    final Offset center = Offset(
        radius, radius); // Since the circle is in the center of the square

    // Example genres list
    final List<String> genres = ['Jazz', 'Pop', 'Rock', 'Latin', 'Classical'];

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(diameter, diameter),
              painter: BubblePainter(
                diameter,
                genres.length,
                genres,
                bubbleRadius: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final double diameter;
  final double bubbleRadius;
  final int numBubbles;
  final List<String> genres;

  BubblePainter(this.diameter, this.numBubbles, this.genres,
      {this.bubbleRadius = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bubblePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = diameter / 2 - bubbleRadius;

    const double startAngle = -math.pi / 2;
    for (int i = 0; i < numBubbles; i++) {
      double angle = startAngle + (2 * math.pi / numBubbles) * i;
      Offset bubblePosition = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawCircle(
          bubblePosition, bubbleRadius, bubblePaint); // Draw the bubble

      // Draw the text
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: genres[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate the position to center the text inside the bubble
      final Offset textPosition = bubblePosition -
          Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, textPosition);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
