import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class GoalTile extends StatelessWidget {
  const GoalTile({super.key, this.value = 12});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1,color: U.Theme.primaryBorder),
          borderRadius: BorderRadius.circular(15),
          color: U.Theme.surfaceLight,
        ),
        height: 100,
        width: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                width: 60,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      showLabels: false,
                      showTicks: false,
                      startAngle: 270,
                      endAngle: 270,
                      axisLineStyle: const AxisLineStyle(
                        thickness: 1,
                        color: U.Theme.onBackground,
                        thicknessUnit: GaugeSizeUnit.factor,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: value,
                          width: 0.15,
                          color: U.Theme.outlineHigh,
                          pointerOffset: 0.1,
                          cornerStyle: CornerStyle.bothCurve,
                          sizeUnit: GaugeSizeUnit.factor,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: U.Text(text: '${value.toInt()}%',
                          textSize: U.TextSize.s16,textWeight: U.TextWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            U.Text(text: 'text'),
          ],
        ),
      ),
    );
  }
}
