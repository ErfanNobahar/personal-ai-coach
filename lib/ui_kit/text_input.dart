import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TextInput extends StatefulWidget {
  final TextEditingController controller;
  final int? maxLines;
  final int? minLines;
  final double borderRadius; // radius when single line / static mode
  final double expandedBorderRadius; // radius when multi line
  final bool expands;
  final InputBorder inputBorder;
  final Color color;
  final String hint;
  final bool autoFocus;
  final bool expandOnMultiline; // <-- toggle
  final double fixedHeight; // used when expandOnMultiline is false
  final Function() onEditingComplete;

  const TextInput({
    super.key,
    required this.controller,
    this.maxLines,
    this.minLines = 1,
    this.borderRadius = 15.0,
    this.expandedBorderRadius = 20.0,
    this.expands = false,
    this.color = U.Theme.white,
    this.inputBorder = InputBorder.none,
    this.hint = '',
    this.autoFocus = false,
    this.expandOnMultiline = false,
    this.fixedHeight = 55,
    required this.onEditingComplete,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final focusNode = FocusNode();
  bool isFocused = false;
  bool isMultiline = false;

  static const double collapsedHeight = 55;
  static const double expandedHeight = 96;
  static const double horizontalPadding = 32;
  static const double fontSize = 14; // match your actual field's text style

  @override
  void initState() {
    if (widget.autoFocus) {
      focusNode.requestFocus();
    }
    focusNode.addListener(() {
      isFocused = focusNode.hasFocus;
      setState(() {});
    });
    if (widget.expandOnMultiline) {
      widget.controller.addListener(_checkMultiline);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.expandOnMultiline) {
      widget.controller.removeListener(_checkMultiline);
    }
    focusNode.dispose();
    super.dispose();
  }

  void _checkMultiline() {
    final width = MediaQuery.of(context).size.width - horizontalPadding;
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.controller.text,
        style: const TextStyle(fontSize: fontSize),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);

    final overflowing = textPainter.didExceedMaxLines;

    if (overflowing != isMultiline) {
      setState(() {
        isMultiline = overflowing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool multiline = widget.expandOnMultiline;
    final double height = widget.expandOnMultiline
        ? (multiline ? expandedHeight : collapsedHeight)
        : widget.fixedHeight;
    final double radius = widget.expandOnMultiline
        ? (multiline ? widget.expandedBorderRadius : widget.borderRadius)
        : widget.borderRadius;

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: AnimatedContainer(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isFocused ? U.Theme.surfaceHigh : U.Theme.surfaceHigh.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(radius),
          color: widget.color,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: TextField(
          style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.w500),
          onEditingComplete: widget.onEditingComplete,
          focusNode: focusNode,
          controller: widget.controller,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          decoration: InputDecoration(
            hint: U.Text(text: widget.hint, textSize: U.TextSize.s16,textWeight: U.TextWeight.sm,),
            fillColor: widget.color,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            border: widget.inputBorder,
          ),
        ),
      ),
    );
  }
}
