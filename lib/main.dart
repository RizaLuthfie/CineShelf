import 'package:flutter/material.dart';

void main() {
  runApp(const CineShelfApp());
}

class CineShelfApp extends StatelessWidget {
  const CineShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineShelf',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CineShelf')),
      body: const Center(child: Text('Selamat datang di CineShelf')),
    );
  }
}