import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dart_openai_agent/src/agent_tool.dart';
import 'package:dart_openai_agent/src/models/context_message_add_event.dart';
import 'package:dart_openai_agent/src/models/no_message_content_error.dart';
import 'package:dart_openai_agent/src/models/tool_call_response.dart';
import 'package:dart_openai_agent/src/models/tool_not_found_error.dart';
import 'package:openai_dart/openai_dart.dart';

class OpenAIAgent {
  final String name;
  final OpenAI client;
  final String model;
  final String systemPrompt;
  final List<AgentTool>? tools;

  final StreamController<ContextMessageAddedEvent> _contextController =
      StreamController<ContextMessageAddedEvent>.broadcast();

  final Set<void Function(ContextMessageAddedEvent)> _contextListeners = {};

  OpenAIAgent({
    required String apiKey,
    required String baseUrl,
    String? name,
    required this.model,
    required this.systemPrompt,
    List<AgentTool>? tools,
    HttpLogCallback? onHttpLog,
  }) : name = name ?? _generateDefaultName(),
       tools = tools ?? [],
       client = OpenAI(apiKey: apiKey, baseUrl: baseUrl, onHttpLog: onHttpLog) {
    final message = ChatMessage(role: 'system', content: systemPrompt);
    context.add(message);
    _emitContextEvent(message, ContextMessageSource.systemInit);
  }

  List<ChatMessage> context = [];

  Stream<ContextMessageAddedEvent> get onContextMessageAdded =>
      _contextController.stream;

  void addContextListener(
    void Function(ContextMessageAddedEvent event) listener,
  ) {
    _contextListeners.add(listener);
  }

  void removeContextListener(
    void Function(ContextMessageAddedEvent event) listener,
  ) {
    _contextListeners.remove(listener);
  }

  void dispose() {
    _contextListeners.clear();
    _contextController.close();
  }

  void _emitContextEvent(ChatMessage message, ContextMessageSource source) {
    final event = ContextMessageAddedEvent(
      agentName: name,
      message: message,
      index: context.length - 1,
      source: source,
    );
    _contextController.add(event);
    for (final listener in _contextListeners) {
      listener(event);
    }
  }

  Future<String> _sendContext({bool isJson = false}) async {
    final response = await client.chat.completions.create(
      ChatCompletionCreateParams(
        model: model,
        messages: context,
        tools: tools?.map((tool) => tool.toToolDefinition()).toList(),
        responseFormat: isJson ? {"type": "json_object"} : null,
      ),
    );

    final assistantMessage = response.choices[0].message;
    context.add(assistantMessage);
    _emitContextEvent(assistantMessage, ContextMessageSource.assistantReply);

    if (assistantMessage.toolCalls != null) {
      for (Map<String, dynamic> toolCall in assistantMessage.toolCalls!) {
        var toolCallResponse = ToolCallResponse.fromJson(toolCall);
        var selectedTool = tools?.firstWhere(
          (tool) => tool.name == toolCallResponse.functionName,
        );
        if (selectedTool == null) {
          throw ToolNotFoundError(toolCall);
        }

        final toolMessage = ChatMessage(
          role: 'tool',
          content: await selectedTool.callback(toolCallResponse.arguments),
          toolCallId: toolCallResponse.toolCallId,
        );
        context.add(toolMessage);
        _emitContextEvent(toolMessage, ContextMessageSource.toolResult);
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
    final userMessage = ChatMessage(role: 'user', content: message);
    context.add(userMessage);
    _emitContextEvent(userMessage, ContextMessageSource.userInput);
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

String _generateDefaultName() {
  const prefix = 'Agent-';
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  final code = List.generate(
    4,
    (_) => chars[rand.nextInt(chars.length)],
  ).join();
  return '$prefix$code';
}
