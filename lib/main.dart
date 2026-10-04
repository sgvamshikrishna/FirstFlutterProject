import 'package:flutter/material.dart';

void main() => runApp(const PlantPalApp());

const forest = Color(0xFF183D32);
const leaf = Color(0xFF3D805A);
const cream = Color(0xFFF5F3E9);
const paleGreen = Color(0xFFE4EBDD);

class PlantPalApp extends StatelessWidget {
  const PlantPalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PlantPal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: cream,
          colorScheme: ColorScheme.fromSeed(seedColor: leaf),
          fontFamily: 'Arial',
        ),
        home: const GardenScreen(),
      );
}

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                children: [
                  Row(children: [
                    const Icon(Icons.eco_rounded, color: leaf, size: 30),
                    const SizedBox(width: 9),
                    const Text('PlantPal', style: TextStyle(color: forest, fontSize: 21, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    CircleAvatar(backgroundColor: paleGreen, child: const Icon(Icons.person_outline_rounded, color: forest)),
                  ]),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(28)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('YOUR LITTLE GARDEN', style: TextStyle(color: Color(0xFFC7D7C3), fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700)),
                      SizedBox(height: 13),
                      Text('Growing at\nits own pace.', style: TextStyle(color: Colors.white, fontSize: 32, height: 1.15, fontWeight: FontWeight.w800)),
                      SizedBox(height: 18),
                      Row(children: [Icon(Icons.wb_sunny_outlined, color: Color(0xFFF2D38D), size: 19), SizedBox(width: 8), Text('A bright day for your plants', style: TextStyle(color: Color(0xFFE0E9DC), fontSize: 14))]),
                    ]),
                  ),
                  const SizedBox(height: 29),
                  const Row(children: [Text('Your plants', style: TextStyle(color: forest, fontSize: 22, fontWeight: FontWeight.w800)), Spacer(), Text('2 plants', style: TextStyle(color: leaf, fontSize: 13, fontWeight: FontWeight.w700))]),
                  const SizedBox(height: 15),
                  const _PlantCard(name: 'Monstera', detail: 'Living room · Water in 2 days', icon: Icons.spa_rounded, color: Color(0xFFDBE8D5)),
                  const SizedBox(height: 12),
                  const _PlantCard(name: 'Little cactus', detail: 'Desk · Looking happy', icon: Icons.energy_savings_leaf_rounded, color: Color(0xFFECE3CA)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PlantCareScreen())),
                      icon: const Icon(Icons.water_drop_outlined),
                      label: const Text('Open plant care', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(child: Text('A HAPPY PLANT, ONE DAY AT A TIME', style: TextStyle(color: Color(0xFF809083), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700))),
                ],
              ),
            ),
          ),
        ),
      );
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.name, required this.detail, required this.icon, required this.color});
  final String name;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: leaf, size: 29)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: forest, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(detail, style: const TextStyle(color: Color(0xFF78847A), fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: leaf),
        ]),
      );
}

class PlantCareScreen extends StatefulWidget {
  const PlantCareScreen({super.key});

  @override
  State<PlantCareScreen> createState() => _PlantCareScreenState();
}

class _PlantCareScreenState extends State<PlantCareScreen> {
  bool _watered = false;
  int _careDays = 4;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: cream,
          leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded, color: forest)),
          title: const Text('Plant care', style: TextStyle(color: forest, fontSize: 17, fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 32), children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(color: paleGreen, borderRadius: BorderRadius.circular(28)),
                  child: const Center(child: Icon(Icons.spa_rounded, color: leaf, size: 112)),
                ),
                const SizedBox(height: 23),
                const Text('Monstera', style: TextStyle(color: forest, fontSize: 31, fontWeight: FontWeight.w800, letterSpacing: -.7)),
                const SizedBox(height: 6),
                const Text('Monstera deliciosa  ·  Living room', style: TextStyle(color: Color(0xFF78847A), fontSize: 14)),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Care check', style: TextStyle(color: forest, fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 15),
                    Row(children: [
                      const Icon(Icons.water_drop_rounded, color: Color(0xFF4D9AB2)),
                      const SizedBox(width: 11),
                      Expanded(child: Text(_watered ? 'Watered today — nicely done!' : 'Water when the top soil feels dry', style: const TextStyle(color: forest, fontSize: 13, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 13),
                    Row(children: [
                      const Icon(Icons.wb_sunny_outlined, color: Color(0xFFD59A43)),
                      const SizedBox(width: 11),
                      const Text('Prefers bright, indirect light', style: TextStyle(color: forest, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Row(children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFFFF0D8), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFE49A38))),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$_careDays day care streak', style: const TextStyle(color: forest, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text('Little routines help plants thrive.', style: TextStyle(color: Color(0xFF78847A), fontSize: 12)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 22),
                SizedBox(height: 56, child: FilledButton.icon(
                  onPressed: _watered ? null : () => setState(() { _watered = true; _careDays++; }),
                  icon: Icon(_watered ? Icons.check_rounded : Icons.water_drop_rounded),
                  label: Text(_watered ? 'Watered today!' : 'Mark as watered', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(backgroundColor: leaf, disabledBackgroundColor: const Color(0xFFB8C7B8), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                )),
              ]),
            ),
          ),
        ),
      );
}
