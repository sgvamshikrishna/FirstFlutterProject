import 'package:flutter/material.dart';

import 'ai_assistant.dart';

void main() => runApp(const MyTrackerApp());

const ink = Color(0xFF202B45);
const accent = Color(0xFF6658E8);
const muted = Color(0xFF8490A6);

class Activity {
  Activity(
    this.title,
    this.start,
    this.duration,
    this.category, {
    this.done = false,
  });
  final String title, category;
  final int start, duration;
  bool done;
}

class Expense {
  Expense(this.title, this.amount, this.category, this.source);
  final String title, category, source;
  final double amount;
}

String clock(int minutes) {
  final hour = minutes ~/ 60;
  return '${hour % 12 == 0 ? 12 : hour % 12}:${(minutes % 60).toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
}

class TrackerState extends ChangeNotifier {
  final activities = <Activity>[
    Activity('Morning movement', 420, 30, 'Wellness', done: true),
    Activity('Breakfast & a fresh start', 480, 30, 'Food', done: true),
    Activity('Design team meeting', 600, 60, 'Work'),
    Activity('Lunch break', 750, 45, 'Food'),
    Activity('Family time', 1080, 60, 'Family'),
  ];
  final expenses = <Expense>[
    Expense('Green bowl', 14.50, 'Food', 'Apple Pay demo'),
    Expense('Morning coffee', 4.75, 'Food', 'Apple Pay demo'),
    Expense('Train ticket', 3.25, 'Transport', 'Manual'),
  ];
  String diet = 'Balanced';
  final meals = [
    'Greek yogurt & berries',
    'Chicken quinoa bowl',
    'Salmon & roasted vegetables',
  ];
  final loggedMeals = <int>{};
  bool imported = false;
  double get spent => expenses.fold(0, (total, e) => total + e.amount);
  Activity? conflict(int start, int duration) {
    for (final a in activities) {
      if (start < a.start + a.duration && start + duration > a.start) return a;
    }
    return null;
  }

  void addActivity(Activity a) {
    activities.add(a);
    activities.sort((a, b) => a.start.compareTo(b.start));
    notifyListeners();
  }

  void toggle(Activity a) {
    a.done = !a.done;
    notifyListeners();
  }

  void remove(Activity a) {
    activities.remove(a);
    notifyListeners();
  }

  void addExpense(Expense e) {
    expenses.insert(0, e);
    notifyListeners();
  }

  void importDemo() {
    if (imported) return;
    imported = true;
    addExpense(
      Expense('Weekly groceries', 42.80, 'Groceries', 'Apple Pay demo'),
    );
  }

  void setDiet(String value) {
    diet = value;
    meals[2] = value == 'Vegetarian'
        ? 'Lentil soup & roasted vegetables'
        : 'Salmon & roasted vegetables';
    meals[1] = value == 'Vegetarian'
        ? 'Chickpea quinoa bowl'
        : value == 'High protein'
        ? 'Chicken & lentil bowl'
        : 'Chicken quinoa bowl';
    notifyListeners();
  }

  void swap(int index) {
    meals[index] = [
      'Oats, banana & almond butter',
      diet == 'High protein'
          ? 'Turkey & lentil salad'
          : 'Tofu & brown rice bowl',
      'Lentil soup & wholegrain toast',
    ][index];
    notifyListeners();
  }

  void logMeal(int i) {
    if (!loggedMeals.add(i)) loggedMeals.remove(i);
    notifyListeners();
  }
}

class MyTrackerApp extends StatelessWidget {
  const MyTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MyTracker',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      colorScheme: ColorScheme.fromSeed(seedColor: accent),
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(bodyMedium: TextStyle(color: ink)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const TrackerHome(),
  );
}

