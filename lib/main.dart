import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const KlasifikasiBuahApp());
}

class KlasifikasiBuahApp extends StatelessWidget {
  const KlasifikasiBuahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klasifikasi Buah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}
