class BusinessServers {
  final develop = '';

  final stable = '';

  // String get current => T.Utils.isDebug ? develop : stable;
  String get current => develop;
}

class BusinessUrls {
  // final createGoal = 'https://api.groq.com/openai/v1/chat/completions';
  final cerebrasAi = 'https://api.mistral.ai/v1/chat/completions'
  // final cerebrasAi = 'https://api.groq.com/openai/v1/chat/completions'
  // final cerebrasAi = 'https://opencode.ai/zen/v1/chat/completions'
  //  'https://api.cerebras.ai/v1/chat/completions'
  ;
}
