import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class AppBar extends StatelessWidget {
  final String title;
  final bool blur;
  final dynamic Function()? onPop;
  const AppBar({super.key, required this.title, this.onPop, this.blur = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 77,
      decoration: BoxDecoration(
        gradient: blur
            ? LinearGradient(
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
                colors: [
                  Color(0xFFF8F8F8).withValues(alpha: 1.0),
                  Color(0xFFF8F8F8).withValues(alpha: 1.0),
                  Color(0xFFF8F8F8).withValues(alpha: 1.0),
                  Color(0xFFF8F8F8).withValues(alpha: 0.9),
                  Color(0xFFF8F8F8).withValues(alpha: 0.6),
                  Color(0xFFF8F8F8).withValues(alpha: 0.0),
                  // Colors.black,
                ],
              )
            : null,
        color: blur ? null : U.Theme.background.withValues(alpha: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                onPop != null ? onPop!() : GoRouter.of(context).pop();
              },
              child: U.Image(path: U.Icons.back, width: 28, height: 14),
            ),
            U.Text(
              text: title,
              textSize: U.TextSize.s18,
              textWeight: U.TextWeight.bold,
            ),
            InkWell(
              onTap: () {
                onPop != null ? onPop!() : GoRouter.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFA29DC3).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: U.Image.icon(path: U.Icons.wrong, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
