import 'package:flutter_test/flutter_test.dart';
import 'package:dijital_defter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DijitalDefterApp());
    expect(find.text('Envanter Bakım Defteri'), findsOneWidget);
  });
}
