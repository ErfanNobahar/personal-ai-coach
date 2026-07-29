import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TextInput extends StatefulWidget {
  final TextEditingController controller;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final InputBorder inputBorder;
  final Color color;
  final String hint;
  final bool autoFocus;
  final Function() onEditingComplete;
  const TextInput({
    super.key,
    required this.controller,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.color = U.Theme.divider,
    this.inputBorder = InputBorder.none,
    this.hint = '',
    this.autoFocus = false,
    required this.onEditingComplete,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final focusNode = FocusNode();
  bool isFocused = false;
  @override
  void initState() {
    if (widget.autoFocus) {
      focusNode.requestFocus();
    }
    focusNode.addListener(() {
      isFocused == focusNode.hasFocus;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isFocused ? U.Theme.primaryBorder : widget.color,
          ),
          borderRadius: BorderRadius.circular(15),
          color: widget.color,
        ),
        child: TextField(
          onEditingComplete: widget.onEditingComplete,
          focusNode: focusNode,
          controller: widget.controller,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          decoration: InputDecoration(
            hint: U.Text(text: widget.hint),
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
