# dart_openai_agent

A high-level wrapper around the OpenAI API for building agent-style chat with tool/function calling.

## Features

- Conversational context management
- Tool/function calling with typed parameters
- Multi-turn chat with automatic tool execution loops

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dart_openai_agent:
    git:
      url: https://github.com/rknell/dart-openai-agent.git
```

## Usage

```dart
import 'dart:io';
import 'package:dart_openai_agent/dart_openai_agent.dart';

void main() async {
  final agent = OpenAIAgent(
    apiKey: Platform.environment['OPENAI_API_KEY']!,
    baseUrl: Platform.environment['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1',
    model: 'gpt-4',
    systemPrompt: 'You are a helpful assistant.',
    tools: [/* your AgentTools */],
  );

  final response = await agent.chat(message: 'What is the weather in London?');
  print(response);
}
```

See the `example/` folder for a full workflow with a weather tool.

## License

MIT License – see [LICENSE](LICENSE). Provided without warranty.
