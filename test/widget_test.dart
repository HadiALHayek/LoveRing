import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_ring/main.dart';

void main() {
  testWidgets('LoveRingApp renders permissions screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LoveRingApp(),
      ),
    );

    expect(find.text('Required Permissions'), findsOneWidget);
  });
}
