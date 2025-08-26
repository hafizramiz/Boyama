enum DrawMode {
  pencil,
  marker,
  spray,
  sticker,
  pattern,
  magic,
  eraser,
  bucket
}

extension DrawModeExtension on DrawMode {
  String get name {
    switch (this) {
      case DrawMode.pencil:
        return 'Kalem';
      case DrawMode.marker:
        return 'İşaretleyici';
      case DrawMode.spray:
        return 'Sprey';
      case DrawMode.sticker:
        return 'Çıkartma';
      case DrawMode.pattern:
        return 'Desen';
      case DrawMode.magic:
        return 'Sihir';
      case DrawMode.eraser:
        return 'Silgi';
      case DrawMode.bucket:
        return 'Boya Kovası';
    }
  }

  String get icon {
    switch (this) {
      case DrawMode.pencil:
        return '✏️';
      case DrawMode.marker:
        return '🖍️';
      case DrawMode.spray:
        return '🎨';
      case DrawMode.sticker:
        return '🌟';
      case DrawMode.pattern:
        return '🔲';
      case DrawMode.magic:
        return '✨';
      case DrawMode.eraser:
        return '🧽';
      case DrawMode.bucket:
        return '🪣';
    }
  }
}
