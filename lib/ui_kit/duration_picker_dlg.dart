import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'theme.dart' as t;

@immutable
class TimeSlot {
  final int startMinutes;
  final int endMinutes;

  const TimeSlot({required this.startMinutes, required this.endMinutes})
    : assert(
        endMinutes > startMinutes,
        'endMinutes must be greater than startMinutes',
      );

  int get durationMinutes => endMinutes - startMinutes;

  bool overlaps(TimeSlot other) =>
      startMinutes < other.endMinutes && other.startMinutes < endMinutes;

  String get label => '${_format(startMinutes)} - ${_format(endMinutes)}';

  static String _format(int minutes) {
    final h24 = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final period = h24 < 12 ? 'AM' : 'PM';
    var h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  TimeSlot copyWith({int? startMinutes, int? endMinutes}) => TimeSlot(
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
  );
}

extension Slot on List<TimeSlot> {
  List<int> get convertToInt {
    List<int> temp = [];
    for (var e in this) {
      final res = List.generate(
        ((e.endMinutes ~/ 60) + 1) - e.startMinutes ~/ 60,
        (index) {
          return e.startMinutes ~/ 60 + index ;
        },
        growable: true,
      );
      temp.addAll(res);
    }
    return temp;
  }
}

/// Shows the circular duration/time picker as a dialog.
///
/// [maxDurationMinutes] caps how long the selected range may be
/// (defaults to 300 min = 5 hours).
Future<TimeSlot?> showDurationTimePicker({
  required BuildContext context,
  required List<TimeSlot> occupiedSlots,
  TimeSlot? initialSlot,
  int minDurationMinutes = 15,
  int snapMinutes = 5,
  int maxDurationMinutes = 300, // ← NEW
}) {
  return showDialog<TimeSlot>(
    context: context,
    barrierColor: t.Theme.tertiaryText.withOpacity(0.35),
    builder: (_) => _DurationTimePickerDialog(
      occupiedSlots: occupiedSlots,
      initialSlot:
          initialSlot ?? const TimeSlot(startMinutes: 0, endMinutes: 180),
      minDurationMinutes: minDurationMinutes,
      snapMinutes: snapMinutes,
      maxDurationMinutes: maxDurationMinutes, // ← NEW
    ),
  );
}

enum _Handle { start, end }

class _DurationTimePickerDialog extends StatefulWidget {
  final List<TimeSlot> occupiedSlots;
  final TimeSlot initialSlot;
  final int minDurationMinutes;
  final int snapMinutes;
  final int maxDurationMinutes; // ← NEW

  const _DurationTimePickerDialog({
    required this.occupiedSlots,
    required this.initialSlot,
    required this.minDurationMinutes,
    required this.snapMinutes,
    required this.maxDurationMinutes, // ← NEW
  });

  @override
  State<_DurationTimePickerDialog> createState() =>
      _DurationTimePickerDialogState();
}

class _DurationTimePickerDialogState extends State<_DurationTimePickerDialog> {
  late int _startMinutes;
  late int _endMinutes;
  _Handle? _activeHandle;

  static const double _boxSize = 300;
  static const double _trackRadius = 95;
  static const double _amRingRadius = _trackRadius - 20;
  static const double _pmRingRadius = _trackRadius + 20;

  @override
  void initState() {
    super.initState();
    _startMinutes = widget.initialSlot.startMinutes;
    _endMinutes = widget.initialSlot.endMinutes;

    // ← NEW: clamp an initial range that is already longer than the max
    if (_endMinutes - _startMinutes > widget.maxDurationMinutes) {
      _endMinutes = _startMinutes + widget.maxDurationMinutes;
    }
  }

  static double _angleForMinutes(int minutes) {
    final inLap = minutes % 720;
    return inLap / 720 * 360;
  }

  static Offset _pointOnCircle(
    Offset center,
    double radius,
    double angleTopDeg,
  ) {
    final rad = angleTopDeg * math.pi / 180;
    return Offset(
      center.dx + radius * math.sin(rad),
      center.dy - radius * math.cos(rad),
    );
  }

