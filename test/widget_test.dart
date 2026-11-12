import 'package:flutter_test/flutter_test.dart';
import 'package:packsmart/main.dart';

void main() {
  testWidgets('PackSmart app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PackSmartApp());
    expect(find.byType(PackSmartApp), findsOneWidget);
  });
}
