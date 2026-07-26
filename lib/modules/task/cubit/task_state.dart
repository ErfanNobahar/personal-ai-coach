part of 'task_cubit.dart';

class TaskState {
  final bool loading;
  final DayTask? task;
  final List<String> occupiedTimes;
  TaskState({required this.loading, this.task, required this.occupiedTimes});
  TaskState.init(this.task) : occupiedTimes = [], loading = false;

  TaskState copyWith({
    bool? loading,
    DayTask? task,
    List<String>? occupiedTimes,
  }) {
    return TaskState(
      loading: loading ?? this.loading,
      task: task ?? this.task,
      occupiedTimes: occupiedTimes ?? this.occupiedTimes,
    );
  }
}
