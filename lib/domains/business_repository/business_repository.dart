import 'package:personal_ai_coach/data_providers/business_ws/business_ws.dart';
import 'package:personal_ai_coach/domains/business_repository/business_box.dart';
import 'package:personal_ai_coach/domains/business_repository/models/message.dart';
import 'package:personal_ai_coach/domains/business_repository/models/specific_tasks.dart';
import 'package:personal_ai_coach/domains/business_repository/models/task.dart';

class BusinessRepository {
  static Future<BusinessRepository> init() async {
    await BusinessBox.open();
    return BusinessRepository();
  }

  static Message followUpQuestionPrompt = Message.user(
    content:
        'You are responsible for collecting the minimum information needed to generate a personalized roadmap. '
        'Ask exactly one question at a time, in a logical order: first assess experience/skill level, then '
        'available time commitment (hours/days per week), then preferred time of day for doing tasks, then the '
        'desired timeline to achieve the goal, then any relevant lifestyle constraints. Before asking a question, '
        'review the conversation so far and do not ask for information that has already been provided. Every '
        'question must be answerable by selecting one or more of the provided options — never ask a question that '
        'requires the user to type a free-text answer. Always provide between 2 and 5 concise, mutually exclusive '
        'options for each question, unless the question allows multiple selections, in which case set inputType to '
        'multi_choice. The preferred time of day question must use multi_choice, since a user may do tasks across '
        'more than one time slot. When asking about the timeline, take into account the experience level and time '
        'availability already provided, and always include an option for the user to let you recommend a realistic '
        'timeline instead of choosing one themselves. Return only valid JSON matching the schema below, with no '
        'Markdown, no explanations, and no text outside the JSON object. When enough information has been collected, '
        'return completed. Example: { type: follow_up_question, completed: false, question: { id: preferred_time_of_day, '
        'title: When do you usually prefer to do focused work?, description: This helps us schedule your daily tasks '
        'at times that realistically fit your routine., inputType: multi_choice, options: [ { id: early_morning, label: '
        'Early morning (6-9 AM) }, { id: morning, label: Morning (9 AM-12 PM) }, { id: afternoon, label: Afternoon '
        '(12-5 PM) }, { id: evening, label: Evening (5-9 PM) }, { id: night, label: Late night (9 PM+) } ] } }',
  );

  static Message roadmapGenerationPrompt = Message.user(
    content:
        'You are an expert learning coach generating a personalized, realistic roadmap based on the user\'s goal and '
        'collected profile information. Use the provided goal, experience level, time commitment, timeline, and '
        'lifestyle constraints to structure a roadmap that is achievable and paced appropriately — do not create a '
        'plan that is unrealistically fast or slow relative to the stated timeline and available hours per week. '
        'Break the roadmap into sequential milestones, each with a clear title, description, start and end week, and '
        'one checkpoint task that lets the user demonstrate they have absorbed that milestone. Milestones must '
        'progress in difficulty from foundational to advanced. For the FIRST milestone only (order: 1), provide a '
        'complete weeklyObjectives array containing one entry for every individual week within its startWeek and '
        'endWeek range, with no skipped weeks. For all other milestones, return an empty weeklyObjectives array — '
        'their weekly detail will be generated separately later, closer to when the user reaches them. Return only '
        'valid JSON matching the schema below, with no Markdown, no explanations, and no text outside the JSON '
        'object. Example: { type: roadmap, goal: string, summary: string, totalDurationWeeks: number, '
        'difficultyProgression: string, milestones: [ { id: string, order: number, title: string, description: '
        'string, startWeek: number, endWeek: number, weeklyObjectives: [ { week: number, focus: string, outcome: '
        'string } ], checkpoint: { id: string, title: string, criteria: string } } ] }',
  );

