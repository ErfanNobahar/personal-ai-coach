part of 'task_cubit.dart';

class TaskState {
  final bool loading;
  final DayTask? task;
  TaskState({required this.loading, this.task});
  TaskState.init(this.task) : loading = false;

  TaskState copyWith({bool? loading, DayTask? task}) {
    return TaskState(loading: loading ?? this.loading, task: task ?? this.task);
  }
}
