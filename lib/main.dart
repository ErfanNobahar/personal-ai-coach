import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:personal_ai_coach/data_providers/business_ws/business_ws.dart';
import 'package:personal_ai_coach/data_providers/hive/hive_db.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/modules/app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDB.init(appName: 'ai coach');
  BusinessWs.Init(onUnauthorized: () {}, onError: (message) {});
  final businessRepo = await BusinessRepository.init();
  runApp(
    RepositoryProvider(
      create: (context) => businessRepo,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          // physics: BouncingScrollPhysics(),
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.invertedStylus,
          },
        ),
      ),
    );
  }
}