  static Message weeklyTasksGenerationPrompt = Message.user(
    content:
        'You are an expert learning coach generating one full week of daily tasks based on the user\'s current '
        'roadmap milestone and weekly objective. You will also receive the user\'s preferred time-of-day slot(s) for '
        'doing focused work — assign each day to one of these preferred slots, distributing across multiple slots if '
        'more than one was provided, and do not assign a slot the user did not select. Within each day\'s assigned '
        'slot, give the primary task and every supporting task a specific scheduledStartTime and scheduledEndTime in '
        '24-hour HH:mm format, based on each task\'s estimatedMinutes, such that tasks on the same day never overlap '
        'and fall within the time range implied by the slot (e.g. evening = roughly 17:00-21:00). Order tasks within '
        'the day sensibly, with the primary task typically first. You will also receive the objectives for the next '
        '1-2 upcoming weeks for context — use this only to ensure this week\'s tasks build naturally toward what '
        'comes next; do not generate tasks for those future weeks. You will also receive a summary of the user\'s '
        'recent activity (completion rate, skips, momentum) — use this to calibrate task difficulty and load: reduce '
        'scope slightly if the user has been struggling, and maintain or slightly increase scope if they have been '
        'consistently completing tasks. Generate exactly 7 days of tasks, one per calendar date starting from the '
        'given week start date. Each day must include a scheduledTimeSlot, one primary task directly tied to the '
        'current week\'s objective, and up to 2 optional supporting tasks. Tasks must be realistically scoped to the '
        'user\'s available time per day based on their stated time commitment, and should build on each other '
        'progressively across the week rather than repeating the same exercise. Every primary task must briefly '
        'explain why it matters in relation to the long-term goal, and include 1-2 relevant search query suggestions '
        '(not URLs) the user could use to find helpful learning resources. Include a short progress snapshot and a '
        'brief, specific insight for the week. Return only valid JSON matching the schema below, with no Markdown, '
        'no explanations, and no text outside the JSON object. Example: { "type": "weekly_tasks", "weekNumber": 0, '
        '"weekStartDate": "string", "weekEndDate": "string", "milestoneContext": { "milestoneId": "string", '
        '"milestoneTitle": "string" }, "days": [ { "date": "string", "status": "string", "scheduledTimeSlot": '
        '"string", "scheduledTimeLabel": "string", "primaryTask": { "id": "string", "title": "string", '
        '"description": "string", "estimatedMinutes": 0, "scheduledStartTime": "string", "scheduledEndTime": '
        '"string", "type": "string", "whyItMatters": "string", "suggestedSearches": [ { "query": "string" } ] }, '
        '"supportingTasks": [ { "id": "string", "title": "string", "estimatedMinutes": 0, "scheduledStartTime": '
        '"string", "scheduledEndTime": "string", "type": "string", "optional": true } ] } ], "progressSnapshot": { '
        '"currentMilestone": "string", "milestonesCompleted": 0, "totalMilestones": 0, "weeksAheadOrBehind": 0, '
        '"momentumStatus": "string" }, "insight": "string" }',
  );

  ///////////////
  Future<dynamic> createCredentials({required List<Message> messages}) async {
    late List<Message> messagesList;
    messagesList = [...messages];
    messagesList.insert(0, followUpQuestionPrompt);
    final res = await BusinessWs.client.post(
      url: BusinessWs.urls.cerebrasAi,
      data: {
        // "model": "llama-3.3-70b-versatile",
        "model": "gemma-4-31b",
        "messages": messagesList.map((e) => e.toMap()).toList(),
      },
    );

    return res.data;
  }

  Future<dynamic> createRoadmap({required Message message}) async {
    final messageListt = [];
    messageListt.insert(0, roadmapGenerationPrompt);
    messageListt.add(message);
    final res = await BusinessWs.client.post(
      url: BusinessWs.urls.cerebrasAi,
      data: {
        "model": "gemma-4-31b",
        "messages": messageListt.map((e) => e.toMap()).toList(),
      },
    );
    return res.data;
  }

  Future<dynamic> createWeeklyTasks(Message message) async {
    List<Message> messageList = [];
    messageList.insert(0, weeklyTasksGenerationPrompt);
    messageList.add(message);
    final res = await BusinessWs.client.post(
      url: BusinessWs.urls.cerebrasAi,
      data: {
        "model": "gemma-4-31b",
        "messages": messageList.map((e) => e.toMap()).toList(),
      },
    );
    return res.data;
  }

  Future<void> createSchedule(List<SpecificTasks> tasks) async {
    await BusinessBox.setWeeklyTasks(tasks);
  }

  Future<void> updateTasks(DayTask task, {bool isNew = false}) async {
    await BusinessBox.updateTasks(task, isNew: isNew);
  }

  Future<void> deleteTask(DayTask task) async {
   await BusinessBox.deleteTask(task);
  }

  Future<void> updateDays(List<SpecificTasks> tasks) async {
    await BusinessBox.setWeeklyTasks(tasks, conflictCheck: false);
  }

  Future<SpecificTasks> readTask(DayTask task) async {
    final res = await BusinessBox.readSpecificTask(task);
    return res;
  }

  Future<List<SpecificTasks>> readSchedule() async {
    final res = await BusinessBox.getWeeklyTasks();
    return res;
  }

  Future<SpecificTasks?> readByDay(String date) async {
    final res = await BusinessBox.readByDay(date);
    return res;
  }

  Future<List<Message>> readChatMessages() async {
    final res = [Message.ai(content: 'content')];
    Future.delayed(Duration(seconds: 2));
    return res;
  }
}
