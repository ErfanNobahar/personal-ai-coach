part of 'schedule_cubit.dart';

enum ScheduleStatus { empty, filled }

class ScheduleState {
  final bool loading;
  final ScheduleStatus status;
  final List<SpecificTasks> dailyTasks;
  final SpecificTasks? selectedDay;
  final String selectedDayIndex;
  ScheduleState({
    required this.loading,
    required this.status,
    required this.dailyTasks,
    required this.selectedDay,
    required this.selectedDayIndex,
  });

  ScheduleState.init(this.dailyTasks)
    : loading = false,
      status = ScheduleStatus.empty,
      selectedDay = null,
      selectedDayIndex = '';

  ScheduleState copyWith({
    bool? loading,
    ScheduleStatus? status,
    List<SpecificTasks>? dailyTasks,
    String? selectedDayIndex,
    SpecificTasks? selectedDay,
  }) {
    return ScheduleState(
      loading: loading ?? this.loading,
      status: status ?? this.status,
      dailyTasks: dailyTasks ?? this.dailyTasks,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}
