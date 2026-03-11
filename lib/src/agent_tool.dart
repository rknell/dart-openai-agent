import 'package:openai_dart/openai_dart.dart';

class AgentTool {
  final String name;
  final String description;
  final AgentToolParameters parameters;
  final Future<String> Function(Map<String, dynamic> properties) callback;

  AgentTool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.callback,
  });

  ToolDefinition toToolDefinition() {
    return ToolDefinition.function(
      name: name,
      description: description,
      parameters: parameters.toToolParameters(),
    );
  }
}

class AgentToolParameters {
  final List<AgentToolProperty> properties;
  final List<String> requiredFields;

  AgentToolParameters({required this.properties, List<String>? requiredFields})
    : requiredFields = requiredFields ?? [];

  ToolParameters toToolParameters() {
    return ToolParameters(
      properties: {
        for (var property in properties)
          property.name: {
            'type': property.type,
            'description': property.description,
          },
      },
      requiredFields: properties
          .where((property) => property.isRequired)
          .map((property) => property.name)
          .toList(),
    );
  }
}

class AgentToolProperty {
  final String name;
  final String type;
  final String description;
  final bool isRequired;

  AgentToolProperty({
    required this.name,
    this.type = 'string',
    required this.description,
    this.isRequired = false,
  });
}
