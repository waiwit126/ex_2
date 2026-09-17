// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ex124/screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'สมุดบันทึกคำศัพท์',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 146, 127, 127),
          foregroundColor: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}