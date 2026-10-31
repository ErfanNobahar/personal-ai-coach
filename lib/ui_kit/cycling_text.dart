import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart' as M;
import 'package:flutter/widgets.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class CyclingTextShowcase extends M.StatefulWidget {
  final List<String> texts;
  final Duration interval;
  final double itemExtent;
  final M.Color? highlightColor;

  const CyclingTextShowcase({
    super.key,
    required this.texts,
    this.interval = const Duration(seconds: 3),
    this.itemExtent = 39,
    this.highlightColor,
  });

  @override
  M.State<CyclingTextShowcase> createState() => _CyclingTextShowcaseState();
}

class _CyclingTextShowcaseState extends M.State<CyclingTextShowcase> {
  late M.FixedExtentScrollController _controller;
  late Timer _timer;
  int _currentIndex = 0;

  // Current scroll offset in items (can be fractional while animating)
  double _currentScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = M.FixedExtentScrollController(initialItem: 0);

    // Listen to scroll so we can smoothly interpolate styles
    _controller.addListener(() {
      if (_controller.hasClients) {
        setState(() {
          
        });
        _currentScrollOffset = _controller.offset / widget.itemExtent;
      }
    });

    _timer = Timer.periodic(widget.interval, (_) {
      if (widget.texts.isEmpty) return;

      _currentIndex = (_currentIndex + 1) % widget.texts.length;
      setState(() {});

      _controller.animateToItem(
        _currentIndex,
        duration: const Duration(milliseconds: 650),
        curve: M.Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  M.Widget build(M.BuildContext context) {
    if (widget.texts.isEmpty) {
      return const M.SizedBox.shrink();
    }

    final highlightColor = widget.highlightColor ?? U.Theme.surfaceLight;

    return M.SizedBox(
      height: widget.itemExtent * 3.5,
      child: M.Stack(
        alignment: M.Alignment.center,
        children: [
          // Scrolling texts
          M.ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: widget.itemExtent,
            perspective: 0.002,
            diameterRatio: 1.6,
            physics: const M.NeverScrollableScrollPhysics(),
            childDelegate: M.ListWheelChildBuilderDelegate(
              childCount: widget.texts.length,
              builder: (context, index) {
                // How far this item is from the visual center (0 = perfectly centered)
                final distance = (index - _currentScrollOffset).abs();

                // 0 → fully selected, 1 → fully unselected
                final t = (distance).clamp(0.0, 1.0);

                // Interpolate size & color
                final fontSize = lerpDouble(20, 16, t)!;
                final fontWeight = t < 0.5
                    ? M.FontWeight.w500
                    : M.FontWeight.w400;

                final color = M.Color.lerp(
                  U.Theme.primaryText, // white when selected
                  U.Theme.quaternaryText, // faded when far
                  t,
                )!;

                return M.Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: M.Padding(
                    padding: const M.EdgeInsets.symmetric(horizontal: 20),
                    child: M.Text(
                      widget.texts[index],
                      maxLines: 1,
                      overflow: M.TextOverflow.ellipsis,
                      textAlign: M.TextAlign.center,
                      style: M.TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed highlight container
          M.IgnorePointer(
            child: M.Container(
              height: widget.itemExtent * 0.92,
              margin: const M.EdgeInsets.symmetric(horizontal: 16),
              decoration: M.BoxDecoration(
                color: highlightColor.withValues(alpha: 0.0),
                borderRadius: M.BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
