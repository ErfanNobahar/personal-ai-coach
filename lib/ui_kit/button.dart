import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

enum ButtonColor { primary, secondary, tertiary }

enum ButtonText { primary, secondary }

// enum weight { bold, semiBold, medium }

class Button extends StatelessWidget {
  final bool disabled;
  final String title;
  final Function() onTap;
  final ButtonColor buttonColor;
  final ButtonText? buttonText;
  // final weight? fontWeight;
  final Widget? trailing;
  final Widget? leading;

  const Button({
    super.key,
    required this.title,
    required this.onTap,
    this.disabled = false,
    this.buttonColor = ButtonColor.primary,
    this.buttonText = ButtonText.primary,
    // this.fontWeight,
    this.trailing,
    this.leading,
  });

  U.TextSize get getSize {
    switch (buttonText!) {
      case ButtonText.primary:
        return U.TextSize.s14;
      case ButtonText.secondary:
        return U.TextSize.s16;
    }
  }

  Color get buttonInfo {
    switch (buttonColor) {
      case ButtonColor.primary:
        return U.Theme.secondaryButton;
      case ButtonColor.secondary:
        return U.Theme.primary;
      case ButtonColor.tertiary:
        return U.Theme.tertiaryButton;
    }
  }

  // FontWeight get fontWeightValue {
  //   switch (fontWeight) {
  //     case weight.bold:
  //       return FontWeight.bold;
  //     case weight.semiBold:
  //       return FontWeight.w600;
  //     case weight.medium:
  //       return FontWeight.w500;
  //     case null:
  //       return FontWeight.w500;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(U.Theme.radius),
      color: disabled ? buttonInfo.withValues(alpha: 0.5) : buttonInfo,
      child: InkWell(
      borderRadius: BorderRadius.circular(U.Theme.radius),
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 11),
          // height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(U.Theme.radius),
            color: disabled ? buttonInfo.withValues(alpha: 0.5) : buttonInfo,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[SizedBox(width: 9.2), leading!],
              U.Text(
                text: title,
                color: U.Theme.white,
                textSize: getSize,
                textWeight: leading != null || trailing != null
                    ? U.TextWeight.md
                    : U.TextWeight.bold,
              ),
              if (trailing != null) ...[SizedBox(width: 23), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
