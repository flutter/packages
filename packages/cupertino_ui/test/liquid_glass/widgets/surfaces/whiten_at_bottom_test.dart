// ignore_for_file: require_trailing_commas
// Smoke tests for the whiten feature:
//   - minimal-quality AdaptiveGlass renders the frosted whiten veil path
//   - GlassTabBar.searchable whiten-at-bottom engages/disengages with a
//     ScrollController without throwing
//   - whitenAtBottom: false opt-out builds

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

final _testTabs = [
  const GlassTab(label: 'Home', icon: Icon(Icons.home)),
  const GlassTab(label: 'Music', icon: Icon(Icons.music_note)),
];

GlassSearchBarConfig _basicSearchConfig() => GlassSearchBarConfig(
      onSearchToggle: (_) {},
    );

/// A scrollable page with the bar pinned over the bottom edge — the layout
/// the whiten-at-bottom feature is designed for. [barController] lets a test
/// hand the bar a different controller than the list (to exercise the
/// didUpdateWidget controller swap); it defaults to [controller].
Widget _buildScrollPage({
  required ScrollController controller,
  bool whitenAtBottom = true,
  ScrollController? barController,
}) {
  return createTestApp(
    theme: ThemeData(brightness: Brightness.light),
    child: Stack(
      children: [
        ListView.builder(
          controller: controller,
          itemCount: 60,
          itemBuilder: (context, i) => SizedBox(
            height: 40,
            child: Text('Row $i'),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 90,
            child: GlassTabBar.searchable(
              tabs: _testTabs,
              selectedIndex: 0,
              onTabSelected: (_) {},
              searchConfig: _basicSearchConfig(),
              scrollController: barController ?? controller,
              whitenAtBottom: whitenAtBottom,
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('AdaptiveGlass — whiten veil (minimal quality)', () {
    testWidgets('whitenStrength 0.6 builds and renders the frosted path',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const SizedBox(
          width: 200,
          height: 100,
          child: AdaptiveGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: 20),
            settings: LiquidGlassSettings(blur: 5, whitenStrength: 0.6),
            quality: GlassQuality.minimal,
            child: SizedBox.expand(),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });
  });

  group('GlassTabBar.searchable — whiten-at-bottom', () {
    testWidgets('boost engages at scroll bottom and releases at top',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_buildScrollPage(controller: controller));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Jump to the bottom — the whiten boost should animate in.
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // Jump back to the top — the boost should animate back out.
      controller.jumpTo(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('whitenAtBottom: false builds and stays inert', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildScrollPage(controller: controller, whitenAtBottom: false),
      );
      await tester.pump();

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('didUpdateWidget re-subscribes when the scrollController swaps',
        (tester) async {
      final controllerA = ScrollController();
      final controllerB = ScrollController();
      addTearDown(controllerA.dispose);
      addTearDown(controllerB.dispose);

      await tester.pumpWidget(_buildScrollPage(controller: controllerA));
      await tester.pump();

      // Same tree, new scroll source — the bar must drop the old listener,
      // subscribe to the new controller, and re-evaluate immediately.
      await tester.pumpWidget(
        _buildScrollPage(controller: controllerA, barController: controllerB),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // The new controller drives the boost once attached to the list too.
      await tester.pumpWidget(_buildScrollPage(controller: controllerB));
      await tester.pump();
      controllerB.jumpTo(controllerB.position.maxScrollExtent);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'didUpdateWidget re-evaluates when whitenAtBottom toggles at the bottom',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      // Engage the boost at the bottom…
      await tester.pumpWidget(_buildScrollPage(controller: controller));
      await tester.pump();
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // …then disable the feature while parked there. No scroll event fires,
      // so the toggle itself must release the boost.
      await tester.pumpWidget(
        _buildScrollPage(controller: controller, whitenAtBottom: false),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // And re-enabling re-engages it without any scrolling.
      await tester.pumpWidget(_buildScrollPage(controller: controller));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(GlassTabBar), findsOneWidget);
    });
  });
}
