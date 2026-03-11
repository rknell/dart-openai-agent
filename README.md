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
import 'package:dart_openai_agent/dart_openai_agent.dart';
import 'package:openai_dart/openai_dart.dart';

void main() async {
  final client = OpenAI(apiKey: Platform.environment['OPENAI_API_KEY']!);
  final agent = OpenaiAgent(
    client: client,
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
