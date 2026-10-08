// ignore_for_file: require_trailing_commas
// Tests for adaptiveBrightness / onBrightnessChanged / brightnessOverride on
// GlassTabBar.bottom and GlassTabBar.searchable, plus the shared
// resolveBarLabelColor helper:
//   - classic path is untouched (no adaptive machinery in the tree)
//   - adaptiveBrightness without a scope renders and stays ambient
//   - brightnessOverride drives both bars and fires onBrightnessChanged
//   - the override reaches the bar subtree (MediaQuery / CupertinoTheme)
//   - label color lerps for dynamic colors, passes through custom colors
//   - end-to-end: bar over dark content in a scope flips dark

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_internal.dart'
    show resolveBarLabelColor;

/// Records the ambient brightness its build context sees — used as a tab
/// icon to verify the override layer reaches the bar internals.
class _BrightnessProbe extends StatelessWidget {
  const _BrightnessProbe(this.onBuild);

  final void Function(Brightness platform, Brightness? cupertino) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(
      MediaQuery.platformBrightnessOf(context),
      CupertinoTheme.of(context).brightness,
    );
    return const SizedBox(width: 16, height: 16);
  }
}

List<GlassTab> _tabs({Widget? probeIcon}) => [
      GlassTab(
        label: 'Home',
        icon: probeIcon ?? const Icon(CupertinoIcons.home),
      ),
      const GlassTab(
        label: 'Music',
        icon: Icon(CupertinoIcons.music_note),
      ),
    ];

Widget _wrapBar(Widget bar) => MaterialApp(
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: SizedBox(height: 100, child: bar),
      ),
    );

