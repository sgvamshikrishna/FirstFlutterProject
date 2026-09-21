import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/main.dart';

void main() {
  testWidgets('App displays the Hello World greeting', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('My First Flutter App'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
