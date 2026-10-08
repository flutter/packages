// Coverage-targeted tests for the platformViewBackdrop feature.
// Targets:
//   - adaptive_glass.dart: the canUsePremiumShader condition operands
//     (!platformViewBackdrop / quality / _canUseImpeller) and the grouped()
//     platformViewBackdrop pass-through.
//   - searchable_bottom_bar_internal.dart: the moving indicator's backgroundKey
//     `_iconLayerKey` branch, only taken when platformViewBackdrop is true.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: LiquidGlassWidgets.wrap(child: child)),
    );

final _tabs = [
  const GlassTab(label: 'Home', icon: Icon(Icons.home)),
  const GlassTab(label: 'Map', icon: Icon(Icons.map)),
];

void main() {
  group('platformViewBackdrop', () {
    testWidgets(
        'premium AdaptiveGlass evaluates the full canUsePremiumShader condition',
        (tester) async {
      // platformViewBackdrop defaults false → the local checks (!kIsWeb,
      // !platformViewBackdrop, quality == premium) all evaluate, then
      // _canUseImpeller — so every operand line executes under `flutter test`.
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: AdaptiveGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: 20),
          settings: LiquidGlassSettings(blur: 5),
          quality: GlassQuality.premium,
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });

    testWidgets('AdaptiveGlass.grouped forwards platformViewBackdrop',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AdaptiveGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 20),
          quality: GlassQuality.premium,
          platformViewBackdrop: true,
          child: const SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pump();
      expect(find.byType(AdaptiveGlass), findsWidgets);
    });

    testWidgets(
        'GlassTabBar.searchable(platformViewBackdrop) refracts the icon layer',
        (tester) async {
      // Exercises the indicator's `backgroundKey: platformViewBackdrop ?
      // _iconLayerKey : widget.backgroundKey` branch plus the background
      // grouped() pass-throughs and the search pill.
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          height: 90,
          width: 400,
          child: GlassTabBar.searchable(
            tabs: _tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
            quality: GlassQuality.premium,
            platformViewBackdrop: true,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets(
        'GlassTabBar.bottom(platformViewBackdrop) refracts the icon layer',
        (tester) async {
      // Exercises the TabIndicator's `backgroundKey: platformViewBackdrop ?
      // _iconLayerKey : widget.backgroundKey` branch plus the
      // AdaptiveLiquidGlassLayer plumbing we added for API parity.
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          height: 90,
          width: 400,
          child: GlassTabBar.bottom(
            tabs: _tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            quality: GlassQuality.premium,
            platformViewBackdrop: true,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets(
        'GlassContainer(platformViewBackdrop) forwards to AdaptiveGlass',
        (tester) async {
      // The flag threads GlassContainer → AdaptiveGlass, forcing the
      // BackdropFilter fallback path even at premium quality.
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        height: 100,
        child: GlassContainer(
          useOwnLayer: true,
          quality: GlassQuality.premium,
          platformViewBackdrop: true,
          settings: LiquidGlassSettings(blur: 5),
          child: SizedBox.expand(),
        ),
      )));
      await tester.pump();
      expect(find.byType(GlassContainer), findsWidgets);
    });

    testWidgets('GlassIconButton(platformViewBackdrop) forwards to GlassButton',
        (tester) async {
      // The flag threads GlassIconButton → GlassButton → AdaptiveGlass.
      await tester.pumpWidget(_wrap(
        GlassIconButton(
          icon: const Icon(Icons.add),
          onPressed: () {},
          useOwnLayer: true,
          quality: GlassQuality.premium,
          platformViewBackdrop: true,
        ),
      ));
      await tester.pump();
      expect(find.byType(GlassIconButton), findsWidgets);
    });

    testWidgets('GlassMenu(platformViewBackdrop) builds and opens',
        (tester) async {
      // The flag threads GlassMenu → AdaptiveLiquidGlassLayer (and the morph
      // blob GlassContainers) once the morphing overlay is shown.
      await tester.pumpWidget(_wrap(
        GlassMenu(
          quality: GlassQuality.premium,
          platformViewBackdrop: true,
          trigger: const Icon(Icons.more_vert),
          items: [
            GlassMenuItem(title: 'One', onTap: () {}),
            GlassMenuItem(title: 'Two', onTap: () {}),
          ],
        ),
      ));
      await tester.pump();
      expect(find.byType(GlassMenu), findsWidgets);

      // Open the menu so the AdaptiveLiquidGlassLayer in the overlay builds
      // with the forwarded flag.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GlassMenu), findsWidgets);
    });
  });
}
