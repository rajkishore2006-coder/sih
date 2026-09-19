import 'package:flutter_test/flutter_test.dart';
import 'package:onion_quality_app/main.dart';

void main() {
  testWidgets('OnionSure app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OnionSureApp());
    expect(find.text('OnionSure'), findsOneWidget);
    expect(find.text('Registered Onion Batches'), findsOneWidget);
  });
}
