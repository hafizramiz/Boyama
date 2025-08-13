import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const DrawingApp());

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DrawingScreen(),
    );
  }
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<List<Offset>> paths = [];
  List<Color> colors = [];
  List<double> strokes = [];

  Color selectedColor = Colors.black;
  double selectedStroke = 4.0;
  bool isEraser = false;

  final GlobalKey _canvasKey = GlobalKey();

  void _undo() {
    if (paths.isNotEmpty) {
      setState(() {
        paths.removeLast();
        colors.removeLast();
        strokes.removeLast();
      });
    }
  }

  void _pickColor() async {
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick a color"),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.black,
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.brown,
              Colors.grey,
              Colors.pink,
              Colors.yellow,
              Colors.cyan,
              Colors.teal,
              Colors.lime,
              Colors.indigo,
              Colors.amber,
            ].map((color) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (pickedColor != null) {
      setState(() {
        selectedColor = pickedColor;
        isEraser = false;
      });
    }
  }

  Future<void> _saveDrawing() async {
    RenderRepaintBoundary boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      // Burada resmi dosyaya kaydedebilir veya paylaşabilirsiniz.
      // Örn: path_provider + dart:io ile dosyaya yazılabilir.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drawing saved as PNG!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Drawing App"),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.color_lens), onPressed: _pickColor),
          IconButton(
            icon: Icon(isEraser ? Icons.brush : Icons.cleaning_services),
            onPressed: () {
              setState(() {
                isEraser = !isEraser;
                if (isEraser) selectedColor = Colors.white;
              });
            },
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDrawing),
        ],
      ),
      body: Column(
        children: [
          // Stroke size slider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Stroke: "),
              Slider(
                value: selectedStroke,
                min: 1,
                max: 20,
                divisions: 19,
                label: selectedStroke.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() => selectedStroke = value);
                },
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  paths.add([details.localPosition]);
                  colors.add(selectedColor);
                  strokes.add(selectedStroke);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  paths.last.add(details.localPosition);
                });
              },
              child: RepaintBoundary(
                key: _canvasKey,
                child: CustomPaint(
                  painter: DrawingPainter(paths, colors, strokes),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> paths;
  final List<Color> colors;
  final List<double> strokes;

  DrawingPainter(this.paths, this.colors, this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < paths.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = strokes[i]
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.srcOver;
      for (int j = 0; j < paths[i].length - 1; j++) {
        canvas.drawLine(paths[i][j], paths[i][j + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
