# Flutter Boyama Uygulaması

Unity C# kodundan esinlenerek geliştirilen kapsamlı bir Flutter boyama uygulaması.

## 🎨 Özellikler

### Ana Çizim Modları
- **Kalem** ✏️ - Klasik çizim
- **İşaretleyici** 🖍️ - Yarı şeffaf boyama
- **Sprey** 🎨 - Parçacık efektli boyama
- **Çıkartma** 🌟 - Önceden tanımlanmış şekiller
- **Desen** 🔲 - Tekrarlayan desenler
- **Sihir** ✨ - Renkli animasyonlu çizim
- **Silgi** 🧽 - Çizimleri silme
- **Boya Kovası** 🪣 - Alan doldurma

### Kullanıcı Arayüzü
- **Renk Paleti**: 12 farklı renk seçeneği
- **Fırça Boyutları**: 6 farklı boyut (2px - 32px)
- **Geri Al/Yinele**: Sınırsız undo/redo sistemi
- **Temizle**: Tuvali tamamen temizleme
- **Ayarlar**: Arka plan rengi ve tuval boyutu ayarları

### Gelişmiş Özellikler
- **Gerçek Zamanlı Çizim**: Akıcı çizim deneyimi
- **Animasyonlu Sihir Modu**: Sürekli değişen renkler
- **Optimized Performance**: Sadece gerektiğinde texture güncellemesi
- **Responsive UI**: Tüm ekran boyutlarında uyumlu

## 🛠️ Teknik Detaylar

### Kullanılan Teknolojiler
- **Flutter**: Ana framework
- **Provider**: State management
- **CustomPainter**: Çizim motoru
- **GestureDetector**: Touch/mouse input handling

### Proje Yapısı
```
lib/
├── main.dart                 # Ana uygulama
├── models/                   # Veri modelleri
│   ├── draw_mode.dart       # Çizim modları enum
│   └── draw_point.dart      # Çizim noktaları
├── providers/               # State management
│   └── painting_provider.dart
├── screens/                 # Ekranlar
│   └── painting_screen.dart
├── widgets/                 # UI bileşenleri
│   ├── drawing_area.dart
│   ├── painting_canvas.dart
│   └── tool_bar.dart
└── services/               # Servisler
    └── flood_fill_service.dart
```

### Ana Sınıflar

#### PaintingProvider
Unity'deki `ColoringBookManager` sınıfının Flutter karşılığı. Tüm çizim state'ini ve business logic'ini yönetir.

**Temel Özellikler:**
- Çizim modları yönetimi
- Renk ve fırça boyutu kontrolü
- Undo/Redo sistemi
- Magic mode animasyonu

#### PaintingCanvas (CustomPainter)
Unity'deki çizim fonksiyonlarının Flutter karşılığı. Her çizim modunu özel algoritmalarla render eder.

**Çizim Algoritmaları:**
- **Pencil**: Standart çizgi çizimi
- **Marker**: Yarı şeffaf daireler
- **Spray**: Rastgele parçacık efekti
- **Magic**: Rainbow renk gradyanı + parıltı efekti
- **Eraser**: BlendMode.clear kullanımı

#### DrawingArea
Unity'deki input handling sisteminin Flutter karşılığı. GestureDetector ile touch/mouse olaylarını yakalar.

## 🎯 Unity'den Flutter'a Dönüşüm

### Unity C# → Flutter Dart Karşılıkları

| Unity C# | Flutter Dart |
|----------|--------------|
| `byte[] pixels` | `List<DrawPath> paths` |
| `Texture2D.LoadRawTextureData()` | `CustomPainter.paint()` |
| `Input.GetMouseButton()` | `GestureDetector.onPan*` |
| `Material.SetTexture()` | `CustomPaint widget` |
| `Queue<int> fillPointX` | `List<Offset> points` |
| `CompareThreshold()` | `Color comparison logic` |

### Performans Optimizasyonları

1. **Lazy Texture Updates**: Unity'deki `textureNeedsUpdate` flag'ine benzer şekilde, sadece gerektiğinde repaint
2. **Path Batching**: Birden fazla çizim noktasını tek path'te birleştirme
3. **Memory Management**: Undo stack boyut sınırlaması
4. **Efficient Rendering**: CustomPainter kullanarak doğrudan canvas'a çizim

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.8.1+
- Dart 3.0+

### Kurulum
```bash
# Dependencies'leri yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

### Build
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# Web
flutter build web --release
```

## 🎮 Kullanım

1. **Çizim Modu Seçin**: Toolbar'da istediğiniz çizim moduna tıklayın
2. **Renk Seçin**: Renk paletinden istediğiniz rengi seçin
3. **Fırça Boyutunu Ayarlayın**: Boyut seçeneklerinden birini seçin
4. **Çizim Yapın**: Tuval üzerinde parmağınızla veya mouse ile çizin
5. **Geri Al/Yinele**: Hata durumunda üst bar'daki butonları kullanın

### Özel Modlar

#### Sihir Modu ✨
- Sürekli değişen renklerle çizim
- Parıltı efekti
- 100ms aralıklarla renk değişimi

#### Sprey Modu 🎨
- Rastgele parçacık efekti
- Fırça boyutuna göre parçacık yoğunluğu
- Doğal sprey görünümü

#### Boya Kovası 🪣
- Geniş alan doldurma (şu an basit daire)
- Gelecekte gerçek flood fill algoritması

## 🔧 Gelecek Özellikler

- [ ] Gerçek flood fill algoritması
- [ ] Sticker ve pattern desteği
- [ ] Görüntü kaydetme/yükleme
- [ ] Çoklu katman desteği
- [ ] Özel fırça şekilleri
- [ ] Ses efektleri
- [ ] Tema desteği

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🙏 Teşekkürler

Bu proje Unity C# boyama uygulamasından esinlenerek geliştirilmiştir. Orijinal algoritma ve yaklaşımlar Flutter'a uyarlanmıştır.
# Boyama
