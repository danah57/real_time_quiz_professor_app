import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/prof_home.dart';
import 'screens/prof_home.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Professor Quiz App',
      home: const ProfessorHome(),
    );
  }
}
