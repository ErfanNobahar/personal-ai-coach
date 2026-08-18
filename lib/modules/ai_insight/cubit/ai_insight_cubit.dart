import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/tool_kit/tool_kit.dart' as T;
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';

part 'ai_insight_state.dart';

class AiInsightCubit extends Cubit<AiInsightState> {
  final BusinessRepository _repo;
  AiInsightCubit({required BusinessRepository repo})
    : _repo = repo,
      super(AiInsightState.init()) {
    onInit();
  }
  //////////////////// Functions
  Future<List<SpecificTasks>> getTasks() async {
    final d = DateTime.now();
    final res = await _repo.readSchedule();
    print('res.length');
    print(res.length);
    final List<SpecificTasks> mondaysList = res.where((e) {
      print(T.DateFormater.dateFromString(e.day).day);
      print(DateTime.monday);
      return T.DateFormater.dateFromString(e.day).weekday == DateTime.monday;
    }).toList();
    final temp = mondaysList.where((e) {
      print('T.DateFormater.dateFromString(e.day).day');
      print(T.DateFormater.dateFromString(e.day).day);
      return (((DateTime.now().day - T.DateFormater.dateFromString(e.day).day) <
              7) &&
          DateTime.now().day - T.DateFormater.dateFromString(e.day).day > 0);
    }).firstOrNull;
    final dayIndex = res.indexWhere((e) => e == temp);
    //  final delta = (d.weekday - DateTime.monday) % 7; // days since Monday
    // final adjusted = delta > 3 ? delta - 7 : delta;  // wrap to nearest
    final delta = (d.weekday - DateTime.monday) % 7;
    final day = d.subtract(Duration(days: delta == 0 ? 7 : delta));
    final list = res.indexWhere((e) {
      print(
        '${T.DateFormater.dateFromString(e.day).weekday} vssssssss ${day.weekday}',
      );
      return T.DateFormater.dateFromString(e.day).weekday == day.weekday;
    });
    print('list');
    print(list);
    List<SpecificTasks> finalList;
    final nextMonday = d.subtract(
      Duration(days: (d.weekday - DateTime.monday) % 7),
    );
    final nextindex = res.indexWhere((e) {
      return T.DateFormater.dateFromString(e.day).weekday == nextMonday.weekday;
    });
    (temp == null)
        ? finalList = res.getRange(0, nextindex).toList()
        : finalList = res
              .getRange(
                dayIndex,
                dayIndex + 7 > res.length ?res.length-1:dayIndex + 7 ,
                // list + 7 > res.length ? res.length : list + 7
              )
              .toList();
    return finalList;
  }

  ///////////////////// Events
  void onInit() async {
    final tasks = await getTasks();
    emit(state.copyWith(weeklyTasks: tasks));
  }
}
