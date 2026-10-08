import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _testTabs = [
  GlassTab(label: 'For You', icon: Icon(CupertinoIcons.news)),
  GlassTab(label: 'Following', icon: Icon(CupertinoIcons.person_2)),
  GlassTab(label: 'Saved', icon: Icon(CupertinoIcons.bookmark)),
];

/// Expanded height with the defaults: barHeight 64 + verticalPadding 20 * 2.
const _expandedHeight = 104.0;

/// Minimized: minimizedBarHeight 50 + 40.
const _minimizedHeight = 90.0;

double _barHeight(WidgetTester tester) =>
    tester.widget<GlassTabBar>(find.byType(GlassTabBar)).preferredSize.height;

/// A scaffold whose body scrolls under a minimizable bar.
Widget _app({
  required GlassTabBarMinimizeController minimize,
  required ScrollController scroll,
  int itemCount = 60,
  bool extendBody = true,
  Widget? bottomAccessory,
  GlassTabBarAccessoryPlacement? accessoryPlacement,
}) {
  return MaterialApp(
    home: GlassScaffold(
      extendBody: extendBody,
      edgeFade: false,
      body: ListView.builder(
        controller: scroll,
        itemCount: itemCount,
        itemBuilder: (_, i) => SizedBox(height: 60, child: Text('row $i')),
      ),
      bottomBar: GlassTabBar.minimizable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        minimizeController: minimize,
        scrollController: scroll,
        onMinimizedTabTap: minimize.expand,
        bottomAccessory: bottomAccessory,
        bottomAccessoryHeight: bottomAccessory == null ? null : 48,
        bottomAccessoryPlacement: accessoryPlacement,
        maskingQuality: MaskingQuality.off,
      ),
    ),
  );
}

