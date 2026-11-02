import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:flutter/material.dart';

class TaskSegment {
  final double value;
  final Color color;
  const TaskSegment(this.value, this.color);
}

class DayTasks {
  final String label;
  final List<TaskSegment> segments; // bottom → top order
  const DayTasks(this.label, this.segments);
}

class TaskBarChart extends StatelessWidget {
  final List<DayTasks> data;

  /// Gap between segments AND above the top of the stack (the "padding"
  /// before the crosshatch region). Default 5.0.
  final double segmentGap;

  /// Spacing between crosshatch lines. Smaller = denser. Default 6.0.
  final double hatchStep;

  const TaskBarChart({
    super.key,
    required this.data,
    this.segmentGap = 5.0,
    this.hatchStep = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _TaskBarPainter(data, segmentGap, hatchStep),
        child: Container(),
      ),
    );
  }
}

class _TaskBarPainter extends CustomPainter {
  final List<DayTasks> data;
  final double segmentGap;
  final double hatchStep;
  _TaskBarPainter(this.data, this.segmentGap, this.hatchStep);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barCount = data.length;
    final spacing = size.width / barCount;
    final barWidth = spacing * 0.66;
    final chartHeight = size.height - 24;
    final radius = barWidth / 3.5;

    // ── Only segments with a positive value participate in layout. ──
    // This prevents a zero-value "starting segment" from consuming a
    // segmentGap and pushing the bottom-most visible segment off the
    // baseline.
    final visible = data
        .map((d) => d.segments.where((s) => s.value > 0).toList())
        .toList();

    final totals = visible
        .map((segs) => segs.fold(0.0, (sum, s) => sum + s.value))
        .toList();

    final maxTotal = totals.fold<double>(0, (a, b) => a > b ? a : b);
    if (maxTotal <= 0) return;

    for (int i = 0; i < barCount; i++) {
      final segments = visible[i];
      final total = totals[i];
      if (segments.isEmpty || total <= 0) continue;

      final barHeight = (total / maxTotal) * chartHeight;
      final centerX = spacing * i + spacing / 2;
      final bottomY = chartHeight;

      final gapsTotal = (segments.length - 1) * segmentGap;
      final availableHeight = (barHeight - gapsTotal).clamp(0.0, barHeight);

      // Build independent rectangles (bottom → top). j == 0 is always
      // flush with bottomY because cumulative starts at 0.
      final rects = <Rect>[];
      double cumulative = 0;
      for (int j = 0; j < segments.length; j++) {
        final seg = segments[j];
        final segH = availableHeight * (seg.value / total);

        final naturalBottom = bottomY - cumulative;
        final naturalTop = naturalBottom - segH;

        rects.add(
          Rect.fromLTRB(
            centerX - barWidth / 2,
            naturalTop,
            centerX + barWidth / 2,
            naturalBottom,
          ),
        );

        cumulative += segH;
        if (j < segments.length - 1) cumulative += segmentGap;
      }

      // ── Crosshatch the leftover space above the drawn stack.
      // Use the *actual* drawn height (availableHeight + gapsTotal), not
      // barHeight, so the hatch lines up even if availableHeight clamped.
      final drawnHeight = availableHeight + gapsTotal;
      final leftoverBottom = (bottomY - drawnHeight) - segmentGap;

      if (leftoverBottom > 0) {
        final leftoverRect = Rect.fromLTRB(
          centerX - barWidth / 2,
          0,
          centerX + barWidth / 2,
          leftoverBottom,
        );

        final leftoverShape = RRect.fromRectAndRadius(
          leftoverRect,
          Radius.circular(radius),
        );

        canvas.save();
        canvas.clipRRect(leftoverShape);

        final hatchPaint = Paint()
          ..color = const Color(0xFF9E9E9E).withOpacity(0.18)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        final h = leftoverRect.height;
        final w = leftoverRect.width;

        for (double d = -h; d < w; d += hatchStep) {
          canvas.drawLine(
            Offset(leftoverRect.left + d, leftoverRect.top),
            Offset(leftoverRect.left + d + h, leftoverRect.bottom),
            hatchPaint,
          );
          canvas.drawLine(
            Offset(leftoverRect.left + d, leftoverRect.bottom),
            Offset(leftoverRect.left + d + h, leftoverRect.top),
            hatchPaint,
          );
        }

        canvas.restore();
      }

      // Draw the actual segments
      for (int j = 0; j < segments.length; j++) {
        final seg = segments[j];
        final rect = rects[j];

        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
        canvas.drawRRect(rrect, Paint()..color = seg.color);

        if (seg.value > 0 && rect.height > 18) {
          final label = '${seg.value.round()}%';
          final tp = TextPainter(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final badgeCenterY = rect.center.dy;
          tp.paint(
            canvas,
            Offset(centerX - tp.width / 2, badgeCenterY - tp.height / 2),
          );
        }
      }

      // Day label
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
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
  bool shouldRepaint(covariant _TaskBarPainter old) =>
      old.data != data ||
      old.segmentGap != segmentGap ||
      old.hatchStep != hatchStep;
}
