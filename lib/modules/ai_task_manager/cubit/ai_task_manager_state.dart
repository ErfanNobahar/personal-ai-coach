part of 'ai_task_manager_cubit.dart';

class AiTaskManagerState extends Equatable {
  final bool loading;
  final List<Message> messages;
  final List<SpecificTasks> tasks;
  const AiTaskManagerState({
    required this.loading,
    required this.messages,
    required this.tasks,
  });

  AiTaskManagerState.init() : tasks = [], loading = false, messages = [];

  AiTaskManagerState copyWith({
    bool? loading,
    List<Message>? messages,
    List<SpecificTasks>? tasks,
  }) {
    return AiTaskManagerState(
      loading: loading ?? this.loading,
      messages: messages ?? this.messages,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [loading, messages, tasks];
}
