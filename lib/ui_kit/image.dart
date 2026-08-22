import 'package:flutter/material.dart' as M;
import 'package:flutter/widgets.dart';

class Image extends M.StatelessWidget {
  final String path;
  final BoxFit fit;
  final Color? color;
  final double? width;
  final double? height;

  const Image({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.color,
  });

  const Image.icon({
    super.key,
    this.color,
    required this.path,
    this.fit = BoxFit.contain,
    required double size,
  }) : width = size,
       height = size;

  @override
  M.Widget build(M.BuildContext context) {
    return M.Image.asset(
      path,
      color: color,
      fit: fit,
      height: height,
      width: width,
    );
  }
}

class Icons {
  static const String home = 'assets/icons/home.png';
  static const String chat = 'assets/icons/chat.png';
  static const String menu = 'assets/icons/menu.png';
  static const String camera = 'assets/icons/camera.png';
  static const String gallery = 'assets/icons/gallery.png';
  static const String microphone = 'assets/icons/microphone.png';
  static const String wrong = 'assets/icons/wrong.png';
  static const String back = 'assets/icons/back.png';
  static const String create = 'assets/icons/create.png';
  static const String progression = 'assets/icons/progression.png';
  static const String journey = 'assets/icons/journey.png';
  static const String down = 'assets/icons/down.png';
  static const String calendar = 'assets/icons/calendar.png';
  static const String subtract = 'assets/icons/subtract.png';
  static const String ai = 'assets/icons/ai.png';
  static const String chart = 'assets/icons/chart.png';
  static const String week = 'assets/icons/week.png';
  static const String task = 'assets/icons/task.png';
}

class Images {
  static const String logo = 'assets/images/logo.png';
  static const String background = 'assets/images/background.png';
  static const String profile = 'assets/images/profile.png';
  static const String settings = 'assets/images/settings.png';
  static const String notification = 'assets/images/notification.png';
  static const String search = 'assets/images/search.png';
  static const String home = 'assets/images/home.png';
  static const String chat = 'assets/images/chat.png';
  static const String calendar = 'assets/images/calendar.png';
  static const String camera = 'assets/images/camera.png';
  static const String gallery = 'assets/images/gallery.png';
  static const String microphone = 'assets/images/microphone.png';
}
