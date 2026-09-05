import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/main.dart';

void main() {
  testWidgets('SafPocApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SafPocApp());

    expect(find.text('WhatsApp Status SAF POC'), findsOneWidget);
    expect(find.text('DIAGNOSTIC MATRIX'), findsOneWidget);
    expect(find.text('Request SAF Access (Test 1)'), findsOneWidget);
  });
}
