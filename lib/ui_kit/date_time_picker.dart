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
      children: [
        InkWell(
          onTap: () {
            isExpanded = !isExpanded;
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(8),
            // height: 22,
            // width: 22,
            child: U.Text(text: 'Pick a time'),
          ),
        ),
        if(isExpanded)
        FadeInDown(
          from: 10,
          duration: Duration(milliseconds: 300),
          child: FadeInLeft(
            duration: Duration(milliseconds: 300),
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
      ],
    );
  }
}
