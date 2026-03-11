import 'dart:convert';

import 'package:dart_openai_agent/src/agent_tool.dart';
import 'package:openai_dart/openai_dart.dart';

class OpenaiAgent {
  final OpenAI client;
  final String model;
  final String systemPrompt;
  final List<AgentTool>? tools;

  OpenaiAgent({
    required this.client,
    required this.model,
    required this.systemPrompt,
    List<AgentTool>? tools,
  }) : tools = tools ?? [] {
    context.add(ChatMessage(role: 'system', content: systemPrompt));
  }

  List<ChatMessage> context = [];

  Future<String> _sendContext({bool isJson = false}) async {
    final response = await client.chat.completions.create(
      ChatCompletionCreateParams(
        model: model,
        messages: context,
        tools: tools?.map((tool) => tool.toToolDefinition()).toList(),
        responseFormat: isJson ? {"type": "json_object"} : null,
      ),
    );

    context.add(response.choices[0].message);
    if (response.choices[0].message.toolCalls != null) {
      for (Map<String, dynamic> toolCall
          in response.choices[0].message.toolCalls!) {
        var toolCallResponse = ToolCallResponse.fromJson(toolCall);
        var selectedTool = tools?.firstWhere(
          (tool) => tool.name == toolCallResponse.functionName,
        );
        if (selectedTool == null) {
          throw ToolNotFoundError(toolCall);
        }

        context.add(
          ChatMessage(
            role: 'tool',
            content: await selectedTool.callback(toolCallResponse.arguments),
            toolCallId: toolCallResponse.toolCallId,
          ),
        );
      }
      return _sendContext(isJson: isJson);
    } else {
      if (response.choices[0].message.content == null) {
        throw NoMessageContentError(response);
      }
      return response.choices[0].message.content!;
    }
  }

  Future<String> chat({required String message, bool isJson = false}) async {
    context.add(ChatMessage(role: 'user', content: message));
    return _sendContext(isJson: isJson);
  }

  String get printableContext {
    var result = StringBuffer();
    for (var message in context) {
      result.write('${message.role}:\n ${message.content ?? ''}\n\n');
      if (message.toolCalls != null) {
        for (var toolCall in message.toolCalls!) {
          result.write(
            'Tool call: \n${toolCall['functionName']}\n${toolCall['arguments']}\n\n',
          );
        }
      }
    }
    return result.toString();
  }
}

class NoMessageContentError extends Error {
  final ChatCompletionResponse response;
  NoMessageContentError(this.response);
  @override
  String toString() => 'NoMessageContentError: $response';
}

class ToolNotFoundError extends Error {
  final Map<String, dynamic> toolCall;
  ToolNotFoundError(this.toolCall);
  @override
  String toString() => 'ToolNotFoundError: ${jsonEncode(toolCall)}';
}

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
