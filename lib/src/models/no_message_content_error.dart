import 'package:openai_dart/openai_dart.dart';

class NoMessageContentError extends Error {
  final ChatCompletionResponse response;
  NoMessageContentError(this.response);
  @override
  String toString() => 'NoMessageContentError: $response';
}