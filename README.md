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

## HTTP Logging

Enable HTTP request/response logging by passing an `onHttpLog` callback. Logging is silent by default (`onHttpLog: null`).

```dart
final agent = OpenAIAgent(
  apiKey: apiKey,
  baseUrl: baseUrl,
  model: model,
  systemPrompt: systemPrompt,
  onHttpLog: (event) {
    print('${event.method} ${event.uri} -> ${event.statusCode} (${event.duration?.inMilliseconds}ms)');
  },
);
```

`HttpLogEvent` provides `method`, `uri`, `statusCode`, `duration`, `requestHeaders` (sanitized; `Authorization` is redacted), `requestBody`, `responseHeaders`, and `responseBody`. Forward to your own logger:

```dart
import 'dart:developer' as developer;

final _log = developer.log;
final agent = OpenAIAgent(
  // ...
  onHttpLog: (e) => _log('HTTP ${e.method} ${e.uri} ${e.statusCode}'),
);
```

## License

MIT License – see [LICENSE](LICENSE). Provided without warranty.
