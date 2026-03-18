import 'dart:convert';

class ToolCallResponse {
  final String toolCallId;
  final String functionName;
  final Map<String, dynamic> arguments;

  ToolCallResponse({
    required this.toolCallId,
    required this.functionName,
    required this.arguments,
  });

  factory ToolCallResponse.fromJson(Map<String, dynamic> json) {
    return ToolCallResponse(
      toolCallId: json['id'] as String,
      functionName: json["function"]['name'] as String,
      arguments:
          jsonDecode(json["function"]['arguments']) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toolCallId': toolCallId,
      'functionName': functionName,
      'arguments': arguments,
    };
  }
}