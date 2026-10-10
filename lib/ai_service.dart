import 'dart:convert';

import 'package:http/http.dart' as http;

class AiReply {
  AiReply(this.message, this.appointment);
  final String message;
  final Map<String, dynamic>? appointment;
  factory AiReply.parse(Map<String, dynamic> json) {
    if (json['message'] is! String ||
        (json['message'] as String).trim().isEmpty) {
      throw const FormatException(
        'The assistant returned an invalid response.',
      );
    }
    final raw = json['appointment'];
    Map<String, dynamic>? appointment;
    if (raw != null) {
      if (raw is! Map<String, dynamic> ||
          raw['title'] is! String ||
          (raw['title'] as String).trim().isEmpty ||
          raw['start'] is! int ||
          raw['duration'] is! int ||
          raw['start'] < 0 ||
          raw['start'] >= 1440 ||
          raw['duration'] < 1 ||
          raw['start'] + raw['duration'] > 1440 ||
          ![
            'Personal',
            'Work',
            'Food',
            'Family',
            'Wellness',
          ].contains(raw['category'])) {
        throw const FormatException(
          'The assistant returned invalid appointment details.',
        );
      }
      appointment = raw;
    }
    return AiReply(json['message'], appointment);
  }
}

class AiService {
  AiService({http.Client? client, String? endpoint})
    : client = client ?? http.Client(),
      endpoint = endpoint ?? const String.fromEnvironment('AI_BACKEND_URL');
  final http.Client client;
  final String endpoint;
  bool get live => endpoint.isNotEmpty;
  void dispose() => client.close();
  Future<AiReply> ask(
    String task,
    String prompt,
    Map<String, dynamic> context,
  ) async {
    if (!live) return demo(task, prompt, context);
    final response = await client
        .post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'task': task,
            'prompt': prompt,
            'context': context,
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode != 200) {
      throw StateError(
        'AI service unavailable (${response.statusCode}). Check the backend and API key.',
      );
    }
    return AiReply.parse(jsonDecode(response.body) as Map<String, dynamic>);
  }

  AiReply demo(String task, String prompt, Map<String, dynamic> context) {
    if (task == 'schedule') {
      final match = RegExp(
        r'^(.+?)\s+at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)(?:\s+for\s+(\d+)\s+minutes)?[.!]?$',
        caseSensitive: false,
      ).firstMatch(prompt.trim());
      if (match == null ||
          RegExp(
            r'tomorrow|next|yesterday',
            caseSensitive: false,
          ).hasMatch(prompt)) {
        return AiReply(
          'Offline demo supports today only. Try “Dentist appointment at 3 pm for 30 minutes”. Live mode understands more natural language.',
          null,
        );
      }
      final hour = int.parse(match[2]!);
      final minute = int.parse(match[3] ?? '0');
      if (hour < 1 || hour > 12 || minute > 59) {
        return AiReply('Please specify a valid time.', null);
      }
      return AiReply.parse({
        'message': 'Review this sample interpretation before saving.',
        'appointment': {
          'title': match[1]!.trim(),
          'start':
              (hour % 12 + (match[4]!.toLowerCase() == 'pm' ? 12 : 0)) * 60 +
              minute,
          'duration': int.parse(match[5] ?? '30'),
          'category': 'Personal',
        },
      });
    }
    if (task == 'summary') {
      return AiReply(
        'You have ${(context['activities'] as List).length} activities today. Take a short break between commitments and protect your family time.',
        null,
      );
    }
    if (task == 'expenses') {
      final expenses = context['expenses'] as List;
      final total = expenses.fold<double>(
        0,
        (sum, e) => sum + (e['amount'] as num).toDouble(),
      );
      return AiReply(
        'Recorded spending: \$${total.toStringAsFixed(2)} across ${expenses.length} transactions. Review food purchases before your next purchase to stay within your \$75 demo budget.',
        null,
      );
    }
    return AiReply(
      context['diet'] == 'High protein'
          ? 'Sample meal ideas: a chicken and lentil bowl, Greek yogurt with berries, or tofu with edamame. Adjust ingredients to your preferences.'
          : 'Sample meal ideas: chickpea quinoa salad, lentil soup, or tofu with brown rice. Add vegetables for variety. These are general ideas; check ingredients against your allergies.',
      null,
    );
  }
}
