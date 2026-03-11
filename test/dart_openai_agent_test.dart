import 'package:dart_openai_agent/dart_openai_agent.dart';
import 'package:test/test.dart';

void main() {
  group('AgentTool', () {
    test('builds tool definition from parameters', () {
      final tool = AgentTool(
        name: 'test_tool',
        description: 'A test tool',
        parameters: AgentToolParameters(
          properties: [
            AgentToolProperty(name: 'input', description: 'Test input'),
          ],
        ),
        callback: (_) async => 'ok',
      );
      final def = tool.toToolDefinition();
      expect(def, isNotNull);
    });
  });
}
