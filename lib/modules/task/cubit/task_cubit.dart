import 'package:bloc/bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final DayTask? task;
  TaskCubit({this.task}) : super(TaskState.init(task)) {}

void onScheduleChanged(){

}
}
