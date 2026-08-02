part of 'schedule_cubit.dart';

enum ScheduleStatus { empty, filled }

class ScheduleState {
  final bool loading;
  final DayTask? task;
  final ScheduleStatus status;
  final List<SpecificTasks> dailyTasks;
  final List<TimeSlot> occupiedTimes;
  final SpecificTasks? selectedDay;
  final String selectedDayIndex;
  ScheduleState({
    required this.loading,
    required this.task,
    required this.status,
    required this.dailyTasks,
    required this.selectedDay,
    required this.selectedDayIndex,
    required this.occupiedTimes,
  });

  ScheduleState.init(this.dailyTasks)
    : loading = false,
      task = null,
      occupiedTimes = [],
      status = ScheduleStatus.empty,
      selectedDay = null,
      selectedDayIndex = '';

  ScheduleState copyWith({
    bool? loading,
    DayTask? task,
    ScheduleStatus? status,
    List<SpecificTasks>? dailyTasks,
    List<TimeSlot>? occupiedTimes,
    String? selectedDayIndex,
    SpecificTasks? selectedDay,
  }) {
    return ScheduleState(
      loading: loading ?? this.loading,
      status: status ?? this.status,
      task: task ?? this.task,
      dailyTasks: dailyTasks ?? this.dailyTasks,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      occupiedTimes: occupiedTimes ?? this.occupiedTimes,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}
