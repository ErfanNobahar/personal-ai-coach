import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/ui_kit/duration_picker_dlg.dart';
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
  Future<void> getTimes(String day) async {
    final res = await _repo.readByDay(day);
    final temp = res?.tasks
        .map(
          (e) => TimeSlot(
            startMinutes:
                int.parse(e.primaryTask.scheduledStartTime.split(':')[0]) * 60,
            endMinutes:
                int.parse(e.primaryTask.scheduledStartTime.split(':')[0]) * 60 +
                e.primaryTask.estimatedMinutes,
          ),
        )
        .toList();
    final ress = temp?.convertToInt;
    print('resssssssssssssssssssssssssssss');
    print(ress);
    emit(state.copyWith(occupiedTimes: temp ?? [...?temp]));
  }

  Future<void> getData() async {
    final res = await _repo.readSchedule();
    final temp = res.where((e) {
      // print('${e.day} vssssss ${T.DateFormater.formater(DateTime.now())}');
      return e.day == T.DateFormater.monthFormater(DateTime.now());
    }).first;

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

  void onTaskCreated(DayTask task) {
    if (task.date == '') {
      toast('Pick a date!!');
      return;
    }
    if (task.primaryTask.scheduledStartTime == '') {
      toast('Pick a time!!');
      return;
    }
    if (task.primaryTask.estimatedMinutes == 0) {
      toast('Pick a date!!');
      return;
    }
    emit(state.copyWith(task: task));
  }

  Future<void> onDateChanged(DateTime time) async {
    emit(state.copyWith(loading: true));
    final temp = T.DateFormater.dayFormater(time);
    final dateString = T.DateFormater.monthFormater(time);
    final currentTask = state.task;
    await getTimes(dateString);
    final updatedTask = currentTask != null
        ? currentTask.copyWith(date: dateString)
        : DayTask(
            date: dateString,
            status: DayTaskStatus.pending,
            scheduledTimeSlot: '',
            scheduledTimeLabel: '',
            primaryTask: PrimaryTask(
              title: '',
              description: '',
              scheduledStartTime: '',
              estimatedMinutes: 0,
              id: '',
              scheduledEndTime: '',
              type: '',
              whyItMatters: '',
              suggestedSearches: [],
            ),
            supportingTasks: [],
          );

    emit(state.copyWith(task: updatedTask, loading: false));
    print(updatedTask);
  }

  void onHourChanged(String hour) {
    emit(
      state.copyWith(
        task: state.task?.copyWith(
          primaryTask: state.task?.primaryTask.copyWith(
            scheduledStartTime: hour,
          ),
        ),
      ),
    );
    print(hour);
    print(state.task);
  }

  void onEstimatedTimeAssigned(TimeSlot slot) {
    emit(
      state.copyWith(
        task: state.task!.copyWith(
          primaryTask: state.task!.primaryTask.copyWith(
            scheduledStartTime:
                '${((slot.startMinutes ~/ 60).toString()).padLeft(2, '0')}:00',
            estimatedMinutes: slot.endMinutes - slot.startMinutes,
          ),
        ),
      ),
    );
    print('cukkkkkkkkkkkkkk;');
    print(state.task?.primaryTask.scheduledStartTime);
  }
  // Future<void> setTodaysStatus(){

  // }

  void selectDay(String day) {
    emit(state.copyWith(selectedDayIndex: day));
  }
}
