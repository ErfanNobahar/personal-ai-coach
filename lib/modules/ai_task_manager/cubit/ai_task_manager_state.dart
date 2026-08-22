part of 'ai_task_manager_cubit.dart';

class AiTaskManagerState extends Equatable {
  final bool loading;
  final List<Message> messages;
  final List<DayTask> modifiedTasks;
  final Map<int, ChatResponse> actions;
  final List<SpecificTasks> tasks;
  const AiTaskManagerState({
    required this.loading,
    required this.messages,
    required this.tasks,
    required this.actions,
    required this.modifiedTasks,
  });

  AiTaskManagerState.init()
    : tasks = [],
      loading = false,
      messages = [],
      modifiedTasks = [],
      actions = {};

  AiTaskManagerState copyWith({
    bool? loading,
    List<Message>? messages,
    Map<int, ChatResponse>? actions,
    List<SpecificTasks>? tasks,
    List<DayTask>? modifiedTasks,
  }) {
    return AiTaskManagerState(
      loading: loading ?? this.loading,
      messages: messages ?? this.messages,
      tasks: tasks ?? this.tasks,
      actions: actions ?? this.actions,
      modifiedTasks: modifiedTasks ?? this.modifiedTasks,
    );
  }

  @override
  List<Object?> get props => [loading, messages, tasks, actions, modifiedTasks];
}
