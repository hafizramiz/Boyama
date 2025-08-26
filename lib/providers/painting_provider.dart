import 'package:flutter/material.dart';
import '../models/draw_mode.dart';
import '../models/draw_point.dart';

class PaintingProvider extends ChangeNotifier {
  // Drawing state
  List<DrawPath> _paths = [];
  List<List<DrawPath>> _undoStack = [];
  int _redoIndex = 0;
  
  // Current drawing settings
  DrawMode _currentDrawMode = DrawMode.pencil;
  Color _currentColor = Colors.red;
  double _brushSize = 8.0;
  bool _isPainting = false;
  
  // Magic mode
  Color _magicColor = Colors.red;
  List<Color> _magicColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
  ];
  
  // Available colors
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
    Colors.black,
    Colors.white,
    Colors.brown,
    Colors.grey,
  ];
  
  // Available brush sizes
  final List<double> _availableBrushSizes = [2, 4, 8, 16, 24, 32];
  
  // Background settings
  Color _backgroundColor = Colors.white;
  Size _canvasSize = const Size(800, 600);
  
  // Getters
  List<DrawPath> get paths => _paths;
  DrawMode get currentDrawMode => _currentDrawMode;
  Color get currentColor => _currentColor;
  double get brushSize => _brushSize;
  bool get isPainting => _isPainting;
  Color get magicColor => _magicColor;
  List<Color> get availableColors => _availableColors;
  List<double> get availableBrushSizes => _availableBrushSizes;
  Color get backgroundColor => _backgroundColor;
  Size get canvasSize => _canvasSize;
  bool get canUndo => _undoStack.length - _redoIndex - 1 > 0;
  bool get canRedo => _undoStack.isNotEmpty && _redoIndex > 0;
  
  // Drawing methods
  void startPainting(Offset position) {
    _isPainting = true;
    
    // Save current state for undo
    if (_redoIndex > 0) {
      _undoStack.removeRange(_undoStack.length - _redoIndex, _undoStack.length);
      _redoIndex = 0;
    }
    
    final newPath = DrawPath(
      points: [
        DrawPoint(
          offset: position,
          color: _currentDrawMode == DrawMode.magic ? _magicColor : _currentColor,
          brushSize: _brushSize,
          timestamp: DateTime.now(),
        )
      ],
      color: _currentDrawMode == DrawMode.magic ? _magicColor : _currentColor,
      brushSize: _brushSize,
      drawMode: _currentDrawMode.name,
      createdAt: DateTime.now(),
    );
    
    _paths.add(newPath);
    notifyListeners();
  }
  
  void updatePainting(Offset position) {
    if (!_isPainting || _paths.isEmpty) return;
    
    final currentPath = _paths.last;
    final newPoint = DrawPoint(
      offset: position,
      color: _currentDrawMode == DrawMode.magic ? _magicColor : _currentColor,
      brushSize: _brushSize,
      timestamp: DateTime.now(),
    );
    
    currentPath.points.add(newPoint);
    
    // Update magic color for continuous drawing
    if (_currentDrawMode == DrawMode.magic) {
      _updateMagicColor();
    }
    
    notifyListeners();
  }
  
  void endPainting() {
    if (!_isPainting) return;
    
    _isPainting = false;
    
    // Save state for undo
    _undoStack.add(List.from(_paths));
    if (_undoStack.length > 50) { // Limit undo stack
      _undoStack.removeAt(0);
    }
    
    notifyListeners();
  }
  
  // Flood fill implementation
  void floodFill(Offset position, Size canvasSize) {
    // This would require converting the canvas to image data
    // For now, we'll add a simple filled circle
    final fillPath = DrawPath(
      points: [
        DrawPoint(
          offset: position,
          color: _currentColor,
          brushSize: _brushSize * 5, // Larger size for bucket fill
          timestamp: DateTime.now(),
        )
      ],
      color: _currentColor,
      brushSize: _brushSize * 5,
      drawMode: 'bucket_fill',
      createdAt: DateTime.now(),
    );
    
    // Save for undo
    if (_redoIndex > 0) {
      _undoStack.removeRange(_undoStack.length - _redoIndex, _undoStack.length);
      _redoIndex = 0;
    }
    
    _paths.add(fillPath);
    _undoStack.add(List.from(_paths));
    
    notifyListeners();
  }
  
  // Settings methods
  void setDrawMode(DrawMode mode) {
    _currentDrawMode = mode;
    notifyListeners();
  }
  
  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }
  
  void setBrushSize(double size) {
    _brushSize = size;
    notifyListeners();
  }
  
  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }
  
  void setCanvasSize(Size size) {
    _canvasSize = size;
    notifyListeners();
  }
  
  // Undo/Redo
  void undo() {
    if (!canUndo) return;
    
    final previousState = _undoStack[_undoStack.length - _redoIndex - 2];
    _paths = List.from(previousState);
    _redoIndex++;
    notifyListeners();
  }
  
  void redo() {
    if (!canRedo) return;
    
    final nextState = _undoStack[_undoStack.length - _redoIndex];
    _paths = List.from(nextState);
    _redoIndex--;
    notifyListeners();
  }
  
  // Clear canvas
  void clearCanvas() {
    if (_redoIndex > 0) {
      _undoStack.removeRange(_undoStack.length - _redoIndex, _undoStack.length);
      _redoIndex = 0;
    }
    
    _undoStack.add(List.from(_paths));
    _paths.clear();
    notifyListeners();
  }
  
  // Magic color animation
  void _updateMagicColor() {
    _magicColor = _magicColors[DateTime.now().millisecond % _magicColors.length];
  }
  
  void startMagicAnimation() {
    // This would be called by a timer in the UI
    _updateMagicColor();
    notifyListeners();
  }
  
  // Pattern support
  void addPattern(String patternName) {
    // Implementation for pattern drawing
    // This would load pattern textures and apply them
  }
  
  // Sticker support
  void addSticker(String stickerName, Offset position) {
    final stickerPath = DrawPath(
      points: [
        DrawPoint(
          offset: position,
          color: Colors.transparent,
          brushSize: _brushSize * 2,
          timestamp: DateTime.now(),
        )
      ],
      color: Colors.transparent,
      brushSize: _brushSize * 2,
      drawMode: 'sticker_$stickerName',
      createdAt: DateTime.now(),
    );
    
    _paths.add(stickerPath);
    _undoStack.add(List.from(_paths));
    notifyListeners();
  }
}
