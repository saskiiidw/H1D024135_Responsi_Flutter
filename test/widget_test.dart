import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_flutter/main.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app bar title
    expect(find.text('Informasi Cuaca'), findsOneWidget);
  });
}
