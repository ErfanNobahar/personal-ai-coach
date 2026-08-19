import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/ai_insight/cubit/ai_insight_cubit.dart';
import 'package:personal_ai_coach/modules/ai_insight/goals.dart';
import 'package:personal_ai_coach/modules/ai_insight/history.dart';
import 'package:personal_ai_coach/modules/ai_insight/overview.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class AiInsightsPage extends StatelessWidget {
  static String route = '/ai-insights';
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AiInsightCubit(repo: context.read<BusinessRepository>()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: U.Theme.afternoonPallet.getColors,
              begin: AlignmentGeometry.topCenter,
              end: AlignmentGeometry.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              U.AppBar(title: 'AI Insights'),
              Expanded(
                child: U.ScrollableTabview(
                  headerHeight: 70,
                  headers: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: U.Theme.primary,
                        ),
                        child: Center(
                          child: U.Text(
                            color: U.Theme.secondaryText,
                            text: 'Current Week',
                            textWeight: U.TextWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: U.Theme.primary,
                        ),
                        child: Center(
                          child: U.Text(
                            color: U.Theme.secondaryText,
                            text: 'Goals',
                            textWeight: U.TextWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: U.Theme.primary,
                        ),
                        child: Center(
                          child: U.Text(
                            color: U.Theme.secondaryText,
                            text: 'History',
                            textWeight: U.TextWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  pages: [
                    Overview(),
                    Expanded(child: Goals()),
                    History(),
                  ],
                  tabController: ScrollController(),
                  pageController: PageController(),
                  onPageCountChanged: (s) {},
                ),
              ),
              // SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
