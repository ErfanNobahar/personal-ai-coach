import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:personal_ai_coach/modules/roadmap/roadmap_page.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class GridItem extends StatelessWidget {
  final Roadmap roadmap;
  const GridItem({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('roadmap.milestones[0].startWeek');
        // print(roadmap.[0]);
        // print(roadmap.milestones[0].weeklyObjectives[1].week);
        // print(roadmap.milestones[1].startWeek);
        GoRouter.of(
          context,
        ).pushNamed(RoadmapPage.route, extra: {'roadMap': roadmap});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        decoration: BoxDecoration(
          color: U.Theme.neutral,
          border: Border.all(
            width: 1,
            color: U.Theme.divider.withValues(alpha: 0.6),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: AlignmentGeometry.xy(1.2, 0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  color: U.Theme.outline,
                ),
                child: U.Text(
                  text: '2026/12',
                  color: U.Theme.white,
                  textSize: U.TextSize.s12,
                  textWeight: U.TextWeight.bold,
                ),
              ),
            ),
            U.Text(text: roadmap.goal, textSize: U.TextSize.s14),
            SizedBox(height: 5),
            Flexible(
              child: U.Text(
                text: roadmap.summary,
                textSize: U.TextSize.s12,
                softWrap: true,
                textWeight: U.TextWeight.sm,
                // maxLines: 3,
                // overFlow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                U.Text(
                  text: roadmap.type,
                  textSize: U.TextSize.s12,
                  textWeight: U.TextWeight.bold,
                ),
                U.Image.icon(path: U.Icons.create, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
