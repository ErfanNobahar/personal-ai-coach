import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';

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

  void onInit() async {
    emit(state.copyWith(loading: true));
    final res = await _repo.readSchedule();
    emit(state.copyWith(loading: false, dailyTasks: res, selectedDay: res[0]));
  }

  void onPageCountChanged(double count) {
    
    // emit(state.copyWith(selectedDay: state.dailyTasks[count.floor()]));
    // print('state.selectedDay');
    // print(count);
  }

  void selectDay(String day) {
    emit(state.copyWith(selectedDayIndex: day));
  }
}
