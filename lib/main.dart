import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'shared/lara_theme.dart';

void main() {
  runApp(const LaraDemoApp());
}

class LaraDemoApp extends StatelessWidget {
  const LaraDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lara Campos — Amigos Games',
      debugShowCheckedModeBanner: false,
      theme: buildLaraTheme(),
      home: const HomeScreen(),
    );
  }
}
