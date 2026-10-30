import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/cubit/ai_task_manager_cubit.dart';
import 'package:personal_ai_coach/modules/ai_task_manager/message_field.dart';
import 'package:personal_ai_coach/modules/roadmap/roadmap_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:personal_ai_coach/domains/business_repository/business_repository.dart';
import 'package:personal_ai_coach/domains/business_repository/models/message.dart';
import 'package:personal_ai_coach/modules/chat/chat_bubble.dart';
import 'package:personal_ai_coach/modules/chat/cubit/chat_cubit.dart';
import 'package:personal_ai_coach/modules/chat/goal_textfield.dart';
import 'package:personal_ai_coach/ui_kit/outline_button.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class ChatPge extends StatefulWidget {
  static final route = '/chat';

  const ChatPge({super.key});

  @override
  State<ChatPge> createState() => _ChatPgeState();
}

class _ChatPgeState extends State<ChatPge> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int _lastItemCount = 0;

  void _scrollToLast(int itemCount) {
    if (itemCount <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_itemScrollController.isAttached) return;

        _itemScrollController.scrollTo(
          index: itemCount - 1,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatCubit(repository: context.read<BusinessRepository>()),
      child: BlocConsumer<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.loading &&
            !current.loading &&
            current.questions.isNotEmpty,
        listener: (context, state) {
          // +1 for the leading "message" bubble, +1 for the trailing spacer
          final itemCount = state.questions.length + 2;
          if (itemCount != _lastItemCount) {
            _lastItemCount = itemCount;
            _scrollToLast(itemCount);
          }
        },
        builder: (context, state) {
          final chatCubit = context.read<ChatCubit>();
          return
          // state.loading
          //     ? const Center(child: CircularProgressIndicator())
          //     :
          state.questions.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: U.Theme.afternoonPallet.getColors,
                      begin: AlignmentGeometry.topCenter,
                      end: AlignmentGeometry.bottomCenter,
                    ),
                  ),
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    padding: const EdgeInsets.all(24),
                    // index 0: message bubble
                    // 1..n: each question block
                    // last: trailing spacer
                    itemCount: state.questions.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ChatBubble(
                          text: state.messages[0].content,
                          rtl: true,
                        );
                      }

                      if (index == state.questions.length + 1) {
                        return const SizedBox(height: 124);
                      }

                      final key = index - 1;
                      final value = state.questions[key];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          !value.isCompleted
                              ? Column(
                                  children: [
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: ChatBubble(
                                        text: value.description!,
                                      ),
                                    ),
                                    const SizedBox(height: 19),
                                    ...value.questions.expand((e) {
                                      final res = state.selectedQuestions.where(
                                        (b) => b.id == e.id,
                                      );
                                      return [
                                        Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: 80,
                                                child: U.OutlineButton(
                                                  title: e.label,
                                                  disabled:
                                                      key <
                                                      state.questions.length -
                                                          1,
                                                  foregroundColor:
                                                      res.isNotEmpty
                                                      ? OutLineButtonForeground
                                                            .secondary
                                                      : OutLineButtonForeground
                                                            .primary,
                                                  onTap: () async {
                                                    await chatCubit
                                                        .onGoalCreated(
                                                          message: Message.user(
                                                            content: e.label,
                                                          ),
                                                        );

                                                    chatCubit.onAnswerSelected(
                                                      e,
                                                    );
                                                  },
                                                ),
                                              ),
                                              const Flexible(
                                                flex: 20,
                                                child: SizedBox(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ];
                                    }),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const ChatBubble(
                                      text:
                                          'congrates click to get your roadmap!',
                                    ),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      width: 207,
                                      child: U.Button(
                                        title: 'roadmap',
                                        onTap: () async {
                                          final res = await context
                                              .read<ChatCubit>()
                                              .onRoadmapGenrated();
                                          GoRouter.of(context).pushNamed(
                                            RoadmapPage.route,
                                            extra: {
                                              'goal': context
                                                  .read<ChatCubit>()
                                                  .state
                                                  .goal,
                                              'roadMap': res,
                                            },
                                          );
                                          // final res = await chatCubit
                                          //     .onRoadmapGenrated();
                                          // GoRouter.of(context).pushNamed(
                                          //   RoadmapPage.route,
                                          //   extra: {
                                          //     'roadmap' : res},
                                          // );
                                        },
                                        buttonColor: U.ButtonColor.primary,
                                      ),
                                    ),
                                  ],
                                ),
                          (index == state.questions.length && state.loading)
                              ? Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      SizedBox(height: 14),
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      );
                    },
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: U.Theme.afternoonPallet.getColors,
                      begin: AlignmentGeometry.topCenter,
                      end: AlignmentGeometry.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: U.AppBar(title: 'create')),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Spacer(flex: 1),
                                    Align(
                                      alignment: Alignment.center,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 120, // your maximum width
                                          maxHeight: 120, // your maximum height
                                        ),
                                        child: FittedBox(
                                          child: U.Image(
                                            fit: BoxFit.contain,
                                            path: U.Icons.orb,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 17),
                                    U.CyclingTextShowcase(
                                      texts: [
                                        ' _CyclingTextShowcaseState extends State<CyclingTextShowcase> ',
                                        'ddddddddddddd',
                                        'U.CyclingTextShowcasef',
                                        'sdfasd',
                                      ],
                                    ),
                                    // Spacer(flex: 3),
                                    // const Expanded(flex: 8, child: SizedBox()),
                                    // Column(
                                    //   children: [
                                    //     GestureDetector(
                                    //       onTap: () async {},
                                    //       child: U.Text(
                                    //         text: 'describe your goal!',
                                    //         textWeight: U.TextWeight.bold,
                                    //         textSize: U.TextSize.s18,
                                    //       ),
                                    //     ),
                                    //     const SizedBox(height: 15),
                                    //   ],
                                    // ),
                                        SizedBox(height: 200),
                                    // const Expanded(flex: 20, child: SizedBox()),
                                    // SizedBox(height: 140),
                                    // Spacer(flex: 2),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 82,
                        child: GoalTextfield(
                          onSubmit: () {},
                          isDisabled: ChattingStatus.enabled,
                          isExapnded: false,
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