class TrackerHome extends StatefulWidget {
  const TrackerHome({super.key});
  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

class _TrackerHomeState extends State<TrackerHome> {
  final store = TrackerState();
  int page = 0;
  void openAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiAssistantScreen(
          contextData: () => {
            'today': DateTime.now().toIso8601String().substring(0, 10),
            'activities': store.activities
                .map(
                  (a) => {
                    'title': a.title,
                    'start': a.start,
                    'duration': a.duration,
                    'category': a.category,
                    'completed': a.done,
                  },
                )
                .toList(),
            'expenses': store.expenses
                .map(
                  (e) => {
                    'title': e.title,
                    'amount': e.amount,
                    'category': e.category,
                  },
                )
                .toList(),
            'diet': store.diet,
          },
          saveAppointment: (a) {
            final start = a['start'] as int;
            final duration = a['duration'] as int;
            final collision = store.conflict(start, duration);
            if (collision != null) {
              int? available;
              for (
                int candidate = 480;
                candidate + duration <= 1320;
                candidate += 15
              ) {
                if (store.conflict(candidate, duration) == null) {
                  available = candidate;
                  break;
                }
              }
              return 'Time conflict with ${collision.title} (${clock(collision.start)}–${clock(collision.start + collision.duration)}). ${available == null ? 'No free slot found between 8 AM and 10 PM.' : 'Try ${clock(available)} instead.'} Edit your request and ask again.';
            }
            store.addActivity(
              Activity(
                a['title'] as String,
                start,
                duration,
                a['category'] as String,
              ),
            );
            return null;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'MyTracker',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text(
                        'DEMO',
                        style: TextStyle(fontSize: 10, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      backgroundColor: Color(0xFFEAE7FF),
                      child: Text(
                        'YOU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: openAssistant,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Open AI assistant'),
                ),
                const SizedBox(height: 16),
                ...switch (page) {
                  0 => today(),
                  1 => schedule(),
                  2 => expenses(),
                  _ => nutrition(),
                },
                const SizedBox(height: 24),
                const Text(
                  'Prototype • Sample data resets when the app restarts',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (i) => setState(() => page = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Nutrition',
          ),
        ],
      ),
    ),
  );
  Widget heading(String eyebrow, String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: const TextStyle(
          color: accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          fontSize: 11,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(color: muted, height: 1.5)),
      const SizedBox(height: 24),
    ],
  );
  Widget card(Widget child, {Color color = Colors.white}) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFEAECEF)),
    ),
    child: child,
  );
  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 14),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
  );
  List<Widget> today() => [
    heading(
      'A little more balance',
      'Your day, thoughtfully planned.',
      'Make room for what matters. We’ll keep the details together.',
    ),
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6658E8), Color(0xFF8F7BF3)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'YOUR DAILY BRIEF',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A good day starts\nwith a little clarity.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${store.activities.length} activities planned. \$${(75 - store.spent).toStringAsFixed(2)} ${store.spent <= 75 ? 'left in' : 'over'} your daily budget. Keep your evening open for family.',
            style: const TextStyle(color: Colors.white, height: 1.6),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => addActivity(voice: true),
            icon: const Icon(Icons.mic_none_rounded),
            label: const Text('Tell me your plans'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: accent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simulated assistant • Try a sample voice transcript',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    ),
    const SizedBox(height: 20),
    LayoutBuilder(
      builder: (context, bounds) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          stat(
            'Daily rhythm',
            '${store.activities.where((a) => a.done).length}/${store.activities.length}',
            'activities complete',
            Icons.task_alt,
            bounds.maxWidth,
          ),
          stat(
            'Daily spending',
            '\$${store.spent.toStringAsFixed(2)}',
            'of a \$75 demo budget',
            Icons.wallet_outlined,
            bounds.maxWidth,
          ),
          stat(
            'Nourish yourself',
            '${store.loggedMeals.length}/3',
            'meals logged',
            Icons.restaurant_outlined,
            bounds.maxWidth,
          ),
        ],
      ),
    ),
    label('Your daily rhythm'),
    ...store.activities.take(3).map(activityTile),
    TextButton(
      onPressed: () => setState(() => page = 1),
      child: const Text('View full schedule →'),
    ),
  ];
  Widget stat(
    String title,
    String value,
    String foot,
    IconData icon,
    double width,
  ) => SizedBox(
    width: width < 550 ? width : (width - 24) / 3,
    child: card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          Text(foot, style: const TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    ),
  );
  Widget activityTile(Activity a) => card(
    Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            clock(a.start),
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: 3,
          height: 44,
          color: a.category == 'Family' ? const Color(0xFFE7A25C) : accent,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ink,
                  decoration: a.done ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${a.category} • ${a.duration} min',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: a.done ? 'Mark incomplete' : 'Mark complete',
          onPressed: () => store.toggle(a),
          icon: Icon(
            a.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: a.done ? const Color(0xFF3DA58B) : muted,
          ),
        ),
        if (page == 1)
          IconButton(
            tooltip: 'Delete activity',
            onPressed: () => store.remove(a),
            icon: const Icon(Icons.close, size: 18),
          ),
      ],
    ),
  );
  List<Widget> schedule() => [
    heading(
      'Make time for you',
      'Your schedule',
      'Work, meals, appointments and the people you love.',
    ),
    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: addActivity,
          icon: const Icon(Icons.add),
          label: const Text('Add activity'),
        ),
        OutlinedButton.icon(
          onPressed: () => addActivity(voice: true),
          icon: const Icon(Icons.mic_none),
          label: const Text('Voice demo'),
        ),
      ],
    ),
    const SizedBox(height: 18),
    card(
      const Row(
        children: [
          Icon(Icons.shield_outlined, color: accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'We check for overlapping times before adding anything.',
              style: TextStyle(color: ink, height: 1.5),
            ),
          ),
        ],
      ),
      color: const Color(0xFFEFEDFF),
    ),
    label('Today’s timeline'),
    if (store.activities.isEmpty)
      card(const Text('A clear day. Add your first activity.')),
    ...store.activities.map(activityTile),
  ];
  List<Widget> expenses() => [
    heading(
      'Spend with intention',
      'Your expenses',
      'A clear picture of the little things that add up.',
    ),
    card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY’S SPENDING',
            style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${store.spent.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: (store.spent / 75).clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 10),
          Text(
            'Daily demo budget: \$75 • ${store.spent > 75 ? 'Over budget' : 'On track'}',
            style: const TextStyle(color: muted),
          ),
        ],
      ),
    ),
    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: addExpense,
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        ),
        OutlinedButton.icon(
          onPressed: store.imported
              ? null
              : () {
                  store.importDemo();
                  message('Imported one sample Apple Pay transaction.');
                },
          icon: const Icon(Icons.sync),
          label: Text(
            store.imported ? 'Sample imported' : 'Import Apple Pay demo',
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    const Text(
      'Apple Pay is simulated. No wallet or bank account is connected.',
      style: TextStyle(color: muted, fontSize: 12),
    ),
    label('Transactions'),
    ...store.expenses.map(
      (e) => card(
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEFEDFF),
              child: Icon(
                e.category == 'Transport'
                    ? Icons.train_outlined
                    : Icons.shopping_bag_outlined,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${e.category} • ${e.source}',
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '-\$${e.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  ];
  List<Widget> nutrition() => [
    heading(
      'Good food, good energy',
      'Your nutrition',
      'A flexible meal plan that fits into your day.',
    ),
    card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your preference',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Balanced', 'Vegetarian', 'High protein']
                .map(
                  (d) => ChoiceChip(
                    label: Text(d),
                    selected: store.diet == d,
                    onSelected: (_) => store.setDiet(d),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
    card(
      const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: accent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A little inspiration',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Try a meal swap for more variety. These curated demo suggestions follow your selected preference.',
                  style: TextStyle(height: 1.5, color: muted),
                ),
                SizedBox(height: 6),
                Text(
                  'Simulated AI • General meal ideas',
                  style: TextStyle(fontSize: 11, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
      color: const Color(0xFFEFEDFF),
    ),
    label('On the menu'),
    ...List.generate(
      3,
      (i) => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  [
                    Icons.wb_sunny_outlined,
                    Icons.light_mode_outlined,
                    Icons.nights_stay_outlined,
                  ][i],
                  color: const Color(0xFFDA9A52),
                ),
                const SizedBox(width: 8),
                Text(
                  [
                    'Breakfast • 8:00 AM',
                    'Lunch • 12:30 PM',
                    'Dinner • 7:00 PM',
                  ][i],
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              store.meals[i],
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => store.swap(i),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Suggest a swap'),
                ),
                TextButton.icon(
                  onPressed: () => store.logMeal(i),
                  icon: Icon(
                    store.loggedMeals.contains(i)
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    store.loggedMeals.contains(i) ? 'Logged' : 'Log meal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ];
  Future<void> addActivity({bool voice = false}) async {
    final title = TextEditingController();
    final transcript = TextEditingController(
      text: 'Dentist appointment at 10:30 am',
    );
    int start = 900, duration = 30;
    String category = 'Personal', error = '';
    await showDialog<void>(
      context: context,
      animationStyle: AnimationStyle.noAnimation,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(voice ? 'Voice assistant demo' : 'Add an activity'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (voice) ...[
                    const Text(
                      'Simulated transcription. Enter a plan using “at 10:30 am” or “at 3 pm”.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: transcript,
                      decoration: const InputDecoration(
                        labelText: 'Sample transcript',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final match = RegExp(
                          r'^(.+?)\s+at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)$',
                          caseSensitive: false,
                        ).firstMatch(transcript.text.trim());
                        if (match == null) {
                          update(
                            () =>
                                error = 'Try: Dentist appointment at 10:30 am',
                          );
                          return;
                        }
                        final h = int.parse(match[2]!);
                        final m = int.parse(match[3] ?? '0');
                        if (h < 1 || h > 12 || m > 59) {
                          update(
                            () => error = 'Please use a valid 12-hour time.',
                          );
                          return;
                        }
                        update(() {
                          title.text = match[1]!;
                          start =
                              (h % 12 +
                                      (match[4]!.toLowerCase() == 'pm'
                                          ? 12
                                          : 0)) *
                                  60 +
                              m;
                          error = '';
                        });
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Interpret transcript'),
                    ),
                    const Divider(),
                  ],
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Activity name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: start ~/ 60,
                          minute: start % 60,
                        ),
                      );
                      if (time != null) {
                        update(() => start = time.hour * 60 + time.minute);
                      }
                    },
                    icon: const Icon(Icons.schedule),
                    label: Text(clock(start)),
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: duration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    items: [15, 30, 45, 60, 90]
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m minutes'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => update(() => duration = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['Personal', 'Work', 'Food', 'Family', 'Wellness']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => category = v!,
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red, height: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) {
                  update(() => error = 'Please enter an activity name.');
                  return;
                }
                if (start + duration > 1440) {
                  update(
                    () => error = 'The activity must finish before midnight.',
                  );
                  return;
                }
                final collision = store.conflict(start, duration);
                if (collision != null) {
                  update(
                    () => error =
                        'Time conflict: ${collision.title} is scheduled for ${clock(collision.start)}–${clock(collision.start + collision.duration)}. Choose another time.',
                  );
                  return;
                }
                store.addActivity(
                  Activity(title.text.trim(), start, duration, category),
                );
                Navigator.pop(dialogContext);
                message('Activity added to your schedule.');
              },
              child: const Text('Save activity'),
            ),
          ],
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    title.dispose();
    transcript.dispose();
  }

  Future<void> addExpense() async {
    final name = TextEditingController(), amount = TextEditingController();
    String category = 'Food', error = '';
    await showDialog<void>(
      context: context,
      animationStyle: AnimationStyle.noAnimation,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Add expense'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'What did you buy?',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: ['Food', 'Groceries', 'Transport', 'Shopping', 'Other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text);
                if (name.text.trim().isEmpty ||
                    value == null ||
                    !value.isFinite ||
                    value <= 0) {
                  update(() => error = 'Enter a name and a positive amount.');
                  return;
                }
                store.addExpense(
                  Expense(name.text.trim(), value, category, 'Manual'),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save expense'),
            ),
          ],
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    name.dispose();
    amount.dispose();
  }
}