/// Drags the list by [dy] in many small steps, the way a finger actually
/// moves. `tester.drag` dispatches the whole delta in about two move events,
/// which cannot exercise a threshold that accumulates.
Future<void> _slowDrag(WidgetTester tester, double dy) async {
  final gesture = await tester.startGesture(const Offset(200, 300));
  const steps = 12;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, dy / steps));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  group('GlassTabBar.minimizable — scroll to minimize', () {
    testWidgets('a slow scroll down minimizes, and back up expands',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: scroll));
      await tester.pumpAndSettle();
      expect(_barHeight(tester), _expandedHeight);

      await _slowDrag(tester, -80); // content up = scrolling down
      expect(minimize.minimized, isTrue);
      expect(_barHeight(tester), _minimizedHeight);

      await _slowDrag(tester, 40);
      expect(minimize.minimized, isFalse);
      expect(_barHeight(tester), _expandedHeight);
    });

    testWidgets('a fling minimizes and stays minimized once it settles',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: scroll));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(ListView), const Offset(0, -300), 2000);
      await tester.pumpAndSettle();

      // The state is latched, so it survives userScrollDirection going idle
      // when the ballistic activity ends — that is what makes momentum safe.
      expect(minimize.minimized, isTrue);
      expect(_barHeight(tester), _minimizedHeight);
    });

    testWidgets('scrolling back to the top expands', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: scroll));
      await tester.pumpAndSettle();
      await _slowDrag(tester, -80);
      expect(minimize.minimized, isTrue);

      await tester.fling(find.byType(ListView), const Offset(0, 600), 3000);
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, 0);
      expect(minimize.minimized, isFalse);
    });

    testWidgets('content shorter than the viewport never minimizes',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(
        _app(minimize: minimize, scroll: scroll, itemCount: 2),
      );
      await tester.pumpAndSettle();

      await _slowDrag(tester, -120);
      expect(minimize.minimized, isFalse);
      expect(_barHeight(tester), _expandedHeight);
    });

    testWidgets('tapping the minimized circle expands', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: scroll));
      await tester.pumpAndSettle();
      await _slowDrag(tester, -80);
      expect(minimize.minimized, isTrue);

      await tester.tap(find.byIcon(CupertinoIcons.news).first);
      await tester.pumpAndSettle();
      expect(minimize.minimized, isFalse);
      expect(_barHeight(tester), _expandedHeight);
    });

    testWidgets('never does not minimize', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.never,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: scroll));
      await tester.pumpAndSettle();

      await _slowDrag(tester, -200);
      expect(minimize.minimized, isFalse);
    });
  });

  group('GlassTabBar.minimizable — scaffold synchronisation', () {
    testWidgets('the body inset tracks the bar with extendBody: false',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(
        _app(minimize: minimize, scroll: scroll, extendBody: false),
      );
      await tester.pumpAndSettle();
      final expandedBody = tester.getRect(find.byType(ListView));

      minimize.minimize();
      await tester.pumpAndSettle();
      final minimizedBody = tester.getRect(find.byType(ListView));

      // The bar shrank by 14, so the body it sits above grows by the same.
      expect(
        minimizedBody.height - expandedBody.height,
        _expandedHeight - _minimizedHeight,
        reason: 'GlassScaffold must re-read preferredSize when the bar '
            'minimizes from its own state',
      );
    });

    testWidgets('the bar re-renders even though the widget instance is reused',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: scroll));
      await tester.pumpAndSettle();
      final expandedBar = tester.getSize(find.byType(GlassTabBar));

      // No pumpWidget — nothing above the bar rebuilds, so only the bar's own
      // subscription can drive this.
      minimize.minimize();
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(GlassTabBar)).height,
          lessThan(expandedBar.height));
    });
  });

  group('GlassTabBar.minimizable — bottom accessory placement', () {
    late GlassTabBarAccessoryPlacement observed;

    Widget probe() => Builder(
          builder: (context) {
            observed = GlassTabBarAccessoryPlacementScope.of(context);
            return const SizedBox(height: 48, child: Text('mini player'));
          },
        );

    testWidgets('moves inline when the bar minimizes and no placement is set',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(
        minimize: minimize,
        scroll: scroll,
        bottomAccessory: probe(),
      ));
      await tester.pumpAndSettle();
      expect(observed, GlassTabBarAccessoryPlacement.expanded);

      minimize.minimize();
      await tester.pumpAndSettle();
      expect(observed, GlassTabBarAccessoryPlacement.inline);
    });

    testWidgets('an explicit placement always wins', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(
        minimize: minimize,
        scroll: scroll,
        bottomAccessory: probe(),
        accessoryPlacement: GlassTabBarAccessoryPlacement.expanded,
      ));
      await tester.pumpAndSettle();

      minimize.minimize();
      await tester.pumpAndSettle();
      expect(observed, GlassTabBarAccessoryPlacement.expanded);
    });

    testWidgets(
        'the reserved height drops to match, so the scaffold stays in '
        'sync', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(
        minimize: minimize,
        scroll: scroll,
        bottomAccessory: probe(),
      ));
      await tester.pumpAndSettle();
      expect(_barHeight(tester), greaterThan(_expandedHeight),
          reason: 'expanded, the accessory adds its own row above the pill');

      minimize.minimize();
      await tester.pumpAndSettle();

      // Inline, the accessory sits beside the pill and costs no height, so the
      // bar is exactly as tall as one with no accessory at all. This is the
      // invariant the shared resolver exists to hold: preferredSize is what
      // GlassScaffold insets the body by, and the layout engine has to draw
      // the same thing.
      expect(_barHeight(tester), _minimizedHeight);
      expect(tester.getSize(find.byType(GlassTabBar)).height, _minimizedHeight);
    });

    testWidgets('searchable does not pull its accessory inline on search',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassScaffold(
          body: const SizedBox.expand(),
          bottomBar: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: true,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
            bottomAccessory: probe(),
            bottomAccessoryHeight: 48,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(observed, GlassTabBarAccessoryPlacement.expanded,
          reason: 'a search field expanding is not the bar minimizing');
    });
  });

  group('GlassTabBar.minimizable — lifecycle', () {
    testWidgets('asserts when both a controller and minimized: true are passed',
        (tester) async {
      expect(
        () => GlassTabBar.minimizable(
          tabs: _testTabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          minimized: true,
          minimizeController: GlassTabBarMinimizeController(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
        'swapping the scroll controller re-targets without a spurious '
        'minimize', (tester) async {
      final first = ScrollController();
      addTearDown(first.dispose);
      final second = ScrollController(initialScrollOffset: 900);
      addTearDown(second.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      await tester.pumpWidget(_app(minimize: minimize, scroll: first));
      await tester.pumpAndSettle();

      // A new tab with its own, already-scrolled list. The cross-controller
      // delta would be +900 if the baseline were not reset.
      await tester.pumpWidget(_app(minimize: minimize, scroll: second));
      await tester.pumpAndSettle();

      expect(minimize.minimized, isFalse);
      expect(minimize.scrollController, same(second));
    });

    testWidgets('one controller on two mounted lists does not throw',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final minimize = GlassTabBarMinimizeController(
        behavior: GlassBarMinimizeBehavior.onScrollDown,
      );
      addTearDown(minimize.dispose);

      // The AnimatedSwitcher / Navigator-transition case: two scroll views
      // share one controller, so ScrollController.position throws.
      await tester.pumpWidget(MaterialApp(
        home: GlassScaffold(
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scroll,
                  children: const [SizedBox(height: 2000)],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  children: const [SizedBox(height: 2000)],
                ),
              ),
            ],
          ),
          bottomBar: GlassTabBar.minimizable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            minimizeController: minimize,
            scrollController: scroll,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
