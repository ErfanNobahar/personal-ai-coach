import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class TimePickerDialog extends StatefulWidget {
  final int currentTime;
  final List<int> occupiedTimes;
  final Function(String)? onHourChanged;
  const TimePickerDialog({
    super.key,
    required this.currentTime,
    this.occupiedTimes = const [],
    this.onHourChanged,
  });

  static Future<dynamic> show(
    int currentTime, {
    List<int> occupiedTimes = const [],
    required BuildContext context,
  }) {
    print('occupiedTimessssss');
    print(occupiedTimes);
    return U.Dialog.show(
      TimePickerDialog(currentTime: currentTime, occupiedTimes: occupiedTimes),
      context: context,
      useRootNavigator: true,
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
  void didUpdateWidget(covariant TimePickerDialog oldWidget) {
    if (oldWidget.currentTime != widget.currentTime) {
      _selectedIndex = widget.currentTime;
      _controller.jumpToItem(_selectedIndex);
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('currentTime');
    print(widget.currentTime);
    return Container(
      decoration: BoxDecoration(
              color: U.Theme.white.withValues(alpha: 0.5),
borderRadius: BorderRadius.circular(15) 
      ),
      child: Column(
        children: [
          // SizedBox(height: 10),
          const U.Text(
            text: 'Select Hour',
            textWeight: U.TextWeight.semiBold,
            textSize: U.TextSize.s18,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center highlight bar
                Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Container(
                    height: 53,
                    decoration: BoxDecoration(
                      color: U.Theme.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: U.Theme.primary.withValues(alpha: 0.5),
                        width: 1,
                      ),
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
                            color:
                                (isSelected &&
                                    widget.occupiedTimes.contains(index))
                                ? U.Theme.primaryText.withValues(alpha: 0.3)
                                : U.Theme.primaryText,
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
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: U.OutlineButton(
                    // size: U.OutlineButtonSize.large,
                    title: 'Cancel',
                    onTap: () {
                      GoRouter.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: U.OutlineButton(
                    color: U.OutLineButtonColor.secondary,
                    foregroundColor: U.OutLineButtonForeground.secondary,
                    // size: U.OutlineButtonSize.large,
                    title: 'OK',
                    onTap: () {
                      if (widget.occupiedTimes.contains(_selectedIndex)) {
                        return;
                      }
                      widget.onHourChanged != null
                          ? widget.onHourChanged!(
                              '${_selectedIndex.toString().padLeft(2, '0')}:00',
                            )
                          : GoRouter.of(context).pop(
                              '${_selectedIndex.toString().padLeft(2, '0')}:00',
                            );
                    },
                  ),
                ),
                // onPressed: () => Navigator.pop(context, _selectedIndex),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
