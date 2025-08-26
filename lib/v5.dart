import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PaintingApp());
}

class PaintingApp extends StatelessWidget {
  const PaintingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PNG Masked Painting – Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PaintingScreen(
        // Change these to your asset paths
        maskAsset: 'assets/images/hs_limon.png',
        // Transparent background, white shape to paint
        lineAsset:
            'assets/images/hs_limon.png', // Line art (black lines on transparent bg)
      ),
    );
  }
}

class PaintingScreen extends StatefulWidget {
  final String maskAsset;
  final String lineAsset;

  const PaintingScreen({
    super.key,
    required this.maskAsset,
    required this.lineAsset,
  });

  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  ui.Image? _maskImage;
  ui.Image? _lineImage;

  final List<Stroke> _strokes = [];
  Stroke? _current;

  double _brushSize = 24;
  Color _brushColor = Colors.red;

  // Holds the last paintable rect; used for hit testing and sizing
  Rect? _imageRect;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mask = await _loadUiImage(widget.maskAsset);
    final line = await _loadUiImage(widget.lineAsset);
    setState(() {
      _maskImage = mask;
      _lineImage = line;
    });
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _onPanStart(DragStartDetails d) {
    if (_maskImage == null) return;
    final localPos = _globalToImageOffset(d.localPosition);
    if (localPos == null) return; // outside image bounds
    _current = Stroke(color: _brushColor, width: _brushSize)
      ..points.add(localPos);
    setState(() => _strokes.add(_current!));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_current == null) return;
    final localPos = _globalToImageOffset(d.localPosition);
    if (localPos == null) return;
    setState(() => _current!.points.add(localPos));
  }

  void _onPanEnd(DragEndDetails d) {
    _current = null;
  }

  Offset? _globalToImageOffset(Offset local) {
    // Convert from widget space to image space using _imageRect
    final rect = _imageRect;
    final img = _maskImage;
    if (rect == null || img == null) return null;
    if (!rect.contains(local))
      return null; // outside the drawn image area entirely
    final dx = (local.dx - rect.left) / rect.width * img.width;
    final dy = (local.dy - rect.top) / rect.height * img.height;
    return Offset(dx, dy);
  }

  void _undo() {
    if (_strokes.isNotEmpty) setState(() => _strokes.removeLast());
  }

  void _clear() {
    setState(() => _strokes.clear());
  }

  @override
  Widget build(BuildContext context) {
    final mask = _maskImage;
    final line = _lineImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PNG Masked Painting (Freehand)'),
        actions: [
          IconButton(
            onPressed: _undo,
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: _clear,
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: (mask == null || line == null)
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Fit the image into available space while keeping aspect ratio
                final imgW = mask.width.toDouble();
                final imgH = mask.height.toDouble();
                final maxW = constraints.maxWidth;
                final maxH =
                    constraints.maxHeight - 120; // leave room for tools
                final scale = _fitContain(imgW, imgH, maxW, maxH);
                final drawW = imgW * scale;
                final drawH = imgH * scale;
                final left = (maxW - drawW) / 2;
                final top = (maxH - drawH) / 2;
                final rect = Rect.fromLTWH(left, top, drawW, drawH);
                _imageRect = rect; // cache for pointer mapping

                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Checkerboard background to show transparency
                          CustomPaint(painter: CheckerboardPainter()),

                          // Painting + mask + line art
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: ExcludeSemantics(
                              child: CustomPaint(
                                painter: PaintingPainter(
                                  strokes: _strokes,
                                  mask: mask,
                                  line: line,
                                  imageRect: rect,
                                ),
                                child:
                                    const SizedBox.expand(), // 👈 boş child ekle
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Toolbar(
                      brushSize: _brushSize,
                      onSizeChanged: (v) => setState(() => _brushSize = v),
                      brushColor: _brushColor,
                      onColorChanged: (c) => setState(() => _brushColor = c),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }

  double _fitContain(double w, double h, double maxW, double maxH) {
    final scaleW = maxW / w;
    final scaleH = maxH / h;
    return scaleW < scaleH ? scaleW : scaleH;
  }
}

class Stroke {
  final List<Offset> points = [];
  final Color color;
  final double width;

  Stroke({required this.color, required this.width});
}

class PaintingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final ui.Image mask; // the alpha of this image defines paintable area
  final ui.Image line; // line art drawn on top
  final Rect imageRect; // where the image is placed on the screen

  PaintingPainter({
    required this.strokes,
    required this.mask,
    required this.line,
    required this.imageRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw everything relative to imageRect: we scale the canvas so image pixels map 1:1
    canvas.save();
    // Translate to imageRect origin and scale to match image logical pixels
    canvas.translate(imageRect.left, imageRect.top);
    final sx = imageRect.width / mask.width;
    final sy = imageRect.height / mask.height;
    canvas.scale(sx, sy);

    // 1) Paint strokes into a layer
    final paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final recordingLayer = Paint();
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
      recordingLayer,
    );

    for (final s in strokes) {
      paint
        ..color = s.color
        ..strokeWidth = s.width;
      for (int i = 0; i < s.points.length - 1; i++) {
        final p1 = s.points[i];
        final p2 = s.points[i + 1];
        canvas.drawLine(p1, p2, paint);
      }
      if (s.points.length == 1) {
        // dot
        canvas.drawCircle(
          s.points.first,
          s.width / 2,
          Paint()..color = s.color,
        );
      }
    }

    // 2) Apply mask using srcIn: keep only pixels where mask alpha > 0
    final maskPaint = Paint()..blendMode = BlendMode.srcIn;
    canvas.drawImage(mask, Offset.zero, maskPaint);

    // 3) Merge layer
    canvas.restore();

    // 4) Draw line art on top so strokes appear "under" the outlines
    canvas.drawImage(line, Offset.zero, Paint());

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PaintingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.mask != mask ||
        oldDelegate.line != line ||
        oldDelegate.imageRect != imageRect;
  }
}

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 16.0;
    final light = Paint()..color = const Color(0xFFEFEFEF);
    final dark = Paint()..color = const Color(0xFFD0D0D0);
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final isDark = (((x / cell).floor() + (y / cell).floor()) % 2) == 0;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), isDark ? dark : light);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Toolbar extends StatelessWidget {
  final double brushSize;
  final ValueChanged<double> onSizeChanged;
  final Color brushColor;
  final ValueChanged<Color> onColorChanged;

  const _Toolbar({
    required this.brushSize,
    required this.onSizeChanged,
    required this.brushColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.black,
      Colors.white,
    ];

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Text('Brush'),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                min: 2,
                max: 64,
                value: brushSize,
                onChanged: onSizeChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final c = colors[i];
                  final selected = c == brushColor;
                  return GestureDetector(
                    onTap: () => onColorChanged(c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.black12,
                          width: selected ? 2 : 1,
                        ),
                        color: c,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: colors.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
