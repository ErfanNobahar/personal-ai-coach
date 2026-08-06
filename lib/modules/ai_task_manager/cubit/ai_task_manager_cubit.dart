import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'ai_task_manager_state.dart';

class AiTaskManagerCubit extends Cubit<AiTaskManagerState> {
  AiTaskManagerCubit() : super(AiTaskManagerInitial());
  final messageCtrl = TextEditingController();
}
