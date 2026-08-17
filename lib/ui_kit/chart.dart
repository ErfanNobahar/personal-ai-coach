import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:flutter/material.dart';

class TaskSegment {
  final double value;
  final Color color;
  const TaskSegment(this.value, this.color);
}

class DayTasks {
  final String label;
  final List<TaskSegment> segments; // bottom -> top order
  const DayTasks(this.label, this.segments);
}

class TaskBarChart extends StatelessWidget {
  final List<DayTasks> data;
  const TaskBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(painter: _TaskBarPainter(data), child: Container()),
    );
  }
}

class _TaskBarPainter extends CustomPainter {
  final List<DayTasks> data;
  _TaskBarPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = data.length;
    final spacing = size.width / barCount;
    final barWidth = spacing * 0.4;
    final chartHeight = size.height - 24;
    final radius = barWidth / 2;
    final overlap = radius * 1.2;

    final maxTotal = data
        .map((d) => d.segments.fold(0.0, (sum, s) => sum + s.value))
        .reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < barCount; i++) {
      final day = data[i];
      final total = day.segments.fold(0.0, (sum, s) => sum + s.value);
      final barHeight = (total / maxTotal) * chartHeight;
      final centerX = spacing * i + spacing / 2;
      final bottomY = chartHeight;

      // pass 1: natural (non-overlapped) rects
      final rects = <Rect>[];
      double cumulativeHeight = 0;
      for (final seg in day.segments) {
        final segHeight = barHeight * (seg.value / total);
        final naturalBottom = bottomY - cumulativeHeight;
        final naturalTop = naturalBottom - segHeight;
        rects.add(
          Rect.fromLTRB(
            centerX - barWidth / 2,
            naturalTop,
            centerX + barWidth / 2,
            naturalBottom,
          ),
        );
        cumulativeHeight += segHeight;
      }

      // pass 2: draw top-to-bottom so lower segments paint last (frontmost)
      for (int j = day.segments.length - 1; j >= 0; j--) {
        final seg = day.segments[j];
        final natural = rects[j];
        final segHeight = natural.height;

        // cap overlap so short segments don't get eaten alive
        final effectiveOverlap = (segHeight * 0.5 < overlap)
            ? segHeight * 0.5
            : overlap;

        final drawTop = natural.top - effectiveOverlap;
        // bottom always stays at the natural, un-extended position — flat, no rounding
        final drawBottom = natural.bottom;

        final rrect = RRect.fromRectAndCorners(
          Rect.fromLTRB(natural.left, drawTop, natural.right, drawBottom),
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          // bottomLeft / bottomRight intentionally omitted -> stay square
        );

        canvas.drawRRect(rrect, Paint()..color = seg.color);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: day.label,
          style: const TextStyle(color: U.Theme.primaryText, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TaskBarPainter oldDelegate) => true;
}
