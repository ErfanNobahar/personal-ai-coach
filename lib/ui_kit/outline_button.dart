import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

enum OutlineButtonSize { small, medium, large }

enum OutLineButtonColor { primary, secondary, tertiary }

enum OutLineButtonForeground { primary, secondary, tertiary }

class OutlineButton extends StatelessWidget {
  final bool disabled;
  final String title;
  final Function() onTap;
  final OutLineButtonColor color;
  final OutLineButtonForeground foregroundColor;
  final OutlineButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final MainAxisAlignment align;

  const OutlineButton({
    super.key,
    this.disabled = false,
    required this.title,
    required this.onTap,
    this.color = OutLineButtonColor.primary,
    this.size = OutlineButtonSize.medium,
    this.foregroundColor = OutLineButtonForeground.secondary,
    this.leading,
    this.trailing,
    this.align = MainAxisAlignment.center,
  });

  double get _size {
    switch (size) {
      case OutlineButtonSize.small:
        return 36;
      case OutlineButtonSize.medium:
        return 44;
      case OutlineButtonSize.large:
        return 54;
    }
  }

  ({Color text, Color border, U.TextWeight weight, U.TextSize size})
  get _color {
    switch (color) {
      case OutLineButtonColor.primary:
        return (
          text: U.Theme.outlineHigh,
          border: U.Theme.primaryBorder,
          weight: U.TextWeight.bold,
          size: U.TextSize.s14,
        );
      case OutLineButtonColor.secondary:
        return (
          text: U.Theme.primaryText,
          border: U.Theme.secondaryButton,
          weight: leading != null ? U.TextWeight.bold : U.TextWeight.md,
          size: leading != null ? U.TextSize.s16 : U.TextSize.s14,
        );
      case OutLineButtonColor.tertiary:
        return (
          text: U.Theme.tertiaryText,
          border: U.Theme.outline,
          weight: U.TextWeight.bold,
          size: U.TextSize.s12,
        );
    }
  }

  Color get _foregroundColor {
    switch (foregroundColor) {
      case OutLineButtonForeground.primary:
        return Colors.white.withValues(alpha: 0.0);
      case OutLineButtonForeground.secondary:
        return U.Theme.onBackground;
      case OutLineButtonForeground.tertiary:
        return U.Theme.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Material(
        color: _foregroundColor,
        borderRadius: BorderRadiusGeometry.all(Radius.circular(50)),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: disabled ? null : onTap,
          child: Container(
            //TODO:
            height: _size,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color:
                    //  disabled
                    //     ? _color.border.withValues(alpha: 0.5)
                    //     :
                    _color.border,
              ),
              color:
                  //  disabled
                  //     ? _foregroundColor.withValues(alpha: 0.5)
                  //     :
                  _foregroundColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: align,
                children: [
                  if (leading != null) ...[ leading!],
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: U.Text(
                        // maxLines: 5,
                        softWrap: true,
                        isCentered: true,
                        text: title,
                        color:
                            //  disabled
                            //     ? _color.text.withValues(alpha: 0.5)
                            //     :
                            _color.text,
                        textSize: _color.size,
                        textWeight: _color.weight,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[SizedBox(width: 10), trailing!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
