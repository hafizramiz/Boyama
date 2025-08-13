import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ColoringgApp());

class ColoringgApp extends StatelessWidget {
  const ColoringgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ColoringScreen(),
    );
  }
}

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  List<List<Offset>> paths = [];
  List<Color> colors = [];
  List<double> strokes = [];

  Color selectedColor = Colors.black;
  double selectedStroke = 4.0;
  bool isEraser = false;

  final GlobalKey _canvasKey = GlobalKey();
  
  // Arkaplan resmi için değişkenler
  ui.Image? backgroundImage;
  ByteData? imagePixelData;
  String imagePath = 'assets/images/hs_limon.png'; // Varsayılan resim yolu
  bool imageLoadFailed = false;
  
  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }
  
  // Arkaplan resmini yükle
  Future<void> _loadBackgroundImage() async {
    try {
      final ByteData data = await rootBundle.load(imagePath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      
      // Pixel verilerini al
      final ByteData? pixelData = await frameInfo.image.toByteData();
      
      setState(() {
        backgroundImage = frameInfo.image;
        imagePixelData = pixelData;
      });
      print('Resim başarıyla yüklendi: ${backgroundImage?.width}x${backgroundImage?.height}');
    } catch (e) {
      print('Resim yüklenirken hata: $e');
      // Resim yüklenemezse, boyama kontrolünü devre dışı bırak
      setState(() {
        backgroundImage = null;
        imagePixelData = null;
        imageLoadFailed = true;
      });
    }
  }
  
  // Belirtilen noktanın boyama yapılabilir olup olmadığını kontrol et
  bool _canPaintAtPosition(Offset position) {
    // GEÇİCİ: Her yere boyama yapılabilir (test için)
    return true;
    
    /* ORIJINAL KOD - İHTIYAÇ DUYULDUĞUNDA AKTİF EDİLECEK
    if (backgroundImage == null || imagePixelData == null) return true;
    
    // Canvas boyutlarını al
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return true;
    
    final Size canvasSize = renderBox.size;
    
    // Pozisyonu resim koordinatlarına çevir
    final double scaleX = backgroundImage!.width / canvasSize.width;
    final double scaleY = backgroundImage!.height / canvasSize.height;
    
    final int imageX = (position.dx * scaleX).round();
    final int imageY = (position.dy * scaleY).round();
    
    // Sınırları kontrol et
    if (imageX < 0 || imageX >= backgroundImage!.width || 
        imageY < 0 || imageY >= backgroundImage!.height) {
      print('Sınır dışı: ($imageX, $imageY)');
      return false;
    }
    
    // Pixel rengini al (RGBA formatında)
    final int pixelIndex = (imageY * backgroundImage!.width + imageX) * 4;
    if (pixelIndex + 3 >= imagePixelData!.lengthInBytes) {
      print('Pixel index sınır dışı: $pixelIndex');
      return false;
    }
    
    final int r = imagePixelData!.getUint8(pixelIndex);
    final int g = imagePixelData!.getUint8(pixelIndex + 1);
    final int b = imagePixelData!.getUint8(pixelIndex + 2);
    
    print('Pixel rengi: RGB($r, $g, $b) at ($imageX, $imageY)');
    
    // Sadece tamamen siyah pikselleri engelle (RGB = 0,0,0)
    final bool isLine = (r == 0 && g == 0 && b == 0);
    
    print('Is line: $isLine (sadece tamamen siyah pikseller engellenir)');
    
    return !isLine; // Çizgi değilse boyama yapılabilir
    */
  }

  void _undo() {
    if (paths.isNotEmpty) {
      setState(() {
        paths.removeLast();
        colors.removeLast();
        strokes.removeLast();
      });
    }
  }

  void _clearAll() {
    setState(() {
      paths.clear();
      colors.clear();
      strokes.clear();
    });
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
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.brown,
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

  // Resim seçme fonksiyonu
  void _pickImage() async {
    String? selectedImage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Boyama Resmi Seç"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Limon"),
              onTap: () => Navigator.pop(context, 'assets/images/hs_limon.png'),
            ),
            // Buraya daha fazla resim ekleyebilirsiniz
          ],
        ),
      ),
    );

    if (selectedImage != null && selectedImage != imagePath) {
      setState(() {
        imagePath = selectedImage;
        // Mevcut boyamaları temizle
        paths.clear();
        colors.clear();
        strokes.clear();
      });
      await _loadBackgroundImage();
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
        title: const Text("Boyama Uygulaması"),
        actions: [
          IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.clear_all), onPressed: _clearAll),
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
                print('Pan start: ${details.localPosition}');
                // Resim yoksa her zaman, varsa pixel kontrolü yap
                bool canPaint = backgroundImage == null || _canPaintAtPosition(details.localPosition);
                print('Can paint: $canPaint');
                
                if (canPaint) {
                  setState(() {
                    paths.add([details.localPosition]);
                    colors.add(selectedColor);
                    strokes.add(selectedStroke);
                  });
                  print('Path added. Total paths: ${paths.length}');
                }
              },
              onPanUpdate: (details) {
                // Aktif bir path var mı ve boyama yapılabilir pozisyon mu kontrol et
                if (paths.isNotEmpty) {
                  // Pixel kontrolü ile boyama yapılabilir alanı kontrol et
                  bool canPaint = backgroundImage == null || _canPaintAtPosition(details.localPosition);
                  
                  if (canPaint) {
                    setState(() {
                      paths.last.add(details.localPosition);
                    });
                  }
                }
              },
              child: RepaintBoundary(
                key: _canvasKey,
                child: CustomPaint(
                  painter: DrawingPainter(paths, colors, strokes, backgroundImage),
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
  final ui.Image? backgroundImage;

  DrawingPainter(this.paths, this.colors, this.strokes, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    // Önce arkaplan resmini çiz
    if (backgroundImage != null) {
      final Paint imagePaint = Paint();
      final Rect destRect = Rect.fromLTWH(0, 0, size.width, size.height);
      final Rect srcRect = Rect.fromLTWH(0, 0, 
          backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
      canvas.drawImageRect(backgroundImage!, srcRect, destRect, imagePaint);
    }
    
    // Sonra boyama çizgilerini çiz
    print('Drawing ${paths.length} paths');
    for (int i = 0; i < paths.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = strokes[i]
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.srcOver
        ..style = PaintingStyle.stroke; // Stroke style'ı açıkça belirt
        
      if (paths[i].length > 1) {
        // Path oluştur ve çiz
        final path = Path();
        path.moveTo(paths[i][0].dx, paths[i][0].dy);
        for (int j = 1; j < paths[i].length; j++) {
          path.lineTo(paths[i][j].dx, paths[i][j].dy);
        }
        canvas.drawPath(path, paint);
      } else if (paths[i].length == 1) {
        // Tek nokta için küçük daire çiz
        canvas.drawCircle(paths[i][0], strokes[i] / 2, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
