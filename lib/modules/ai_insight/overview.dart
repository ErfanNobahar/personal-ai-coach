import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/modules/ai_insight/cubit/ai_insight_cubit.dart';
import 'package:personal_ai_coach/modules/ai_insight/overview_card.dart';

class Overview extends StatelessWidget {
  const Overview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiInsightCubit, AiInsightState>(
      builder: (context, state) {
        return ListView(children: [OverviewCard(tasks: state.weeklyTasks)]);
      },
    );
  }
}
