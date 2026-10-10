import 'package:flutter/material.dart';

import 'ai_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({
    super.key,
    required this.contextData,
    required this.saveAppointment,
  });
  final Map<String, dynamic> Function() contextData;
  final String? Function(Map<String, dynamic>) saveAppointment;
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final service = AiService();
  final input = TextEditingController(
    text: 'Dentist appointment at 3 pm for 30 minutes',
  );
  String task = 'schedule';
  String? error;
  AiReply? reply;
  bool busy = false, saved = false;
  @override
  void dispose() {
    input.dispose();
    service.dispose();
    super.dispose();
  }

  Future<void> ask() async {
    FocusScope.of(context).unfocus();
    if (input.text.trim().isEmpty) {
      setState(() => error = 'Enter a request first.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
      reply = null;
      saved = false;
    });
    try {
      final result = await service.ask(
        task,
        input.text.trim(),
        widget.contextData(),
      );
      if (mounted) setState(() => reply = result);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not get an AI response. Check your connection, backend configuration, and API key, then retry.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MyTracker assistant')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Chip(
              label: Text(
                service.live
                    ? 'Live AI • Connected backend'
                    : 'Offline sample • Simulated AI',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              service.live ? 'Ask your assistant' : 'Try the assistant flow',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              service.live
                  ? 'Your request and current demo schedule, expenses, and meal preference are sent to the configured AI backend.'
                  : 'Sample responses work without a key. Configure the backend to use a real AI model. Voice capture is not enabled; type your request.',
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  {
                        'schedule': 'Plan my day',
                        'summary': 'Daily summary',
                        'meals': 'Meal ideas',
                        'expenses': 'Spending insights',
                      }.entries
                      .map(
                        (e) => ChoiceChip(
                          label: Text(e.value),
                          selected: task == e.key,
                          onSelected: busy
                              ? null
                              : (_) => setState(() {
                                  task = e.key;
                                  reply = null;
                                  error = null;
                                  saved = false;
                                  input.text = switch (task) {
                                    'schedule' => 'Dentist appointment at 3 pm for 30 minutes',
                                    'summary' => 'Summarize my day and suggest how to keep it balanced.',
                                    'meals' => 'Suggest three meal alternatives for my dietary preference.',
                                    _ => 'Summarize my spending and suggest one practical improvement.',
                                  };
                                }),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: input,
              onChanged: (_) => setState(() {
                reply = null;
                error = null;
                saved = false;
              }),
              enabled: !busy,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Your request'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: busy ? null : ask,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                busy
                    ? 'Thinking…'
                    : service.live
                    ? 'Ask AI'
                    : 'Try sample',
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            if (reply != null)
              Card(
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply!.message, style: const TextStyle(height: 1.6)),
                      if (reply!.appointment case final a?) ...[
                        const Divider(height: 30),
                        const Text('TODAY • REVIEW BEFORE SAVING'),
                        const SizedBox(height: 8),
                        Text(
                          a['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(a['start'] as int) ~/ 60}:${((a['start'] as int) % 60).toString().padLeft(2, '0')} • ${a['duration']} minutes • ${a['category']}',
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: saved
                              ? null
                              : () {
                                  final problem = widget.saveAppointment(a);
                                  setState(() {
                                    error = problem;
                                    saved = problem == null;
                                  });
                                },
                          child: Text(
                            saved ? 'Saved to schedule' : 'Confirm appointment',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'The prototype schedules today only. AI suggestions are reviewed before an activity is saved.',
            ),
          ],
        ),
      ),
    ),
  );
}
