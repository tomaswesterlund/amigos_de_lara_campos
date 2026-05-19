import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'shared/lara_audio.dart';
import 'shared/lara_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LaraAudio.init();
  runApp(const AmigosDeLaraApp());
}

class AmigosDeLaraApp extends StatelessWidget {
  const AmigosDeLaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amigos de Lara!',
      debugShowCheckedModeBanner: false,
      theme: buildLaraTheme(),
      home: const HomeScreen(),
    );
  }
}
