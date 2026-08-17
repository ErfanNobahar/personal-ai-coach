import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/ai_insight/ai_insights_page.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/task_manger_page.dart';
import 'package:personal_ai_coach/modules/chat/chat_page.dart';
import 'package:personal_ai_coach/modules/home/home.dart';
import 'package:personal_ai_coach/modules/roadmap/roadmap_page.dart';
import 'package:personal_ai_coach/modules/roadmaps/roadmaps_page.dart';
import 'package:personal_ai_coach/modules/schedule/schedule_page.dart';
import 'package:personal_ai_coach/modules/schedule/task_creation_dlg.dart';
import 'package:personal_ai_coach/modules/task/task_page.dart';

final rootNavKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: SchedulePage.route,
  navigatorKey: rootNavKey,
  redirect: (context, state) {
    // print('state.fullPath');
    // print(state.name);
    // print(state.);
  },
  routes: [
    // GoRoute(
    //   path: Chat.route,
    //   name: Chat.route,
    //   builder: (context, state) => Chat(),
    // ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeSell(child: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: SchedulePage.route,
              name: SchedulePage.route,
              builder: (context, state) {
                return SchedulePage(initialTasks: state.extra as dynamic);
              },
              routes: [
                GoRoute(
                  path: TaskDetailPage.route,
                  name: TaskDetailPage.route,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return TaskDetailPage(
                      inComingRoute: extra['path'] as String?,
                      milestoneTitle: extra['milestone'] as String?,
                      initialTask: extra['task'] as dynamic,
                      scheduleCubit: extra['cubit'] as dynamic,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: TaskCreationPage.route,
              name: TaskCreationPage.route,
              builder: (context, state) {
                return TaskCreationPage(task: state.extra as dynamic);
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AiInsightsPage.route,
              name: AiInsightsPage.route,
              builder: (context, state) {
                return AiInsightsPage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: ChatPge.route,
              name: ChatPge.route,
              builder: (context, state) => ChatPge(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: TaskMangerPage.route,
              name: TaskMangerPage.route,
              builder: (context, state) {
                return TaskMangerPage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoadmapsPage.route,
              name: RoadmapsPage.route,
              builder: (context, state) {
                return RoadmapsPage();
              },
            ),
          ],
        ),
      ],
    ),
    // ShellRoute(
    //   builder: (context, state, child) {
    //     return HomeSell(child: child);
    //   },
    //   routes: [GoRoute(path: Chat.route, name: Chat.route,
    //   builder: (context, state) => Chat(),
    //   )],
    // ),
  ],
);
