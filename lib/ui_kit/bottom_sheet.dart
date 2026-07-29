import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class BottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsets pading;

  const BottomSheet({super.key, required this.child, required this.pading});

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double maxHeight = 450,
    double maxwidth = 250,
    EdgeInsets pading = const EdgeInsets.all(15),
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxwidth),
      builder: (BuildContext context) {
        return U.BottomSheet(pading: pading, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: U.Theme.onBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
