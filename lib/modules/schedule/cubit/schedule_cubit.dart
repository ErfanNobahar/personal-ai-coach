import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final BusinessRepository _repo;
  final List<SpecificTasks>? initialTasks;
  final ScrollController tabCtril = ScrollController();
  final PageController pageCtrl = PageController();
  ScheduleCubit({required BusinessRepository repo, this.initialTasks})
    : _repo = repo,
      super(ScheduleState.init(initialTasks ?? [])) {
    onInit();
  }

  final taskDescriptionCtrl = TextEditingController();
  final taskTitleCtrl = TextEditingController();
  /////////// Functions

  Future<void> getData() async {
    final res = await _repo.readSchedule();
    final temp = res
        .where((e) => e.day == T.DateFormater.formater(DateTime.now()))
        .first;
    final updatedSpecificTasks = temp.copyWith(
      tasks: temp.tasks
          .map(
            (e) => e.copyWith(
              status:
                  (e.status != DayTaskStatus.completed &&
                      DateTime.now().hour >
                          int.parse(
                            e.primaryTask.scheduledStartTime.split(':')[0],
                          ))
                  ? DayTaskStatus.skipped
                  : e.status,
            ),
          )
          .toList(),
    );
    final int index = res.indexWhere((element) => element.day == temp.day);
    res.removeAt(index);
    res.insert(index, updatedSpecificTasks);
    await _repo.updateDays(res);
    emit(state.copyWith(dailyTasks: res, selectedDay: res[0]));
  }

  /////////// Methods
  void onInit() async {
    emit(state.copyWith(loading: true));
    await getData();
    emit(state.copyWith(loading: false));
  }

  void onRefresh() async {
    emit(state.copyWith(loading: true));
    await getData();
    emit(state.copyWith(loading: false));
  }

  void onPageCountChanged(double count) {
    // emit(state.copyWith(selectedDay: state.dailyTasks[count.floor()]));
    // print('state.selectedDay');
    // print(count);
  }

  // Future<void> setTodaysStatus(){

  // }

  void selectDay(String day) {
    emit(state.copyWith(selectedDayIndex: day));
  }
}
