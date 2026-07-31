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
    double radius = 22,
    bool isFullScreen = false,
    EdgeInsets pading = const EdgeInsets.all(8),
    EdgeInsets insetPading = const EdgeInsets.all(15),
  }) {
    return M.showDialog<T>(
      useRootNavigator: useRootNavigator,
      context: context,
      builder: (BuildContext context) {
        return isFullScreen
            ? Dialog.fullScreen(
                pading: pading,
                radius: radius,
                color: color,
                insetPading: insetPading,
                child: child,
              )
            : Dialog(
                maxHeight: maxHeight,
                maxWidth: maxHeight,
                pading: pading,
                radius: radius,
                color: color,
                insetPading: insetPading,
                child: child,
              );
      },
    );
  }

  final M.Widget child;
  final bool isFullScreen;
  final M.Color? backgroundColor;
  final M.Color? color;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets pading;
  final EdgeInsets insetPading;
  final double radius;
  const Dialog({
    super.key,
    required this.child,
    required this.maxWidth,
    required this.maxHeight,
    required this.pading,
    this.color,
    this.backgroundColor,
    required this.radius,
    required this.insetPading,
  }) : isFullScreen = false;

  const Dialog.fullScreen({
    super.key,
    required this.child,
    required this.pading,
    required this.insetPading,
    this.color,
    this.backgroundColor,
    required this.radius,
  }) : isFullScreen = true,
       maxHeight = double.infinity,
       maxWidth = double.infinity;

  Color get _color => color ?? U.Theme.white;

  @override
  M.Widget build(M.BuildContext context) {
    return M.Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isFullScreen ? 0 : radius),
      ),
      insetPadding: isFullScreen ? EdgeInsets.zero : insetPading,
      backgroundColor: _color,
      constraints: M.BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: M.Padding(
        padding: isFullScreen ? EdgeInsets.zero : const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}
