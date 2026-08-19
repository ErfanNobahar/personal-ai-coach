import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/modules/ai_insight/cubit/ai_insight_cubit.dart';
import 'package:personal_ai_coach/modules/ai_insight/goal_tile.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class Goals extends StatelessWidget {
  const Goals({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 222,
      child: BlocBuilder<AiInsightCubit, AiInsightState>(
        builder: (context, state) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: U.Text(text: 'Your current goals :',textWeight: U.TextWeight.semiBold,textSize: U.TextSize.s16,),
              ),
              SizedBox(height: 8,),
              ...state.goals.map((e) => GoalTile(goal: e))],
          );
        },
      ),
    );
  }
}
