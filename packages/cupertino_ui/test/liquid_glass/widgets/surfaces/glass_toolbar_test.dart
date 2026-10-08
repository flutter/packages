import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassToolbar', () {
    testWidgets('renders children correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassToolbar(
              children: const [
                Text('Item 1'),
                Text('Item 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('respects height parameter', (tester) async {
      const height = 60.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassToolbar(
              height: height,
              children: const [],
            ),
          ),
        ),
      );

      final container = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SafeArea),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(container.height, height);
    });

    testWidgets('respects alignment parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassToolbar(
              alignment: MainAxisAlignment.spaceAround,
              children: const [],
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceAround);
    });

    testWidgets('wraps content in SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassToolbar(
              children: const [],
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
