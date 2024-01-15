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
      body: const BubbleCircle(),
    );
  }
}

class BubbleCircle extends StatelessWidget {
  const BubbleCircle({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to get screen size
    final screenSize = MediaQuery.of(context).size;
    final squareSize = math.min(screenSize.width, screenSize.height) * 0.8;
    final circleDiameter = squareSize * 0.8;

    return Center(
      child: Container(
        width: squareSize,
        height: squareSize,
        decoration: BoxDecoration(
          color: Colors.grey[300], // Background color for the square
          shape: BoxShape.rectangle,
        ),
        child: CustomPaint(
          painter: BubblePainter(circleDiameter),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final double diameter;

  BubblePainter(this.diameter);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Paint bubblePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Center of the square
    final Offset center = Offset(size.width / 2, size.height / 2);
    // Radius of the circle
    final double radius = diameter / 2;

    // Draw the main circle
    canvas.drawCircle(center, radius, circlePaint);

    // Calculate the bubble positions and draw them
    const int numberOfBubbles = 3;
    // Adjust the starting angle to be at the top center
    final double startAngle = -math.pi / 2;
    for (int i = 0; i < numberOfBubbles; i++) {
      // Angle calculation for bubble placement
      double angle = startAngle + (2 * math.pi / numberOfBubbles) * i;
      // Bubble position
      Offset bubblePosition = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      // Draw the bubble
      canvas.drawCircle(bubblePosition, 20.0, bubblePaint); // Bubble radius is set to 20.0
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