void main() {
  group('GlassTabBar.bottom — adaptive brightness plumbing', () {
    testWidgets('classic path mounts no adaptive machinery', (tester) async {
      await tester.pumpWidget(_wrapBar(GlassTabBar.bottom(
        tabs: _tabs(),
        selectedIndex: 0,
        onTabSelected: (_) {},
      )));
      expect(find.byType(GlassContentAwareBrightness), findsNothing);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('adaptiveBrightness without a scope stays ambient',
        (tester) async {
      await tester.pumpWidget(_wrapBar(GlassTabBar.bottom(
        tabs: _tabs(),
        selectedIndex: 0,
        onTabSelected: (_) {},
        adaptiveBrightness: true,
      )));
      expect(find.byType(GlassContentAwareBrightness), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('brightnessOverride drives the bar and its subtree',
        (tester) async {
      final override = ValueNotifier<Brightness>(Brightness.light);
      addTearDown(override.dispose);
      final flips = <Brightness>[];
      Brightness? probePlatform;
      Brightness? probeCupertino;

      await tester.pumpWidget(_wrapBar(GlassTabBar.bottom(
        tabs: _tabs(
          probeIcon: _BrightnessProbe((platform, cupertino) {
            probePlatform = platform;
            probeCupertino = cupertino;
          }),
        ),
        selectedIndex: 0,
        onTabSelected: (_) {},
        brightnessOverride: override,
        onBrightnessChanged: flips.add,
      )));
      expect(probePlatform, Brightness.light);

      override.value = Brightness.dark;
      await tester.pump();
      expect(flips, [Brightness.dark]);
      await tester.pump(const Duration(milliseconds: 250));
      expect(probePlatform, Brightness.dark);
      expect(probeCupertino, Brightness.dark);

      override.value = Brightness.light;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(flips, [Brightness.dark, Brightness.light]);
      expect(probePlatform, Brightness.light);
    });

    testWidgets('end-to-end: bar over dark content flips dark', (tester) async {
      final flips = <Brightness>[];
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: Scaffold(
            extendBody: true,
            body: GlassContentAwareContent(
              child: const ColoredBox(
                color: Color(0xFF000000),
                child: SizedBox.expand(),
              ),
            ),
            bottomNavigationBar: SizedBox(
              height: 100,
              child: GlassTabBar.bottom(
                tabs: _tabs(),
                selectedIndex: 0,
                onTabSelected: (_) {},
                adaptiveBrightness: true,
                onBrightnessChanged: flips.add,
              ),
            ),
          ),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await scope.sampleNow();
      });
      await tester.pump();
      expect(flips, [Brightness.dark]);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('GlassTabBar.searchable — adaptive brightness plumbing', () {
    Widget searchableBar({
      ValueListenable<Brightness>? override,
      ValueChanged<Brightness>? onBrightnessChanged,
      bool adaptive = false,
      Widget? probeIcon,
    }) {
      return _wrapBar(GlassTabBar.searchable(
        tabs: _tabs(probeIcon: probeIcon),
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
        adaptiveBrightness: adaptive,
        brightnessOverride: override,
        onBrightnessChanged: onBrightnessChanged,
      ));
    }

    testWidgets('classic path mounts no adaptive machinery', (tester) async {
      await tester.pumpWidget(searchableBar());
      expect(find.byType(GlassContentAwareBrightness), findsNothing);
    });

    testWidgets('adaptiveBrightness without a scope stays ambient',
        (tester) async {
      await tester.pumpWidget(searchableBar(adaptive: true));
      expect(find.byType(GlassContentAwareBrightness), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('brightnessOverride drives the bar and fires the callback',
        (tester) async {
      final override = ValueNotifier<Brightness>(Brightness.light);
      addTearDown(override.dispose);
      final flips = <Brightness>[];
      Brightness? probePlatform;

      await tester.pumpWidget(searchableBar(
        override: override,
        onBrightnessChanged: flips.add,
        probeIcon: _BrightnessProbe((platform, _) {
          probePlatform = platform;
        }),
      ));
      expect(probePlatform, Brightness.light);

      override.value = Brightness.dark;
      await tester.pump();
      expect(flips, [Brightness.dark]);
      await tester.pump(const Duration(milliseconds: 250));
      expect(probePlatform, Brightness.dark);
      await tester.pumpAndSettle();
    });
  });

  group('resolveBarLabelColor', () {
    Future<BuildContext> contextUnder(
      WidgetTester tester,
      Widget Function(Widget child) wrap,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(wrap(Builder(builder: (context) {
        captured = context;
        return const SizedBox();
      })));
      return captured;
    }

    testWidgets('classic path resolves the ambient label color',
        (tester) async {
      final context =
          await contextUnder(tester, (child) => MaterialApp(home: child));
      final color = resolveBarLabelColor(context, null);
      // Light ambient → the label's light variant.
      expect(color.toARGB32(), CupertinoColors.label.color.toARGB32());
    });

    testWidgets('dynamic label colors lerp with darkAmount', (tester) async {
      final context =
          await contextUnder(tester, (child) => MaterialApp(home: child));
      final light = resolveBarLabelColor(context, 0.0);
      final dark = resolveBarLabelColor(context, 1.0);
      final mid = resolveBarLabelColor(context, 0.5);
      expect(light.toARGB32(), CupertinoColors.label.color.toARGB32());
      expect(dark.toARGB32(), CupertinoColors.label.darkColor.toARGB32());
      expect(
        mid.toARGB32(),
        Color.lerp(
          CupertinoColors.label.color,
          CupertinoColors.label.darkColor,
          0.5,
        )!
            .toARGB32(),
      );
    });

    testWidgets('non-dynamic custom label colors pass through unchanged',
        (tester) async {
      const custom = Color(0xFF336699);
      final context = await contextUnder(
        tester,
        (child) => MaterialApp(
          home: CupertinoTheme(
            data: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                textStyle: TextStyle(color: custom),
              ),
            ),
            child: child,
          ),
        ),
      );
      expect(resolveBarLabelColor(context, 0.7), custom);
      expect(resolveBarLabelColor(context, null), custom);
    });

    testWidgets('a color-less text theme falls back to CupertinoColors.label',
        (tester) async {
      final context = await contextUnder(
        tester,
        (child) => MaterialApp(
          home: CupertinoTheme(
            data: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                textStyle: TextStyle(fontSize: 17),
              ),
            ),
            child: child,
          ),
        ),
      );
      final lerped = resolveBarLabelColor(context, 1.0);
      expect(lerped.toARGB32(), CupertinoColors.label.darkColor.toARGB32());
    });
  });
}
