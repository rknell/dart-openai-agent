import 'dart:io';

import 'package:dart_openai_agent/src/openai_agent.dart';

import 'example_weather_tool.dart';

Future<void> main() async {
  final apiKey = Platform.environment['DEEPSEEK_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('API key not found');
    return;
  }

  final url =
      Platform.environment['DEEPSEEK_URL'] ?? 'https://api.deepseek.com';

  final agent = OpenAIAgent(
    apiKey: apiKey,
    baseUrl: url,
    model: 'deepseek-chat',
    systemPrompt: 'You get weather result and respond as rudely as possible.',
    tools: [exampleWeatherTool],
  );

  final curiousAgent = OpenAIAgent(
    apiKey: apiKey,
    baseUrl: url,
    model: 'deepseek-chat',
    systemPrompt:
        'You are super interested in weather in different parts of the world. You are talking with another AI agent who will fetch the current weather from an api in the response. If the agent is rude pull them up on it.',
    tools: [],
  );

  String prompt =
      "Choose a random location somewhere in the world to get the weather for. ";
  for (var i = 0; i < 5; i++) {
    final response = await curiousAgent.chat(message: prompt);
    print(response);
    prompt = await agent.chat(message: response);
    print(prompt);
  }
}
