import 'dart:ui';

class Theme {
  static const Color background = Color(0xFFF7F7F7);
  static const Color primary = Color(0xFF4E38B2);
  static const Color white = Color(0xFFFFFFFF);
  // static   const  primary = Color(value)
  static const Color onBackground = Color(0xFFD8CEFF);

  static final afternoonPallet = LinearBackground(
    background1: Color(0xFFFCFCFC),
    background2: Color(0xFFE3F0FF),
    background3: Color(0xFFE8C2FF),
  );
  // Text colors
  static const primaryText = Color(0xFF352A7C);
  static const secondaryText = Color(0xFFFFFFFF);
  static const tertiaryText = Color(0xFF143966);
  static const quaternaryText = Color(0xFF768393);
  //
  static const outline = Color(0xFFCBCDFB);
  static const outlineHigh = Color(0xFF321C98);

  // Surface
  static const surface = Color(0xFFCBFBF9);
  static const surfaceLight = Color(0xFFBAA9F6);
  static const surfaceHigh = Color(0xFF4E38B2);

  // Divider
  static const divider = Color(0xFF9DCBEC);

  // Buttons
  static const secondaryButton = Color(0xFF917AE5);
  // static const secondaryButton = Color(0xFF352A7C);
  static const tertiaryButton = Color(0xFFB8B2D6);

  // Border
  static const primaryBorder = Color(0xFF9D89E8);

  // Shadow
  static const shadow = Color(0xFF143C6D);

  // Radius
  static double radius = 50.0;
}

class LinearBackground {
  final Color background1;
  final Color background2;
  final Color background3;

  LinearBackground({
    required this.background1,
    required this.background2,
    required this.background3,
  });

  List<Color> get getColors => [background1, background2, background3];
}
