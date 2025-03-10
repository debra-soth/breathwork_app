import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(BreathworkApp());
}

class BreathworkApp extends StatelessWidget {
  const BreathworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
    );
  }
}
