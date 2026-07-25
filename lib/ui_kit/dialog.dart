import 'package:flutter/material.dart' as M;
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:flutter/widgets.dart';

class Dialog extends M.StatelessWidget {
  static Future<T?> show<T>(
    Widget child, {
    required BuildContext context,
    bool useRootNavigator = false,
    Color? color,
    double maxHeight = 400,
    double maxWidth = 400,
    EdgeInsets pading = const EdgeInsets.all(8),
  }) {
    return M.showDialog<T>(
      useRootNavigator: useRootNavigator,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          maxHeight: maxHeight,
          maxWidth: maxHeight,
          pading: pading,
          color: color,
          child: child,
        );
      },
    );
  }

  final M.Widget child;
  final M.Color? backgroundColor;
  final M.Color? color;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets pading;
  final double radius;
  const Dialog({
    super.key,
    required this.child,
    required this.maxWidth,
    required this.maxHeight,
    required this.pading,
    this.color,
    this.backgroundColor,
    this.radius = 22,
  });

  Color get _color => color ?? U.Theme.onBackground.withValues(alpha: 0.3);

  @override
  M.Widget build(M.BuildContext context) {
    return M.Dialog(
      backgroundColor: backgroundColor,
      constraints: M.BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: M.Container(
        padding: pading,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}
