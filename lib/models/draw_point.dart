import 'package:flutter/material.dart';

class DrawPoint {
  final Offset offset;
  final double pressure;
  final Color color;
  final double brushSize;
  final DateTime timestamp;

  DrawPoint({
    required this.offset,
    this.pressure = 1.0,
    required this.color,
    required this.brushSize,
    required this.timestamp,
  });

  DrawPoint copyWith({
    Offset? offset,
    double? pressure,
    Color? color,
    double? brushSize,
    DateTime? timestamp,
  }) {
    return DrawPoint(
      offset: offset ?? this.offset,
      pressure: pressure ?? this.pressure,
      color: color ?? this.color,
      brushSize: brushSize ?? this.brushSize,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class DrawPath {
  final List<DrawPoint> points;
  final Color color;
  final double brushSize;
  final String drawMode;
  final DateTime createdAt;

  DrawPath({
    required this.points,
    required this.color,
    required this.brushSize,
    required this.drawMode,
    required this.createdAt,
  });

  DrawPath copyWith({
    List<DrawPoint>? points,
    Color? color,
    double? brushSize,
    String? drawMode,
    DateTime? createdAt,
  }) {
    return DrawPath(
      points: points ?? this.points,
      color: color ?? this.color,
      brushSize: brushSize ?? this.brushSize,
      drawMode: drawMode ?? this.drawMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
