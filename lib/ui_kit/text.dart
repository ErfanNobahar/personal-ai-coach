import 'package:flutter/material.dart' as M;
import 'package:flutter/widgets.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

enum TextWeight { sm, md, bold, semiBold }

enum TextSize { s12, s14, s16, s18 }

class Text extends M.StatelessWidget {
  final String text;
  final M.Color? color;
  final TextWeight? textWeight;
  final TextSize? textSize;
  final bool isCentered;
  final TextOverflow overFlow;
  final bool softWrap;
  final int? maxLines;
  const Text({
    super.key,
    required this.text,
    this.color,
    this.textSize = TextSize.s12,
    this.textWeight = TextWeight.md,
    this.isCentered = false,
    this.softWrap = true,
    this.overFlow = TextOverflow.clip,
    this.maxLines,
  });
  // ignore: unused_element
  M.FontWeight get _getWeight {
    switch (textWeight) {
      case TextWeight.sm:
        return M.FontWeight.w400;
      case TextWeight.md:
        return M.FontWeight.w500;
      case TextWeight.bold:
        return M.FontWeight.w700;
      case TextWeight.semiBold:
        return M.FontWeight.w600;
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  double? get _getSize {
    switch (textSize) {
      case TextSize.s12:
        return 12;
      case TextSize.s14:
        return 14;
      case TextSize.s16:
        return 16;
      case TextSize.s18:
        return 18;

      // throw UnimplementedError().message;
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  M.Widget build(M.BuildContext context) {
    return M.Text(
      text,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overFlow,
      textAlign: isCentered ? M.TextAlign.center : null,
      style: M.TextStyle(
        fontWeight: _getWeight,
        fontSize: _getSize,
        color: color,
      ),
    );
  }
}

class DurationText extends StatelessWidget {
  final int minutes;
  final TextStyle? style;
  final bool showZeroMinutes;
  final String hourSuffix;
  final String minuteSuffix;
  final String separator;

  const DurationText(
    this.minutes, {
    super.key,
    this.style,
    this.showZeroMinutes = false,
    this.hourSuffix = 'h',
    this.minuteSuffix = 'm',
    this.separator = ' ',
  });

  @override
  Widget build(BuildContext context) {
    final text = formatDuration(
      minutes,
      showZeroMinutes: showZeroMinutes,
      hourSuffix: hourSuffix,
      minuteSuffix: minuteSuffix,
      separator: separator,
    );

    return Text(text: text,textWeight: TextWeight.semiBold,
    textSize: TextSize.s16,
    color: U.Theme.primaryText,
    );
  }
}

String formatDuration(
  int minutes, {
  bool showZeroMinutes = false,
  String hourSuffix = 'h',
  String minuteSuffix = 'm',
  String separator = ' ',
}) {
  if (minutes < 0) minutes = 0;

  final hours = minutes ~/ 60;
  final mins = minutes % 60;

  if (hours == 0) {
    return '$mins$minuteSuffix';
  }

  if (mins == 0 && !showZeroMinutes) {
    return '$hours$hourSuffix';
  }

  return '$hours$hourSuffix$separator$mins$minuteSuffix';
}
