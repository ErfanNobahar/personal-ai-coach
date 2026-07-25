import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TimePickerDialog extends StatefulWidget {
  final int currentTime;
  const TimePickerDialog({super.key, required this.currentTime});

  static Future<dynamic> show(
    int currentTime, {
    required BuildContext context,
  }) {
    return U.Dialog.show(
      TimePickerDialog(currentTime: currentTime),
      context: context,
    );
  }

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  late final FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentTime;
    _controller = FixedExtentScrollController(initialItem: widget.currentTime);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select Hour',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center highlight bar
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: U.Theme.primary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: U.Theme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),

              // The scroll wheel
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: 56, // Height of each row
                perspective: 0.005, // 3D cylinder curve
                diameterRatio: 1.4, // How "round" the wheel feels
                overAndUnderCenterOpacity: 0.35, // Fade top/bottom
                physics: const FixedExtentScrollPhysics(), // Snaps to center
                onSelectedItemChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 24,
                  builder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.center,
                      child: Text(
                        '${index.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          fontSize: isSelected ? 26 : 20,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(1.0),
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedIndex),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

