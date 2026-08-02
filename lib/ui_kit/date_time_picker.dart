import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/modules/schedule/cubit/schedule_cubit.dart';
import 'package:personal_ai_coach/ui_kit/duration_picker_dlg.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;

class DateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateChanged;

  const DateTimePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  bool isTimeExpanded = true;
  bool isHourExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return BlocListener<ScheduleCubit, ScheduleState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, state) {
            print('state.tasksjpoijpoijpoikjnpoikjp\n');
            print('${state.task?.toMap()}\n');
            // TODO: implement listener
          },
          child: BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              print('==================================');
              print('${state.task?.primaryTask.scheduledStartTime == ''} vs  ');
              // print(state.task?.primaryTask.scheduledStartTime);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 70,
                        child: Align(
                          alignment: AlignmentGeometry.centerStart,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedPositioned(
                                // right: isExpanded ?  -35 : 0  ,
                                left: isTimeExpanded ? 75 : 0,
                                right: isTimeExpanded ? -75 : 0,
                                // bottom: -2,
                                duration: Duration(milliseconds: 300),
                                child: U.OutlineButton(
                                  title: 'schedule',
                                  onTap: () {},
                                  align: MainAxisAlignment.end,
                                ),
                              ),
                              U.Button(
                                size: MainAxisSize.max,
                                buttonColor: U.ButtonColor.primary,
                                title: state.task == null
                                    ? 'Pick a Time'
                                    : state.task!.date,
                                onTap: () {
                                  isTimeExpanded = !isTimeExpanded;
                                  isHourExpanded = false;
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
                                      turns: isTimeExpanded
                                          ? 0.5
                                          : 0, // 0.5 turns = 180°
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
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
                      ),
                      Expanded(flex: 30, child: SizedBox()),
                      constraints.maxWidth < 450
                          ? SizedBox()
                          : SizedBox(
                              width: 155,
                              child: U.OutlineButton(
                                disabled:
                                    context.read<ScheduleCubit>().state.task ==
                                    null,
                                align: MainAxisAlignment.center,
                                leading: U.Image.icon(
                                  path: U.Icons.calendar,
                                  size: 20,
                                ),
                                title:
                                    (state
                                                .task
                                                ?.primaryTask
                                                .scheduledStartTime ==
                                            '' ||
                                        state.task?.primaryTask == null)
                                    ? 'pick an hour'
                                    : state
                                          .task!
                                          .primaryTask
                                          .scheduledStartTime,
                                onTap: () {
                                  isHourExpanded = !isHourExpanded;
                                  isTimeExpanded = false;
                                  setState(() {});
                                },
                              ),
                            ),
                    ],
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(
                          -0.1,
                          0,
                        ), // matches FadeInLeft's direction
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: isTimeExpanded && !isHourExpanded
                        ? Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: U.Theme.secondaryButton.withValues(alpha: 0.3),
                                  ),
                                  child: CalendarDatePicker(
                                    key: const ValueKey(
                                      'calendar',
                                    ), // key is required!
                                    initialDate: widget.initialDate,
                                    firstDate: widget.firstDate,
                                    lastDate: widget.lastDate,
                                    onDateChanged: widget.onDateChanged,
                                  ),
                                ),
                              ),
                              if (state.loading)
                                Positioned.fill(
                                  child: Container(
                                    color: U.Theme.white.withValues(alpha: 0.4),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('calendar-empty'),
                          ),
                  ),

                  constraints.maxWidth > 450
                      ? SizedBox()
                      : Column(
                          children: [
                            SizedBox(height: 15),
                            AnimatedSize(
                              duration: Duration(milliseconds: 300),
                              child: U.OutlineButton(
                                disabled:
                                    context.read<ScheduleCubit>().state.task ==
                                    null,
                                align: MainAxisAlignment.center,
                                leading: U.Image.icon(
                                  path: U.Icons.calendar,
                                  size: 20,
                                ),
                                title:
                                    (state
                                                .task
                                                ?.primaryTask
                                                .scheduledStartTime ==
                                            '' ||
                                        state.task?.primaryTask == null)
                                    ? 'pick an hour'
                                    : state
                                          .task!
                                          .primaryTask
                                          .scheduledStartTime,

                                onTap: () {
                                  isHourExpanded = !isHourExpanded;
                                  isTimeExpanded = false;
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(
                          0.1,
                          0,
                        ), // matches FadeInRight's direction
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: !isTimeExpanded && isHourExpanded
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 18.0,
                            ),
                            child: SizedBox(
                              key: const ValueKey('hour-picker'),
                              height: 332,
                              child: U.DashedBox(
                                showScissors: false,
                                child: U.TimePickerDialog(
                                  occupiedTimes:
                                      state.occupiedTimes.convertToInt,
                                  currentTime:
                                      state
                                              .task
                                              ?.primaryTask
                                              .scheduledStartTime ==
                                          ''
                                      ? 10
                                      : int.parse(
                                          (state
                                                  .task!
                                                  .primaryTask
                                                  .scheduledStartTime)
                                              .split(':')[0],
                                        ),
                                  onHourChanged: context
                                      .read<ScheduleCubit>()
                                      .onHourChanged,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('hour-picker-empty'),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
