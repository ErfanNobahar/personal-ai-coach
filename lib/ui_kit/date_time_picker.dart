import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class DateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  // final Function(DateTime) onDateChanged;

  const DateTimePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    // required this.onDateChanged,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentGeometry.centerStart,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                // right: isExpanded ?  -35 : 0  ,
                left: isExpanded ? 75 : 0,
                right: isExpanded ? -75 : 0,
                // bottom: -2,
                duration: Duration(milliseconds: 300),
                child: U.OutlineButton(
                  title: 'schedule',
                  onTap: () {},
                  align: MainAxisAlignment.end,
                ),
              ),
              U.Button(
                buttonColor: U.ButtonColor.primary,
                title: 'Pick a Time',
                onTap: () {
                  isExpanded = !isExpanded;
                  setState(() {});
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    U.Image.icon(
                      color: U.Theme.primaryText,

                      path: U.Icons.calendar,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0, // 0.5 turns = 180°
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: U.Image.icon(
                        color: U.Theme.primaryText,
                        path: U.Icons.down,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // InkWell(
        //   onTap: () {
        //     isExpanded = !isExpanded;
        //     setState(() {});
        //   },
        //   child: Container(
        //     padding: EdgeInsets.all(8),
        //     // height: 22,
        //     // width: 22,
        //     child: U.Text(text: 'Pick a time'),
        //   ),
        // ),
        if (isExpanded)
          FadeInDown(
            from: 10,
            duration: Duration(milliseconds: 300),
            child: FadeInLeft(
              duration: Duration(milliseconds: 300),
              child: SizedBox(
                // height: 252,
                child: CalendarDatePicker(
                  initialDate: widget.initialDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (value) {
                    print(value);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
