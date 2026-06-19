// Smoke test: verifies the app builds and renders its root widget.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flux_app/main.dart';

void main() {
  testWidgets('FluxApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FluxApp()));
    expect(find.byType(FluxApp), findsOneWidget);
  });
}
