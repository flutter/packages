import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group(
      'Issue #356: Interactive widgets dispose CurvedAnimation and ValueNotifiers',
      () {
    testWidgets('GlassButton disposes everything cleanly on unmount',
        // Enable leak tracking specifically on this test
        experimentalLeakTesting: LeakTesting.settings.withTracked(
          allNotDisposed: true,
        ), (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GlassButton(
              icon: const Icon(Icons.add),
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('GlassSlider disposes everything cleanly on unmount',
        experimentalLeakTesting: LeakTesting.settings.withTracked(
          allNotDisposed: true,
        ), (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GlassSlider(
              value: 0.5,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('GlassSwitch disposes everything cleanly on unmount',
        experimentalLeakTesting: LeakTesting.settings.withTracked(
          allNotDisposed: true,
        ), (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GlassSwitch(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('GlassPageControl disposes everything cleanly on unmount',
        experimentalLeakTesting: LeakTesting.settings.withTracked(
          allNotDisposed: true,
        ), (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GlassPageControl(
              count: 3,
              currentPage: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('GlassSheet disposes everything cleanly on unmount',
        experimentalLeakTesting: LeakTesting.settings.withTracked(
          allNotDisposed: true,
        ), (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GlassSheet(
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
