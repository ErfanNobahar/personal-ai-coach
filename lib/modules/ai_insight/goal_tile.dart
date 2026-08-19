import 'package:flutter/material.dart';
import 'package:personal_ai_coach/domains/business_repository/models/goal.dart';
import 'package:personal_ai_coach/domains/business_repository/models/roadmap.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class GoalTile extends StatelessWidget {
  final Goal goal;
  const GoalTile({super.key, this.value = 12, required this.goal});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: 2,
              color: const Color.fromARGB(78, 201, 200, 200),
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
          border: Border.all(width: 1, color: U.Theme.primaryBorder),
          borderRadius: BorderRadius.circular(15),
          color: U.Theme.onBackground,
        ),
        // height: 100,
        // width: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                  width: 70,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        showLabels: false,
                        showTicks: false,
                        startAngle: 270,
                        endAngle: 270,
                        axisLineStyle: AxisLineStyle(
                          thickness: 1,
                          color: U.Theme.surface.withValues(alpha: 0.6),
                          thicknessUnit: GaugeSizeUnit.factor,
                        ),
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: goal.roadmap!
                                .getProgress(goal.roadmap!)
                                .toDouble(),
                            width: 0.15,
                            color: U.Theme.outlineHigh,
                            pointerOffset: 0.1,
                            cornerStyle: CornerStyle.bothCurve,
                            sizeUnit: GaugeSizeUnit.factor,
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: U.Text(
                              text:
                                  '${goal.roadmap!.getProgress(goal.roadmap!).toString()}%',
                              textSize: U.TextSize.s14,
                              textWeight: U.TextWeight.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: U.Text(
                      maxLines: 2,
                      overFlow: TextOverflow.ellipsis,
                      // softWrap: true,
                      text: goal.roadmap!.goal,
                      textSize: U.TextSize.s14,
                      textWeight: U.TextWeight.semiBold,
                    ),
                  ),
                ),
                // Spacer(),
                U.Text(
                  text: 'Ai insights!',
                  textSize: U.TextSize.s12,
                  textWeight: U.TextWeight.sm,
                  color: U.Theme.quaternaryText,
                ),
                SizedBox(width: 4),
                U.Image.icon(path: U.Icons.ai, size: 20),
                // SizedBox(width: 12,),
                // Expanded(
                //   flex: 15,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     mainAxisSize: MainAxisSize.min,
                //     children: [

                //     ],
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
