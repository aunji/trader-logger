import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  // Icon size
  const int size = 1024;

  // Create a canvas
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Colors matching the theme
  const backgroundColor = Color(0xFF0A0E27); // backgroundDark
  const goldColor = Color(0xFFFFD700); // accentGold

  // Draw background
  final backgroundPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    backgroundPaint,
  );

  // Draw gold circle
  final circlePaint = Paint()
    ..color = goldColor
    ..style = PaintingStyle.fill;

  canvas.drawCircle(
    Offset(size / 2, size / 2),
    size * 0.35,
    circlePaint,
  );

  // Draw trending up arrow icon (simplified)
  final arrowPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.08
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final path = Path();

  // Arrow line going up
  path.moveTo(size * 0.3, size * 0.7);
  path.lineTo(size * 0.5, size * 0.3);
  path.lineTo(size * 0.7, size * 0.5);

  // Arrow head
  path.moveTo(size * 0.55, size * 0.3);
  path.lineTo(size * 0.7, size * 0.3);
  path.lineTo(size * 0.7, size * 0.45);

  canvas.drawPath(path, arrowPaint);

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save to file
  final file = File('assets/icon.png');
  await file.writeAsBytes(buffer);

  print('Icon created successfully at: assets/icon.png');
  exit(0);
}
