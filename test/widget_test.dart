import 'package:flutter_test/flutter_test.dart';
import 'package:kudiflow/main.dart';

void main() {
  testWidgets('shows the KudiFlow dashboard', (tester) async {
    await tester.pumpWidget(const KudiFlowApp());
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
  });
}
