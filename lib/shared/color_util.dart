import 'dart:ui';

import 'package:flutter/material.dart';

class ColorUtil {
  static Color darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
  }
}
