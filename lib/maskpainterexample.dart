import 'package:flutter/material.dart';
import 'package:untitled2/maskpainter.dart';


void main() {
  runApp(const Maskpainterexample());
}



class Maskpainterexample extends StatefulWidget {
  const Maskpainterexample({super.key});

  @override
  State<Maskpainterexample> createState() => _MaskpainterexampleState();
}

class _MaskpainterexampleState extends State<Maskpainterexample> {



  final maskPainter = MaskPainter();

@override
void initState() {
  super.initState();
  maskPainter.loadMask('assets/images/hs_limon.png');
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(


onDoubleTap: () {
    print("Double tapped");
  },
  onTap: () {
    print("Tapped");
  },
  onLongPress: () {
    print("Long pressed");
  },
  onPanStart: (details) {
    if (maskPainter.canPaintAt(details.localPosition.dx, details.localPosition.dy)) {
      print( "Paintable at ${details.localPosition}");
      // Burada CustomPainter ile fırça çiz
    }
    print("Not paintable at ${details.localPosition}");
  },
  onPanEnd: (details) {
},

onDoubleTapDown: (details){
    if (maskPainter.canPaintAt(details.localPosition.dx, details.localPosition.dy)) {
      print( "Paintable at ${details.localPosition}");
      // Burada CustomPainter ile fırça çiz
    }
    print("Not paintable at ${details.localPosition}");
  },


  onPanUpdate: (details) {
    if (maskPainter.canPaintAt(details.localPosition.dx, details.localPosition.dy)) {
      print( "Paintable at ${details.localPosition}");
      // Burada CustomPainter ile fırça çiz
    }
    print("Not paintable at ${details.localPosition}");
  },
  child: maskPainter.maskImage == null
      ? const CircularProgressIndicator()
      : Container(
          height: 300,
          color: Colors.white,
          child: RawImage(
      image: maskPainter.maskImage,
      fit: BoxFit.contain,
      width: 100,
    ),
  )
  
);
  }
}