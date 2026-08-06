import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final BusinessRepository _repo;
  final DayTask? task;
  TaskCubit({this.task, required BusinessRepository repo})
    : _repo = repo,
      super(TaskState.init(task)) {
    onInit();
  }

  /////////// Functions
  Future<SpecificTasks> readTask() async {
    final res = await _repo.readTask(task!);
    return res;
  }

  Future<List<String>> getTimes() async {
    final res = await readTask();
    final temp = res.tasks
        .map((e) => e.primaryTask.scheduledStartTime)
        .toList();
    emit(state.copyWith(occupiedTimes: temp));
    return temp;
  }

  //////// Events
  void onInit() async {
    emit(state.copyWith(loading: true));
    await getTimes();
    emit(state.copyWith(loading: false));
  }

  Future<void> onTaskDeleted() async {
    emit(state.copyWith(loading: true));
    await _repo.deleteTask(state.task!);
    emit(state.copyWith(loading: false, task: null));
  }

  void onScheduleChanged(DayTask task) async {
    emit(state.copyWith(loading: true, task: task));
    await _repo.updateTasks(task);
    await getTimes();
    emit(state.copyWith(loading: false));
  }

  Future<void> onStatusChanged(DayTask task) async {
    emit(state.copyWith(loading: true));
    await _repo.updateTasks(task);
    emit(state.copyWith(loading: false, task: task));
  }
}
