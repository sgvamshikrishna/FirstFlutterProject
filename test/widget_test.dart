import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/main.dart';

void main() {
  test('Detects overlaps but permits adjacent activities', () {
    final state = TrackerState();
    expect(state.conflict(630, 30)?.title, 'Design team meeting');
    expect(state.conflict(660, 30), isNull);
    expect(state.conflict(590, 90), isNotNull);
    state.dispose();
  });
  test('Demo import is idempotent and meal preferences apply', () {
    final state = TrackerState();
    state.importDemo();
    state.importDemo();
    expect(state.expenses.length, 4);
    expect(state.spent, closeTo(65.30, .001));
    state.setDiet('Vegetarian');
    expect(state.meals.join(' '), isNot(contains('Salmon')));
    state.logMeal(0);
    expect(state.loggedMeals, contains(0));
    state.dispose();
  });
  testWidgets('All four destinations work on a mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyTrackerApp());
    expect(find.text('MyTracker'), findsOneWidget);
    for (final destination in ['Schedule', 'Expenses', 'Nutrition', 'Today']) {
      await tester.tap(find.text(destination));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: destination);
    }
  });
  testWidgets('Manual expense validation and save', (tester) async {
    await tester.pumpWidget(const MyTrackerApp());
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save expense'));
    await tester.pump();
    expect(find.text('Enter a name and a positive amount.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Notebook');
    await tester.enterText(find.byType(TextField).at(1), '10');
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Notebook'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Notebook'), findsOneWidget);
    expect(find.text('\$32.50'), findsOneWidget);
  });
}
