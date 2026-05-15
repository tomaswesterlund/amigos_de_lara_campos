import 'package:flutter/material.dart';

class LaraColors {
  static const pink = Color(0xFFFF5CA8);
  static const magenta = Color(0xFFE33282);
  static const mint = Color(0xFF72E0C4);
  static const yellow = Color(0xFFFFD640);
  static const sky = Color(0xFFB8E5FF);
  static const rhenneGreen = Color(0xFF6EC85A);
  static const rhenneGreenDark = Color(0xFF4C9C40);
  static const galletaBrown = Color(0xFFBE824E);
  static const corazonRed = Color(0xFFEB4058);
  static const cream = Color(0xFFFFF6E5);
  static const ink = Color(0xFF1E1E28);
}

class LaraGradients {
  static const sunny = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [LaraColors.yellow, LaraColors.pink],
  );

  static const pond = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [LaraColors.sky, LaraColors.mint],
  );

  static const party = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LaraColors.pink, LaraColors.yellow, LaraColors.mint],
  );
}

class LaraTextStyles {
  static const titleHuge = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 1.2,
    shadows: [
      Shadow(offset: Offset(0, 3), blurRadius: 0, color: LaraColors.magenta),
    ],
  );

  static const titleCard = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const tagline = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white70,
  );

  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 1.0,
  );

  static const hudScore = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    shadows: [
      Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black54),
    ],
  );
}

ThemeData buildLaraTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: LaraColors.pink,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: LaraColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: LaraColors.pink,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1.0,
      ),
    ),
  );
}
