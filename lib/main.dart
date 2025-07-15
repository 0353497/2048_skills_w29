import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_modern_edition_2048/homepage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp
      ]
    );
    return const MaterialApp(
      home: Homepage()
    );
  }
}
