import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaskBasedPaintingService {
  static ui.Image? _maskImage;
  static Uint8List? _maskPixels;
  static Set<int>? _lockMask;
  static int _imageWidth = 0;
  static int _imageHeight = 0;

  // Mask image'ı yükle (hs_limon.png)
  static Future<void> loadMaskImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      _maskImage = frameInfo.image;
      
      _imageWidth = _maskImage!.width;
      _imageHeight = _maskImage!.height;
      
      // Mask pixel verilerini oku
      await _readMaskPixels();
      
      debugPrint('Mask image loaded: ${_imageWidth}x${_imageHeight}');
    } catch (e) {
      debugPrint('Error loading mask image: $e');
    }
  }

  // Mask pixel verilerini oku
  static Future<void> _readMaskPixels() async {
    if (_maskImage == null) return;

    final ByteData? data = await _maskImage!.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data != null) {
      _maskPixels = data.buffer.asUint8List();
      debugPrint('Mask pixels loaded: ${_maskPixels!.length} bytes');
    }
  }

  // Belirli bir pozisyonda boyama izni var mı kontrol et
  static bool canPaintAt(Offset position, Size canvasSize) {
    if (_maskPixels == null || _lockMask == null) return true;
    
    // Canvas koordinatlarını image koordinatlarına dönüştür
    final int x = ((position.dx / canvasSize.width) * _imageWidth).round().clamp(0, _imageWidth - 1);
    final int y = ((position.dy / canvasSize.height) * _imageHeight).round().clamp(0, _imageHeight - 1);
    
    final int pixelIndex = (y * _imageWidth + x);
    return _lockMask!.contains(pixelIndex);
  }

  // Lock area oluştur (tıklanan noktadaki benzer renkli alanı belirle)
  static Future<void> createLockArea(Offset position, Size canvasSize) async {
    if (_maskPixels == null) return;
    
    // Canvas koordinatlarını image koordinatlarına dönüştür
    final int startX = ((position.dx / canvasSize.width) * _imageWidth).round().clamp(0, _imageWidth - 1);
    final int startY = ((position.dy / canvasSize.height) * _imageHeight).round().clamp(0, _imageHeight - 1);
    
    // Tıklanan noktadaki rengi al
    final int pixelIndex = (startY * _imageWidth + startX) * 4;
    final int targetR = _maskPixels![pixelIndex];
    final int targetG = _maskPixels![pixelIndex + 1];
    final int targetB = _maskPixels![pixelIndex + 2];
    final int targetA = _maskPixels![pixelIndex + 3];
    
    // Siyah çizgileri koruma kontrolü
    if (_isBlackLine(targetR, targetG, targetB)) {
      debugPrint('Black line detected, no painting allowed');
      _lockMask = <int>{};
      return;
    }
    
    // Flood fill ile benzer renkli alanı bul
    _lockMask = await _floodFillLockArea(startX, startY, targetR, targetG, targetB, targetA);
    
    debugPrint('Lock area created with ${_lockMask!.length} pixels');
  }

  // Siyah çizgi kontrolü
  static bool _isBlackLine(int r, int g, int b) {
    // Siyah veya çok koyu renkler için threshold
    const int blackThreshold = 50;
    return r < blackThreshold && g < blackThreshold && b < blackThreshold;
  }

  // Flood fill ile lock area oluştur
  static Future<Set<int>> _floodFillLockArea(int startX, int startY, int targetR, int targetG, int targetB, int targetA) async {
    final Set<int> lockArea = <int>{};
    final List<Point<int>> queue = [Point(startX, startY)];
    final Set<Point<int>> visited = <Point<int>>{};
    
    while (queue.isNotEmpty) {
      final Point<int> current = queue.removeAt(0);
      final int x = current.x;
      final int y = current.y;
      
      // Sınır kontrolü
      if (x < 0 || x >= _imageWidth || y < 0 || y >= _imageHeight) continue;
      if (visited.contains(current)) continue;
      
      // Pixel rengini kontrol et
      final int pixelIndex = (y * _imageWidth + x) * 4;
      final int currentR = _maskPixels![pixelIndex];
      final int currentG = _maskPixels![pixelIndex + 1];
      final int currentB = _maskPixels![pixelIndex + 2];
      final int currentA = _maskPixels![pixelIndex + 3];
      
      // Renk benzerlik kontrolü
      if (!_colorsMatch(currentR, currentG, currentB, currentA, targetR, targetG, targetB, targetA)) {
        continue;
      }
      
      // Siyah çizgi kontrolü
      if (_isBlackLine(currentR, currentG, currentB)) {
        continue;
      }
      
      visited.add(current);
      lockArea.add(y * _imageWidth + x);
      
      // Komşu pixelleri kuyruğa ekle
      queue.add(Point(x + 1, y)); // sağ
      queue.add(Point(x - 1, y)); // sol  
      queue.add(Point(x, y + 1)); // aşağı
      queue.add(Point(x, y - 1)); // yukarı
    }
    
    return lockArea;
  }

  // Renk benzerlik kontrolü (threshold ile)
  static bool _colorsMatch(int r1, int g1, int b1, int a1, int r2, int g2, int b2, int a2) {
    const int threshold = 30; // Renk toleransı
    
    return (r1 - r2).abs() <= threshold &&
           (g1 - g2).abs() <= threshold &&
           (b1 - b2).abs() <= threshold &&
           (a1 - a2).abs() <= threshold;
  }

  // Mask image'ı canvas'a çiz (debug için)
  static void drawMaskImage(Canvas canvas, Size size) {
    if (_maskImage == null) return;
    
    final Paint paint = Paint()..filterQuality = FilterQuality.low;
    canvas.drawImageRect(
      _maskImage!,
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  // Resources'ları temizle
  static void dispose() {
    _maskImage?.dispose();
    _maskImage = null;
    _maskPixels = null;
    _lockMask = null;
  }

  // Getter'lar
  static bool get hasMaskImage => _maskImage != null;
  static Size get maskImageSize => Size(_imageWidth.toDouble(), _imageHeight.toDouble());
  static bool get hasLockArea => _lockMask != null && _lockMask!.isNotEmpty;
}

class Point<T> {
  final T x;
  final T y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point<T> && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
