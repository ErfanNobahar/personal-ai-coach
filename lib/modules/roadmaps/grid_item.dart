import 'package:flutter/widgets.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class GridItem extends StatelessWidget {
  final Roadmap roadmap;
  const GridItem({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: U.Theme.neutral,
        border: Border.all(
          width: 1,
          color: U.Theme.divider.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentGeometry.xy(0, -0.1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                color: U.Theme.outline,
              ),
              child: U.Text(text: '2026/12'),
            ),
          ),
          U.Text(text: roadmap.goal, textSize: U.TextSize.s14),
          SizedBox(height: 5),
          U.Text(
            text: roadmap.summary,
            textSize: U.TextSize.s14,
            overFlow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              U.Text(text: roadmap.type),
              U.Image.icon(path: U.Icons.create, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
