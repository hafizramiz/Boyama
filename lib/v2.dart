import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<List<Offset>> paths = [];
  List<Color> colors = [];
  Color selectedColor = Colors.black;

  ui.Image? maskImage;
  ByteData? maskImageBytes;
  double scaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _loadMaskImage();
  }

  Future<void> _loadMaskImage() async {
    final data = await rootBundle.load('assets/images/hs_limon.png');
    final bytes = Uint8List.view(data.buffer);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    setState(() {
      maskImage = image;
      maskImageBytes = byteData;
    });
  }

  void _undo() {
    if (paths.isNotEmpty) {
      setState(() {
        paths.removeLast();
        colors.removeLast();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );

    if (pickedColor != null) {
      setState(() => selectedColor = pickedColor);
    }
  }

  bool _isDrawable(Offset localPos) {
    if (maskImage == null || maskImageBytes == null) return false;

    // Dokunma koordinatını resmin piksel koordinatına çevir
    int x = (localPos.dx * maskImage!.width / (maskImage!.width * scaleFactor)).toInt();
    int y = (localPos.dy * maskImage!.height / (maskImage!.height * scaleFactor)).toInt();

    if (x < 0 || y < 0 || x >= maskImage!.width || y >= maskImage!.height) {
      return false;
    }

    int pixelOffset = (y * maskImage!.width + x) * 4;
    int r = maskImageBytes!.getUint8(pixelOffset);
    int g = maskImageBytes!.getUint8(pixelOffset + 1);
    int b = maskImageBytes!.getUint8(pixelOffset + 2);

    // Parlaklık eşiği: 80 altı siyah/çizgi kabul edilir
    int brightness = (r + g + b) ~/ 3;
    return brightness > 80;
  }

  @override
  Widget build(BuildContext context) {
    if (maskImage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Boyama Kitabı"),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.color_lens), onPressed: _pickColor),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onPanStart: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPos = box.globalToLocal(details.globalPosition);
            if (_isDrawable(localPos)) {
              setState(() {
                paths.add([localPos]);
                colors.add(selectedColor);
              });
            }
          },
          onPanUpdate: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPos = box.globalToLocal(details.globalPosition);
            if (_isDrawable(localPos)) {
              setState(() {
                paths.last.add(localPos);
              });
            }
          },
          child: CustomPaint(
            painter: DrawingPainter(paths, colors, maskImage!),
            size: Size(maskImage!.width.toDouble(), maskImage!.height.toDouble()),
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> paths;
  final List<Color> colors;
  final ui.Image maskImage;

  DrawingPainter(this.paths, this.colors, this.maskImage);

  @override
  void paint(Canvas canvas, Size size) {
    // Önce maskeyi çiz
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: maskImage,
      fit: BoxFit.contain,
    );

    // Sonra kullanıcı çizimlerini ekle
    for (int i = 0; i < paths.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      for (int j = 0; j < paths[i].length - 1; j++) {
        canvas.drawLine(paths[i][j], paths[i][j + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
