import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/painting_provider.dart';
import 'screens/painting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PaintingProvider(),
      child: MaterialApp(
        title: 'Flutter Boyama Uygulaması',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const PaintingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
