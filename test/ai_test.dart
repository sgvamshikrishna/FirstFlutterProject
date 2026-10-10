import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/ai_service.dart';
import 'package:hello_world/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'Live service sends context and accepts structured model response',
    () async {
      final client = MockClient((request) async {
        final payload = jsonDecode(request.body);
        expect(payload['task'], 'schedule');
        expect(payload['context']['diet'], 'Vegetarian');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          jsonEncode({
            'message': 'Review your appointment.',
            'appointment': {
              'title': 'Dentist',
              'start': 900,
              'duration': 60,
              'category': 'Personal',
            },
          }),
          200,
        );
      });
      final service = AiService(
        client: client,
        endpoint: 'http://localhost:8080/ai',
      );
      final reply = await service.ask('schedule', 'Dentist at 3 pm', {
        'diet': 'Vegetarian',
      });
      expect(reply.appointment?['start'], 900);
      service.dispose();
    },
  );
  test(
    'Live service surfaces failures instead of pretending a demo is AI',
    () async {
      final service = AiService(
        client: MockClient((_) async => http.Response('unavailable', 502)),
        endpoint: 'http://localhost:8080/ai',
      );
      await expectLater(
        service.ask('summary', 'Summarize', {}),
        throwsStateError,
      );
      service.dispose();
    },
  );
  test(
    'Rejects invalid appointment times and distinguishes future dates',
    () async {
      expect(
        () => AiReply.parse({
          'message': 'Plan',
          'appointment': {
            'title': 'Test',
            'start': 1430,
            'duration': 60,
            'category': 'Work',
          },
        }),
        throwsFormatException,
      );
      final service = AiService(endpoint: '');
      final reply = await service.ask(
        'schedule',
        'Dentist tomorrow at 3 pm',
        {},
      );
      expect(reply.appointment, isNull);
      expect(reply.message, contains('today only'));
      service.dispose();
    },
  );
  testWidgets(
    'Assistant conflict blocks save and valid proposal requires confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyTrackerApp());
      await tester.tap(find.text('Open AI assistant'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Dentist at 10:30 am');
      await tester.tap(find.text('Try sample'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Confirm appointment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm appointment'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Time conflict with Design team meeting'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Dentist at 3 pm');
      await tester.ensureVisible(find.text('Try sample'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try sample'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Confirm appointment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm appointment'));
      await tester.pumpAndSettle();
      expect(find.text('Saved to schedule'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
