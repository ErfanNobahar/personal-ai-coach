import 'package:flutter/widgets.dart';
import 'package:personal_ai_coach/modules/ai_insight/goal_tile.dart';

class Goals extends StatelessWidget {
  const Goals({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox
    (
      height: 222,
      child: ListView(children: [Expanded(child: GoalTile())]));
  }
}