  double _angleFromLocalPosition(Offset localPos, Offset center) {
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    var thetaTop = math.atan2(dx, -dy) * 180 / math.pi;
    if (thetaTop < 0) thetaTop += 360;
    return thetaTop;
  }

  double _resolveMinutes(double angleDeg, double lastMinutes) {
    final base = angleDeg * 2;
    final candidateA = base;
    final candidateB = base + 720;
    return _circularDistance(candidateA, lastMinutes) <=
            _circularDistance(candidateB, lastMinutes)
        ? candidateA
        : candidateB;
  }

  double _circularDistance(double a, double b) {
    final diff = (a - b).abs() % 1440;
    return diff > 720 ? 1440 - diff : diff;
  }

  int _snap(double minutes) {
    final snapped = (minutes / widget.snapMinutes).round() * widget.snapMinutes;
    return snapped.clamp(0, 1440);
  }

  // ← UPDATED: added max-duration check
  bool _isValidRange(int start, int end) {
    if (end - start < widget.minDurationMinutes) return false;
    if (end - start > widget.maxDurationMinutes) return false; // ← NEW
    if (start < 0 || end > 1440) return false;
    for (final slot in widget.occupiedSlots) {
      if (start < slot.endMinutes && slot.startMinutes < end) return false;
    }
    return true;
  }

  void _onPanStart(Offset localPos, Offset center) {
    final startHandlePos = _pointOnCircle(
      center,
      _trackRadius,
      _angleForMinutes(_startMinutes),
    );
    final endHandlePos = _pointOnCircle(
      center,
      _trackRadius,
      _angleForMinutes(_endMinutes),
    );

    final distToStart = (localPos - startHandlePos).distance;
    final distToEnd = (localPos - endHandlePos).distance;

    const hitRadius = 28.0;
    if (distToStart > hitRadius && distToEnd > hitRadius) {
      _activeHandle = null;
      return;
    }
    _activeHandle = distToStart <= distToEnd ? _Handle.start : _Handle.end;
    setState(() {});
  }

  // ← UPDATED: guard dragging so it can never exceed maxDurationMinutes
  void _onPanUpdate(Offset localPos, Offset center) {
    if (_activeHandle == null) return;
    final angle = _angleFromLocalPosition(localPos, center);

    if (_activeHandle == _Handle.start) {
      final raw = _resolveMinutes(angle, _startMinutes.toDouble());
      final candidate = _snap(raw);

      // Hard floor: can't shrink below min duration
      if (candidate >= _endMinutes - widget.minDurationMinutes) return;
      // Hard ceiling: can't expand beyond max duration   // ← NEW
      if (candidate < _endMinutes - widget.maxDurationMinutes) return;
      if (!_isValidRange(candidate, _endMinutes)) return;
      setState(() => _startMinutes = candidate);
    } else {
      final raw = _resolveMinutes(angle, _endMinutes.toDouble());
      final candidate = _snap(raw);

      // Hard floor: can't shrink below min duration
      if (candidate <= _startMinutes + widget.minDurationMinutes) return;
      // Hard ceiling: can't expand beyond max duration   // ← NEW
      if (candidate > _startMinutes + widget.maxDurationMinutes) return;
      if (!_isValidRange(_startMinutes, candidate)) return;
      setState(() => _endMinutes = candidate);
    }
  }

  String _timeLabel(int minutes) {
    final h24 = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    var h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:${m.toString().padLeft(2, '0')} ${h24 < 12 ? 'AM' : 'PM'}';
  }

  String get _periodLabel {
    final startPeriod = _startMinutes < 720 ? 'AM' : 'PM';
    final endPeriod = _endMinutes < 720 ? 'AM' : 'PM';
    return startPeriod == endPeriod ? startPeriod : '$startPeriod-$endPeriod';
  }

  String get _durationLabel {
    final total = _endMinutes - _startMinutes;
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0 && m > 0) return '$h hr $m min';
    if (h > 0) return '$h hr';
    return '$m min';
  }

