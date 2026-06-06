import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lara_demo/screens/home_screen.dart';
import 'core/lara_audio.dart';
import 'core/lara_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initSpineFlutter();
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
      home: HomeScreen(),
    );
  }
}
