import 'package:flutter/material.dart';

class FloodFillService {
  // Basit flood fill implementasyonu
  static void floodFill({
    required List<Offset> points,
    required Offset position,
    required Color fillColor,
    required Function(Offset, Color) addPoint,
  }) {
    // Bu basit implementasyon flood fill benzeri bir daire çizer
    final radius = 50.0;
    
    for (double angle = 0; angle < 360; angle += 5) {
      for (double r = 0; r < radius; r += 2) {
        final x = position.dx + r * (angle / 360) * 2 - 1;
        final y = position.dy + r * (angle / 360) * 2 - 1;
        addPoint(Offset(x, y), fillColor);
      }
    }
  }
}
