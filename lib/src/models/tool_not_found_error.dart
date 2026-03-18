import 'dart:convert';

class ToolNotFoundError extends Error {
  final Map<String, dynamic> toolCall;
  ToolNotFoundError(this.toolCall);
  @override
  String toString() => 'ToolNotFoundError: ${jsonEncode(toolCall)}';
}
