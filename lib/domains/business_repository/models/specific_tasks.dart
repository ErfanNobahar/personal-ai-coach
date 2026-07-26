import 'package:equatable/equatable.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

class SpecificTasks extends Equatable {
  final String day;
  final List<DayTask> tasks;
  const SpecificTasks({required this.day, required this.tasks});

  SpecificTasks addToList({required DayTask task}) {
    tasks.add(task);
    List<DayTask> newtasks = [...tasks];
    return SpecificTasks(day: day, tasks: newtasks);
  }

  SpecificTasks copyWith({String? day, List<DayTask>? tasks}) {
    return SpecificTasks(day: day ?? this.day, tasks: tasks ?? this.tasks);
  }

factory SpecificTasks.fromMap(Map<String, dynamic> map) {
    return SpecificTasks(
      day: map['day'],
      tasks: List.from(map['tasks'] ?? [])
          .map((e) => DayTask.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'tasks': List.from(tasks).map((e) => e.toMap()).toList(),
    };
  }
  
  @override
  List<Object?> get props => [day,tasks];
}
