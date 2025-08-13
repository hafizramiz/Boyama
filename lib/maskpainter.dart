import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class MaskPainter {
  ui.Image? maskImage;
  Uint8List? maskBytes;

  /// Mask PNG yükleme
  Future<void> loadMask(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    maskImage = frameInfo.image;

    // Byte verisini RGBA formatında al
    final ByteData? byteData =
        await maskImage!.toByteData(format: ui.ImageByteFormat.rawRgba);
    maskBytes = byteData!.buffer.asUint8List();
  }


  /// Piksel boyanabilir mi kontrol et
  bool canPaintAt(double touchX, double touchY) {
    if (maskImage == null || maskBytes == null) return false;

    // Dokunma koordinatını mask koordinatına çevir
    int x = touchX.toInt();
    int y = touchY.toInt();

    // Ekran ölçeği -> Mask boyutuna göre orantı
    if (x < 0 || x >= maskImage!.width || y < 0 || y >= maskImage!.height) {
      return false;
    }

    int index = (y * maskImage!.width + x) * 4;
    int alpha = maskBytes![index + 3]; // RGBA -> A kanalı

    return alpha > 0; // alfa sıfır değilse boyanabilir
  }
}
