import 'package:test/test.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:dart_openai_agent/src/models/context_message_add_event.dart';

class MockChatMessage extends ChatMessage {
  final String? mockToolCallId;
  final List<Map<String, dynamic>>? mockToolCalls;
  MockChatMessage({
    required super.role,
    super.content,
    this.mockToolCallId,
    this.mockToolCalls,
  }) : super(
    toolCallId: mockToolCallId,
    toolCalls: mockToolCalls,
  );
}

void main() {
  group('ContextMessageAddedEvent ANSI string', () {
    test('user message is right aligned, bold', () {
      final msg = MockChatMessage(role: 'user', content: 'Hello');
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 1,
        source: ContextMessageSource.userInput,
      );
      final ansi = event.toAnsiString();
      expect(ansi.contains('You:'), isTrue);
      expect(ansi.trim().endsWith('Hello'), isTrue);
      expect(ansi.contains('\x1B[1m'), isTrue); // Bold
    });

    test('assistant message is italic and cyan', () {
      final msg = MockChatMessage(role: 'assistant', content: 'Thinking...');
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 2,
        source: ContextMessageSource.assistantReply,
      );
      final ansi = event.toAnsiString();
      expect(ansi.contains('\x1B[3m'), isTrue); // Italic
      expect(ansi.contains('\x1B[36m'), isTrue); // Cyan
      expect(ansi.contains('AI is thinking:'), isTrue);
      expect(ansi.contains('Thinking...'), isTrue);
    });

    test('system message is cyan', () {
      final msg = MockChatMessage(role: 'system', content: 'Welcome');
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 0,
        source: ContextMessageSource.systemInit,
      );
      final ansi = event.toAnsiString();
      expect(ansi.startsWith('\x1B[36m'), isTrue); // Cyan
      expect(ansi.contains('System:'), isTrue);
      expect(ansi.contains('Welcome'), isTrue);
    });

    test('tool result message shows tool details in grey', () {
      final msg = MockChatMessage(
        role: 'tool',
        content: 'Tool completed.',
        mockToolCallId: 'tool-123',
      );
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 3,
        source: ContextMessageSource.toolResult,
      );
      final ansi = event.toAnsiString();
      expect(ansi.contains('\x1B[38;5;245m'), isTrue); // Grey
      // Allow for ANSI escape codes between label and value
      expect(ansi.contains('ToolCall ID:'), isTrue);
      expect(ansi.contains('tool-123'), isTrue);
      expect(ansi.contains('Response:'), isTrue);
      expect(ansi.contains('Tool completed.'), isTrue);
    });

    test('fallback for unknown role', () {
      final msg = MockChatMessage(role: 'somethingelse', content: 'Other');
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 4,
        source: ContextMessageSource.userInput,
      );
      final ansi = event.toAnsiString();
      expect(ansi, contains('somethingelse: Other'));
    });

    test('handles null content safely', () {
      final msg = MockChatMessage(role: 'system');
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 0,
        source: ContextMessageSource.systemInit,
      );
      final ansi = event.toAnsiString();
      expect(ansi, contains('System:'));
    });

    test('handles toolResult source with null toolCallId safely', () {
      final msg = MockChatMessage(
        role: 'tool',
        content: 'Tool ran.',
        mockToolCallId: null,
      );
      final event = ContextMessageAddedEvent(
        agentName: 'TestAgent',
        message: msg,
        index: 5,
        source: ContextMessageSource.toolResult,
      );
      final ansi = event.toAnsiString();
      expect(ansi, isA<String>());
      // Falls back to generic role/content formatting when toolCallId is null
      expect(ansi.contains('tool:'), isTrue);
      expect(ansi.contains('Tool ran.'), isTrue);
    });
  });
}