import 'package:openai_dart/openai_dart.dart';

enum ContextMessageSource { systemInit, userInput, assistantReply, toolResult }

class ContextMessageAddedEvent {
  final String agentName;
  final ChatMessage message;
  final int index;
  final ContextMessageSource source;

  ContextMessageAddedEvent({
    required this.agentName,
    required this.message,
    required this.index,
    required this.source,
  });

  /// An event representing when a message is added to the agent context.
  ///
  /// Contains metadata about the message, including the agent's name,
  /// the message itself, its index in the conversation, and its origin/source.
  ///
  /// See also:
  /// - [ContextMessageSource] for the possible types of message sources.
  /// - [ChatMessage] for the message model.
  String toAnsiString() {
    final reset = '\x1B[0m';
    final italic = '\x1B[3m';
    final bold = '\x1B[1m';
    final cyan = '\x1B[36m';
    final grey = '\x1B[38;5;245m';
    final userAlignPad = 40;

    String padRight(String input, int width) {
      if (input.length >= width) return input;
      return ' ' * (width - input.length) + input;
    }

    // Tool message (tool result)
    if (source == ContextMessageSource.toolResult &&
        message.toolCallId != null) {
      // Try to pretty print request and response
      // Tool call info can usually be found in previous assistant message's toolCalls
      // But here, we just show what's available in message
      final request = (message.content is String)
          ? message.content
          : message.content?.toString() ?? '';
      // Compose a pretty tool call
      var toolDetails = '';
      if (message.toolCallId != null) {
        toolDetails += '${bold}ToolCall ID:$reset ${message.toolCallId}\n';
      }
      toolDetails += '${bold}Response:$reset $request';
      return '$grey$toolDetails$reset';
    }

    // User message: right-aligned
    if (message.role == 'user') {
      final rightText = '${bold}You:$reset ${message.content ?? ""}';
      return padRight(rightText, userAlignPad);
    }

    // Assistant/AI thinking (italics)
    if (message.role == 'assistant') {
      return '$italic${cyan}AI is thinking:$reset ${message.content ?? ""}$reset';
    }

    // System message: just cyan
    if (message.role == 'system') {
      return '${cyan}System:$reset ${message.content ?? ""}';
    }

    // Fallback
    return '${message.role}: ${message.content ?? ""}';
  }
}
