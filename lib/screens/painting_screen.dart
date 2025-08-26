import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/painting_provider.dart';
import '../widgets/drawing_area.dart';
import '../widgets/tool_bar.dart';
import 'dart:async';

class PaintingScreen extends StatefulWidget {
  const PaintingScreen({super.key});

  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  Timer? _magicTimer;

  @override
  void initState() {
    super.initState();
    // Start magic color animation timer
    _magicTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final provider = Provider.of<PaintingProvider>(context, listen: false);
      provider.startMagicAnimation();
    });
  }

  @override
  void dispose() {
    _magicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Boyama Uygulaması'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          Consumer<PaintingProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  IconButton(
                    onPressed: provider.canUndo ? provider.undo : null,
                    icon: const Icon(Icons.undo),
                    tooltip: 'Geri Al',
                  ),
                  IconButton(
                    onPressed: provider.canRedo ? provider.redo : null,
                    icon: const Icon(Icons.redo),
                    tooltip: 'Yinele',
                  ),
                  IconButton(
                    onPressed: () => _showSettingsDialog(context),
                    icon: const Icon(Icons.settings),
                    tooltip: 'Ayarlar',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: const Column(
        children: [
           ToolBar(),
          Expanded(
            child: DrawingArea(),
          ),
        ],
      ),
      floatingActionButton: Consumer<PaintingProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () => _showClearDialog(context, provider),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            child: const Icon(Icons.clear_all),
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, PaintingProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tuvali Temizle'),
          content: const Text('Tüm çizimleri silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                provider.clearCanvas();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tuval temizlendi!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Temizle'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<PaintingProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              title: const Text('Ayarlar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Arka Plan Rengi'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: provider.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    onTap: () => _showColorPicker(context, provider),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tuval Boyutu:'),
                  DropdownButton<String>(
                    value: '${provider.canvasSize.width.toInt()}x${provider.canvasSize.height.toInt()}',
                    items: const [
                      DropdownMenuItem(value: '800x600', child: Text('800x600')),
                      DropdownMenuItem(value: '1024x768', child: Text('1024x768')),
                      DropdownMenuItem(value: '1200x800', child: Text('1200x800')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        final parts = value.split('x');
                        final width = double.parse(parts[0]);
                        final height = double.parse(parts[1]);
                        provider.setCanvasSize(Size(width, height));
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, PaintingProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Arka Plan Rengi Seç'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: provider.backgroundColor,
              onColorChanged: (color) {
                provider.setBackgroundColor(color);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}

class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.brown,
      Colors.grey,
    ];

    return Wrap(
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: pickerColor == color ? Colors.black : Colors.grey,
                width: pickerColor == color ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
