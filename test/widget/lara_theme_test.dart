import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lara_demo/shared/lara_theme.dart';

void main() {
  group('LaraColors', () {
    test('magenta is #E33282', () {
      expect(LaraColors.magenta, const Color(0xFFE33282));
    });

    test('pink is #FF5CA8', () {
      expect(LaraColors.pink, const Color(0xFFFF5CA8));
    });

    test('mint is #72E0C4', () {
      expect(LaraColors.mint, const Color(0xFF72E0C4));
    });

    test('cream is #FFF6E5', () {
      expect(LaraColors.cream, const Color(0xFFFFF6E5));
    });

    test('corazonRed is #EB4058', () {
      expect(LaraColors.corazonRed, const Color(0xFFEB4058));
    });
  });

  group('LaraGradients', () {
    test('sunny has at least 2 colors', () {
      expect(LaraGradients.sunny.colors.length, greaterThanOrEqualTo(2));
    });

    test('party has at least 3 colors', () {
      expect(LaraGradients.party.colors.length, greaterThanOrEqualTo(3));
    });

    test('night contains dark blue tones', () {
      for (final c in LaraGradients.night.colors) {
        // All colors should have high blue channel relative to red
        expect(c.b, greaterThan(c.r));
      }
    });
  });

  group('LaraTextStyles', () {
    test('hudScore has fontWeight w900', () {
      expect(LaraTextStyles.hudScore.fontWeight, FontWeight.w900);
    });

    test('hudScore font size is 22', () {
      expect(LaraTextStyles.hudScore.fontSize, 22);
    });

    test('titleHuge font size is 44', () {
      expect(LaraTextStyles.titleHuge.fontSize, 44);
    });

    test('button has letterSpacing 1.0', () {
      expect(LaraTextStyles.button.letterSpacing, 1.0);
    });
  });

  group('buildLaraTheme', () {
    late ThemeData theme;

    setUp(() => theme = buildLaraTheme());

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('scaffold background is cream', () {
      expect(theme.scaffoldBackgroundColor, LaraColors.cream);
    });

    test('AppBar background is pink', () {
      expect(theme.appBarTheme.backgroundColor, LaraColors.pink);
    });

    test('AppBar foreground is white', () {
      expect(theme.appBarTheme.foregroundColor, Colors.white);
    });

    test('colorScheme is derived from pink seed', () {
      // The primary color should be in the pink/magenta family (red > green)
      final primary = theme.colorScheme.primary;
      expect(primary.r, greaterThan(primary.g));
    });
  });
}
