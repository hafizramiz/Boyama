import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/painting_provider.dart';
import '../widgets/painting_canvas.dart';
import '../models/draw_mode.dart';

class DrawingArea extends StatefulWidget {
  const DrawingArea({super.key});

  @override
  State<DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaintingProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: provider.backgroundColor,
            border: Border.all(color: Colors.grey),
          ),
          child: GestureDetector(
            onPanStart: (details) {
              final renderBox = context.findRenderObject() as RenderBox;
              final localPosition = renderBox.globalToLocal(details.globalPosition);
              
              if (provider.currentDrawMode == DrawMode.bucket) {
                provider.floodFill(localPosition, renderBox.size);
              } else {
                provider.startPainting(localPosition);
              }
            },
            onPanUpdate: (details) {
              if (provider.currentDrawMode == DrawMode.bucket) return;
              
              final renderBox = context.findRenderObject() as RenderBox;
              final localPosition = renderBox.globalToLocal(details.globalPosition);
              provider.updatePainting(localPosition);
            },
            onPanEnd: (details) {
              if (provider.currentDrawMode == DrawMode.bucket) return;
              provider.endPainting();
            },
            child: CustomPaint(
              painter: PaintingCanvas(
                paths: provider.paths,
                backgroundColor: provider.backgroundColor,
                canvasSize: provider.canvasSize,
                showMaskImage: provider.maskEnabled,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}
