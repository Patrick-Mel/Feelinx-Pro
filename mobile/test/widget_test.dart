import 'package:flutter_test/flutter_test.dart';
import 'package:feelinx/app.dart';

void main() {
  testWidgets('FeelinxApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FeelinxApp());
    expect(find.byType(FeelinxApp), findsOneWidget);
  });
}
