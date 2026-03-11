import 'package:http/http.dart' as http;

import 'package:dart_openai_agent/src/agent_tool.dart';

final exampleWeatherTool = AgentTool(
  name: 'query_open_meteo',
  description:
      'Query the Open-Meteo API for the current weather for a given location.',
  parameters: AgentToolParameters(
    properties: [
      AgentToolProperty(
        name: 'latitude',
        description: 'The latitude of the location to query.',
      ),
      AgentToolProperty(
        name: 'longitude',
        description: 'The longitude of the location to query.',
      ),
    ],
  ),
  callback: (Map<String, dynamic> properties) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${properties['latitude']}&longitude=${properties['longitude']}&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return 'Failed to fetch weather: ${response.statusCode}';
    }
    return response.body;
  },
);
