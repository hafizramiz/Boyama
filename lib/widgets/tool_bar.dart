import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/painting_provider.dart';
import '../models/draw_mode.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaintingProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Draw modes
              Expanded(
                flex: 3,
                child: _buildDrawModes(context, provider),
              ),
              
              const VerticalDivider(),
              
              // Colors
              Expanded(
                flex: 2,
                child: _buildColorPalette(context, provider),
              ),
              
              const VerticalDivider(),
              
              // Brush sizes
              Expanded(
                flex: 1,
                child: _buildBrushSizes(context, provider),
              ),
              
              const VerticalDivider(),
              
              // Mask Controls
              Expanded(
                flex: 1,
                child: _buildMaskControls(context, provider),
              ),
              
              const VerticalDivider(),
              
              // Actions
              // Expanded(
              //   flex: 1,
              //   child: _buildActions(context, provider),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawModes(BuildContext context, PaintingProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DrawMode.values.map((mode) {
          final isSelected = provider.currentDrawMode == mode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => provider.setDrawMode(mode),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mode.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      mode.name,
                      style: TextStyle(
                        fontSize: 8,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context, PaintingProvider provider) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: provider.availableColors.length,
      itemBuilder: (context, index) {
        final color = provider.availableColors[index];
        final isSelected = provider.currentColor == color;
        
        return GestureDetector(
          onTap: () => provider.setColor(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrushSizes(BuildContext context, PaintingProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.availableBrushSizes.map((size) {
          final isSelected = provider.brushSize == size;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => provider.setBrushSize(size),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: size / 2,
                    height: size / 2,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaskControls(BuildContext context, PaintingProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: provider.maskEnabled ? Colors.green : Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: provider.maskEnabled ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: () {
              if (provider.maskEnabled) {
                provider.disableMaskPainting();
              } else {
                provider.enableMaskPainting('assets/images/hs_araba.png');
              }
            },
            icon: Icon(
              Icons.image_outlined,
              color: provider.maskEnabled ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            tooltip: provider.maskEnabled ? 'Mask Kapat' : 'Mask Aç',
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Mask',
          style: TextStyle(
            fontSize: 7,
            color: provider.maskEnabled ? Colors.green : Colors.grey[600],
            fontWeight: provider.maskEnabled ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, PaintingProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: provider.canUndo ? provider.undo : null,
              icon: const Icon(Icons.undo, size: 16),
              tooltip: 'Geri Al',
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            IconButton(
              onPressed: provider.canRedo ? provider.redo : null,
              icon: const Icon(Icons.redo, size: 16),
              tooltip: 'Yinele',
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => _showClearDialog(context, provider),
              icon: const Icon(Icons.clear, size: 16),
              tooltip: 'Temizle',
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            IconButton(
              onPressed: () => _saveImage(context, provider),
              icon: const Icon(Icons.save, size: 16),
              tooltip: 'Kaydet',
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ],
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
              },
              child: const Text('Temizle'),
            ),
          ],
        );
      },
    );
  }

  void _saveImage(BuildContext context, PaintingProvider provider) {
    // Implementation for saving image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Görüntü kaydedildi!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
