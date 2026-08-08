import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class ChatBubble extends StatelessWidget {
  final bool rtl;
  final String text;

  const ChatBubble({super.key, required this.text, this.rtl = false});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        children: [
          Flexible(
            flex: 65,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: rtl
                    ? U.Theme.background.withValues(alpha: 0.9)
                    : U.Theme.secondaryButton.withValues(alpha: 0.7),
                border: Border.all(
                  width: rtl ? 1 : 0,
                  color: !rtl ? U.Theme.surface.withValues(alpha: 0.0) : U.Theme. secondaryButton,
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 10,
                    color:U.Theme.shadow.withValues(alpha: 0.25),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: U.Text(
                  text: text,
                  textWeight: U.TextWeight.md,
                  textSize: U.TextSize.s16,
                  color:rtl? U.Theme.primaryText: U.Theme.white,
                ),
              ),
            ),
          ),
          Flexible(flex: 35, child: SizedBox()),
        ],
      ),
    );
  }
}