  Future<void> _editStartTime() async {
    final result = await _showManualTimeEditor(
      context: context,
      title: 'Set Start Time',
      initialMinutes: _startMinutes,
      isValid: (m) =>
          m < _endMinutes - widget.minDurationMinutes &&
          m >= _endMinutes - widget.maxDurationMinutes && // ← NEW
          _isValidRange(m, _endMinutes),
    );
    if (result != null) setState(() => _startMinutes = result);
  }

  Future<void> _editEndTime() async {
    final result = await _showManualTimeEditor(
      context: context,
      title: 'Set End Time',
      initialMinutes: _endMinutes,
      isValid: (m) =>
          m > _startMinutes + widget.minDurationMinutes &&
          m <= _startMinutes + widget.maxDurationMinutes && // ← NEW
          _isValidRange(_startMinutes, m),
    );
    if (result != null) setState(() => _endMinutes = result);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isValidRange(_startMinutes, _endMinutes);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: t.Theme.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: t.Theme.shadow.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Duration & Time',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: t.Theme.primaryText,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TimeHeader(
                  label: 'Start Time',
                  value: _timeLabel(_startMinutes),
                  active: _activeHandle == _Handle.start,
                  onTap: _editStartTime,
                ),
                _TimeHeader(
                  label: 'End Time',
                  value: _timeLabel(_endMinutes),
                  active: _activeHandle == _Handle.end,
                  onTap: _editEndTime,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: _boxSize,
              height: _boxSize,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final center = Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight / 2,
                  );
                  return GestureDetector(
                    onPanStart: (d) => _onPanStart(d.localPosition, center),
                    onPanUpdate: (d) => _onPanUpdate(d.localPosition, center),
                    onPanEnd: (_) => setState(() => _activeHandle = null),
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _ClockPainter(
                        startMinutes: _startMinutes,
                        endMinutes: _endMinutes,
                        occupiedSlots: widget.occupiedSlots,
                        activeHandle: _activeHandle,
                        trackRadius: _trackRadius,
                        amRingRadius: _amRingRadius,
                        pmRingRadius: _pmRingRadius,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _Legend(),
            const SizedBox(height: 10),
            Text(
              _durationLabel,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: t.Theme.primaryText,
              ),
            ),
            Text(
              'Meeting Duration',
              style: TextStyle(
                fontSize: 13,
                color: t.Theme.quaternaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.Theme.outline, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: t.Theme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () => Navigator.of(context).pop(
                            TimeSlot(
                              startMinutes: _startMinutes,
                              endMinutes: _endMinutes,
                            ),
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.Theme.primary,
                      disabledBackgroundColor: t.Theme.tertiaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: t.Theme.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeHeader extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;

  const _TimeHeader({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: t.Theme.quaternaryText),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: active ? t.Theme.primary : t.Theme.primaryText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: t.Theme.quaternaryText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget dot(Color color) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    TextStyle style = TextStyle(fontSize: 11, color: t.Theme.quaternaryText);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(_ClockPainter.occupiedColor.withOpacity(0.55)),
        const SizedBox(width: 6),
        Text('Busy (inner = AM)', style: style),
        const SizedBox(width: 14),
        dot(_ClockPainter.occupiedColor),
        const SizedBox(width: 6),
        Text('Busy (outer = PM)', style: style),
      ],
    );
  }
}

class _ClockPainter extends CustomPainter {
  final int startMinutes;
  final int endMinutes;
  final List<TimeSlot> occupiedSlots;
  final _Handle? activeHandle;
  final double trackRadius;
  final double amRingRadius;
  final double pmRingRadius;

  static const Color occupiedColor = Color(0xFFE49B9B);

  _ClockPainter({
    required this.startMinutes,
    required this.endMinutes,
    required this.occupiedSlots,
    required this.activeHandle,
    required this.trackRadius,
    required this.amRingRadius,
    required this.pmRingRadius,
  });

  double _angleForMinutes(int minutes) {
    final inLap = minutes % 720;
    return inLap / 720 * 360;
  }

  Offset _pointOnCircle(Offset center, double radius, double angleTopDeg) {
    final rad = angleTopDeg * math.pi / 180;
    return Offset(
      center.dx + radius * math.sin(rad),
      center.dy - radius * math.cos(rad),
    );
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngleTopDeg,
    double sweepDeg,
    Paint paint,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startRad = (startAngleTopDeg - 90) * math.pi / 180;
    final sweepRad = sweepDeg * math.pi / 180;
    canvas.drawArc(rect, startRad, sweepRad, false, paint);
  }

  void _drawHandle(Canvas canvas, Offset center, int minutes, bool isActive) {
    final pos = _pointOnCircle(center, trackRadius, _angleForMinutes(minutes));

    final shadowPaint = Paint()
      ..color = t.Theme.shadow.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(pos + const Offset(0, 2), 15, shadowPaint);

    final fillPaint = Paint()..color = t.Theme.white;
    canvas.drawCircle(pos, 15, fillPaint);

    final borderPaint = Paint()
      ..color = t.Theme.surfaceHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 4.5 : 3.5;
    canvas.drawCircle(pos, 15, borderPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final trackPaint = Paint()
      ..color = t.Theme.onBackground.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, trackRadius, trackPaint);

    const hourLabels = [
      '12',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
    ];
    for (int h = 0; h < 12; h++) {
      final angle = h / 12 * 360;
      final isMajor = h % 3 == 0;
      final labelPos = _pointOnCircle(center, trackRadius + 30, angle);
      final tp = TextPainter(
        text: TextSpan(
          text: hourLabels[h],
          style: TextStyle(
            color: isMajor ? t.Theme.primaryText : t.Theme.quaternaryText,
            fontSize: isMajor ? 13 : 12,
            fontWeight: isMajor ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }

    final amOccupiedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = occupiedColor.withOpacity(0.55);
    final pmOccupiedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = occupiedColor;

    for (final slot in occupiedSlots) {
      final s = slot.startMinutes.clamp(0, 1440);
      final e = slot.endMinutes.clamp(0, 1440);

      if (e <= 720) {
        _drawArc(
          canvas,
          center,
          amRingRadius,
          _angleForMinutes(s),
          (e - s) / 2,
          amOccupiedPaint,
        );
      } else if (s >= 720) {
        _drawArc(
          canvas,
          center,
          pmRingRadius,
          _angleForMinutes(s),
          (e - s) / 2,
          pmOccupiedPaint,
        );
      } else {
        _drawArc(
          canvas,
          center,
          amRingRadius,
          _angleForMinutes(s),
          (720 - s) / 2,
          amOccupiedPaint,
        );
        _drawArc(
          canvas,
          center,
          pmRingRadius,
          0,
          (e - 720) / 2,
          pmOccupiedPaint,
        );
      }
    }

    final duration = endMinutes - startMinutes;
    final selectedPaint = Paint()
      ..color = t.Theme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    _drawArc(
      canvas,
      center,
      trackRadius,
      _angleForMinutes(startMinutes),
      (duration / 2).clamp(0, 360),
      selectedPaint,
    );

    _drawHandle(canvas, center, startMinutes, activeHandle == _Handle.start);
    _drawHandle(canvas, center, endMinutes, activeHandle == _Handle.end);

    final startPeriod = startMinutes < 720 ? 'AM' : 'PM';
    final endPeriod = endMinutes < 720 ? 'AM' : 'PM';
    final centerText = startPeriod == endPeriod
        ? startPeriod
        : '$startPeriod-$endPeriod';
    final centerTp = TextPainter(
      text: TextSpan(
        text: centerText,
        style: TextStyle(
          color: t.Theme.primaryText,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    centerTp.paint(
      canvas,
      center - Offset(centerTp.width / 2, centerTp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.startMinutes != startMinutes ||
        oldDelegate.endMinutes != endMinutes ||
        oldDelegate.activeHandle != activeHandle ||
        oldDelegate.occupiedSlots != occupiedSlots;
  }
}

Future<int?> _showManualTimeEditor({
  required BuildContext context,
  required String title,
  required int initialMinutes,
  required bool Function(int minutes) isValid,
}) {
  return showDialog<int>(
    context: context,
    barrierColor: t.Theme.tertiaryText.withOpacity(0.25),
    builder: (_) => _ManualTimeEditorDialog(
      title: title,
      initialMinutes: initialMinutes,
      isValid: isValid,
    ),
  );
}

class _ManualTimeEditorDialog extends StatefulWidget {
  final String title;
  final int initialMinutes;
  final bool Function(int minutes) isValid;

  const _ManualTimeEditorDialog({
    required this.title,
    required this.initialMinutes,
    required this.isValid,
  });

  @override
  State<_ManualTimeEditorDialog> createState() =>
      _ManualTimeEditorDialogState();
}

class _ManualTimeEditorDialogState extends State<_ManualTimeEditorDialog> {
  late int _hour12;
  late int _minute;
  late bool _isPm;

  static const int _minuteStep = 5;

  @override
  void initState() {
    super.initState();
    final h24 = (widget.initialMinutes ~/ 60) % 24;
    _minute = widget.initialMinutes % 60;
    _isPm = h24 >= 12;
    _hour12 = h24 % 12 == 0 ? 12 : h24 % 12;
  }

  int get _currentMinutes => ((_hour12 % 12) + (_isPm ? 12 : 0)) * 60 + _minute;

  void _shiftHour(int delta) {
    setState(() {
      _hour12 = ((_hour12 - 1 + delta) % 12 + 12) % 12 + 1;
    });
  }

  void _shiftMinute(int delta) {
    setState(() {
      _minute = ((_minute + delta * _minuteStep) % 60 + 60) % 60;
    });
  }

  Widget _stepperColumn({
    required String label,
    required String value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: t.Theme.quaternaryText),
        ),
        const SizedBox(height: 6),
        _StepperButton(icon: Icons.keyboard_arrow_up, onTap: onIncrement),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: t.Theme.primaryText,
            ),
          ),
        ),
        _StepperButton(icon: Icons.keyboard_arrow_down, onTap: onDecrement),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final valid = widget.isValid(_currentMinutes);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: t.Theme.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: t.Theme.shadow.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: t.Theme.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepperColumn(
                  label: 'HOUR',
                  value: _hour12.toString(),
                  onDecrement: () => _shiftHour(-1),
                  onIncrement: () => _shiftHour(1),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 34),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: t.Theme.primaryText,
                    ),
                  ),
                ),
                _stepperColumn(
                  label: 'MIN',
                  value: _minute.toString().padLeft(2, '0'),
                  onDecrement: () => _shiftMinute(-1),
                  onIncrement: () => _shiftMinute(1),
                ),
                const SizedBox(width: 16),
                _AmPmToggle(
                  isPm: _isPm,
                  onChanged: (value) => setState(() => _isPm = value),
                ),
              ],
            ),
            if (!valid) ...[
              const SizedBox(height: 14),
              Text(
                'That time overlaps a busy slot or the other handle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: _ClockPainter.occupiedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.Theme.outline, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: t.Theme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: valid
                        ? () => Navigator.of(context).pop(_currentMinutes)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.Theme.primary,
                      disabledBackgroundColor: t.Theme.tertiaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Set',
                      style: TextStyle(
                        color: t.Theme.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: t.Theme.onBackground.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: t.Theme.primaryText),
      ),
    );
  }
}

class _AmPmToggle extends StatelessWidget {
  final bool isPm;
  final ValueChanged<bool> onChanged;

  const _AmPmToggle({required this.isPm, required this.onChanged});

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? t.Theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? t.Theme.secondaryText : t.Theme.quaternaryText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: t.Theme.onBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment('AM', !isPm, () => onChanged(false)),
            const SizedBox(height: 3),
            _segment('PM', isPm, () => onChanged(true)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Example usage:
//
// final result = await showDurationTimePicker(
//   context: context,
//   occupiedSlots: const [
//     TimeSlot(startMinutes: 4 * 60, endMinutes: 5 * 60 + 30),
//     TimeSlot(startMinutes: 13 * 60, endMinutes: 14 * 60),
//   ],
//   initialSlot: const TimeSlot(startMinutes: 0, endMinutes: 180),
//   maxDurationMinutes: 300,   // ← 5-hour cap (optional, 300 is the default)
// );
// if (result != null) {
//   print('Selected: ${result.label} (${result.durationMinutes} min)');
// }
// ---------------------------------------------------------------------
