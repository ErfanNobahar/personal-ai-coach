part of 'task_cubit.dart';

class TaskState extends Equatable {
  final bool loading;
  final DayTask? task;
  final List<String> occupiedTimes;
  const TaskState({
    required this.loading,
    this.task,
    required this.occupiedTimes,
  });
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

  @override
  List<Object?> get props => [loading, task, occupiedTimes];
}
