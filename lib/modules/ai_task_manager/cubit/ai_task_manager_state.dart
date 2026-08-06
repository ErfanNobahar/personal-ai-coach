part of 'ai_task_manager_cubit.dart';

sealed class AiTaskManagerState extends Equatable {
  const AiTaskManagerState();

  @override
  List<Object> get props => [];
}

final class AiTaskManagerInitial extends AiTaskManagerState {}
