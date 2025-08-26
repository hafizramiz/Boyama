import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/draw_point.dart';
import '../services/mask_painting_service.dart';

class PaintingCanvas extends CustomPainter {
  final List<DrawPath> paths;
  final Color backgroundColor;
  final Size canvasSize;
  final DrawPath? currentPath;
  final bool showMaskImage;

  PaintingCanvas({
    required this.paths,
    required this.backgroundColor,
    required this.canvasSize,
    this.currentPath,
    this.showMaskImage = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw mask image if enabled
    if (showMaskImage) {
      MaskBasedPaintingService.drawMaskImage(canvas, size);
    }

    // Draw all completed paths
    for (final path in paths) {
      _drawPath(canvas, path, size);
    }

    // Draw current path if exists
    if (currentPath != null) {
      _drawPath(canvas, currentPath!, size);
    }
  }

  void _drawPath(Canvas canvas, DrawPath drawPath, Size size) {
    if (drawPath.points.isEmpty) return;

    final paint = Paint()
      ..color = drawPath.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = drawPath.brushSize;

    switch (drawPath.drawMode) {
      case 'Kalem': // Pencil
        _drawPencilPath(canvas, drawPath, paint);
        break;
      case 'İşaretleyici': // Marker
        _drawMarkerPath(canvas, drawPath, paint);
        break;
      case 'Sprey': // Spray
        _drawSprayPath(canvas, drawPath, paint);
        break;
      case 'Sihir': // Magic
        _drawMagicPath(canvas, drawPath, paint);
        break;
      case 'Silgi': // Eraser
        _drawEraserPath(canvas, drawPath, paint);
        break;
      case 'bucket_fill':
        _drawBucketFill(canvas, drawPath, paint);
        break;
      default:
        _drawPencilPath(canvas, drawPath, paint);
    }
  }

  void _drawPencilPath(Canvas canvas, DrawPath drawPath, Paint paint) {
    paint.style = PaintingStyle.stroke;
    
    if (drawPath.points.length == 1) {
      // Single point - draw a circle
      canvas.drawCircle(
        drawPath.points.first.offset,
        drawPath.brushSize / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    path.moveTo(drawPath.points.first.offset.dx, drawPath.points.first.offset.dy);

    for (int i = 1; i < drawPath.points.length; i++) {
      final point = drawPath.points[i];
      path.lineTo(point.offset.dx, point.offset.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawMarkerPath(Canvas canvas, DrawPath drawPath, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.color = drawPath.color.withOpacity(0.7); // Semi-transparent for marker effect
    
    for (int i = 0; i < drawPath.points.length; i++) {
      final point = drawPath.points[i];
      canvas.drawCircle(
        point.offset,
        drawPath.brushSize / 2,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  void _drawSprayPath(Canvas canvas, DrawPath drawPath, Paint paint) {
    final random = math.Random();
    paint.style = PaintingStyle.fill;
    
    for (final point in drawPath.points) {
      final sprayRadius = drawPath.brushSize;
      final particleCount = (sprayRadius * 0.5).round();
      
      for (int i = 0; i < particleCount; i++) {
        final angle = random.nextDouble() * 2 * math.pi;
        final distance = random.nextDouble() * sprayRadius;
        final particleX = point.offset.dx + math.cos(angle) * distance;
        final particleY = point.offset.dy + math.sin(angle) * distance;
        
        canvas.drawCircle(
          Offset(particleX, particleY),
          random.nextDouble() * 2 + 1,
          paint,
        );
      }
    }
  }

  void _drawMagicPath(Canvas canvas, DrawPath drawPath, Paint paint) {
    final random = math.Random();
    paint.style = PaintingStyle.fill;
    
    for (int i = 0; i < drawPath.points.length; i++) {
      final point = drawPath.points[i];
      
      // Create rainbow effect
      final hue = (i * 10) % 360;
      final magicColor = HSVColor.fromAHSV(1.0, hue.toDouble(), 1.0, 1.0).toColor();
      paint.color = magicColor;
      
      // Draw with sparkle effect
      canvas.drawCircle(
        point.offset,
        drawPath.brushSize / 2,
        paint,
      );
      
      // Add sparkle particles
      for (int j = 0; j < 3; j++) {
        final sparkleOffset = Offset(
          point.offset.dx + (random.nextDouble() - 0.5) * drawPath.brushSize,
          point.offset.dy + (random.nextDouble() - 0.5) * drawPath.brushSize,
        );
        
        canvas.drawCircle(
          sparkleOffset,
          random.nextDouble() * 3 + 1,
          paint..color = Colors.white.withOpacity(0.8),
        );
      }
    }
  }

  void _drawEraserPath(Canvas canvas, DrawPath drawPath, Paint paint) {
    paint.blendMode = BlendMode.clear;
    paint.style = PaintingStyle.stroke;
    
    if (drawPath.points.length == 1) {
      canvas.drawCircle(
        drawPath.points.first.offset,
        drawPath.brushSize / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    path.moveTo(drawPath.points.first.offset.dx, drawPath.points.first.offset.dy);

    for (int i = 1; i < drawPath.points.length; i++) {
      final point = drawPath.points[i];
      path.lineTo(point.offset.dx, point.offset.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawBucketFill(Canvas canvas, DrawPath drawPath, Paint paint) {
    if (drawPath.points.isEmpty) return;
    
    paint.style = PaintingStyle.fill;
    final center = drawPath.points.first.offset;
    final radius = drawPath.brushSize;
    
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for smooth drawing
  }
}
