part of 'ai_task_manager_cubit.dart';

enum ChattingStatus { enabled, disabled, clarifing }

class AiTaskManagerState extends Equatable {
  final bool loading;
  final ChattingStatus chattingStatus;
  final List<Message> messages;
  final Map<int, List<DayTask>> modifiedTasks;
  final Map<int, ChatResponse> actions;
  final List<SpecificTasks> tasks;
  const AiTaskManagerState({
    required this.loading,
    required this.messages,
    required this.tasks,
    required this.actions,
    required this.modifiedTasks,
    required this.chattingStatus,
  });

  AiTaskManagerState.init()
    : tasks = [],
      loading = false,
      chattingStatus = ChattingStatus.enabled,
      messages = [],
      modifiedTasks = {},
      actions = {};

  AiTaskManagerState copyWith({
    bool? loading,
    List<Message>? messages,
    Map<int, ChatResponse>? actions,
    List<SpecificTasks>? tasks,
    Map<int, List<DayTask>>? modifiedTasks,
    ChattingStatus? chattingStatus,
  }) {
    return AiTaskManagerState(
      loading: loading ?? this.loading,
      messages: messages ?? this.messages,
      tasks: tasks ?? this.tasks,
      actions: actions ?? this.actions,
      modifiedTasks: modifiedTasks ?? this.modifiedTasks,
      chattingStatus: chattingStatus ?? this.chattingStatus,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    messages,
    tasks,
    actions,
    modifiedTasks,
    chattingStatus,
  ];
}
