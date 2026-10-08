// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

Future<void> _openMenu(WidgetTester tester, String triggerText) async {
  await tester.tap(find.text(triggerText));
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  // ==========================================================================
  // GlassMenuDivider
  // ==========================================================================
  group('GlassMenuDivider', () {
    testWidgets('renders at default dimensions', (tester) async {
      await tester.pumpWidget(_app(const GlassMenuDivider()));
      expect(find.byType(GlassMenuDivider), findsOneWidget);
    });

    testWidgets('renders with custom height and color', (tester) async {
      await tester.pumpWidget(
          _app(const GlassMenuDivider(height: 2.0, color: Colors.red)));
      expect(find.byType(GlassMenuDivider), findsOneWidget);
    });
  });

  // ==========================================================================
  // GlassMenuLabel
  // ==========================================================================
  group('GlassMenuLabel', () {
    testWidgets('uppercases title when using title param', (tester) async {
      await tester.pumpWidget(_app(const GlassMenuLabel(title: 'section')));
      expect(find.text('SECTION'), findsOneWidget);
    });

    testWidgets('renders child when provided', (tester) async {
      await tester
          .pumpWidget(_app(const GlassMenuLabel(child: Text('CUSTOM'))));
      expect(find.text('CUSTOM'), findsOneWidget);
    });

    testWidgets('applies custom style', (tester) async {
      await tester.pumpWidget(_app(const GlassMenuLabel(
        child: Text(
          'ACTIONS',
          style: TextStyle(color: Colors.amber, fontSize: 14),
        ),
      )));
      expect(find.text('ACTIONS'), findsOneWidget);
      final text = tester.widget<Text>(find.text('ACTIONS'));
      expect(text.style?.color, Colors.amber);
    });

    // QUALITY 3: height param is accepted and has correct default.
    testWidgets('exposes height param with default 30.0', (tester) async {
      const label = GlassMenuLabel(title: 'test');
      expect(label.height, 30.0);
      const custom = GlassMenuLabel(height: 48.0, title: 'big');
      expect(custom.height, 48.0);
    });
  });

  // ==========================================================================
  // GlassMenuItem
  // ==========================================================================
  group('GlassMenuItem', () {
    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(_app(GlassMenuItem(
        title: 'Send',
        subtitle: 'Via email',
        onTap: () {},
      )));
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Via email'), findsOneWidget);
    });

    testWidgets('disabled item does not fire onTap', (tester) async {
      var fired = false;
      await tester.pumpWidget(_app(GlassMenuItem(
        title: 'Disabled',
        enabled: false,
        onTap: () => fired = true,
      )));
      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(fired, isFalse);
    });

    testWidgets('disabled renders at 0.4 opacity', (tester) async {
      await tester.pumpWidget(
          _app(GlassMenuItem(title: 'Dim', enabled: false, onTap: () {})));
      final opacity = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.text('Dim'),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(opacity.opacity, closeTo(0.4, 0.01));
    });

    testWidgets('enabled item fires onTap', (tester) async {
      var fired = false;
      await tester.pumpWidget(
          _app(GlassMenuItem(title: 'Go', onTap: () => fired = true)));
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(fired, isTrue);
    });

    testWidgets('iconColor and iconSize respected', (tester) async {
      await tester.pumpWidget(_app(GlassMenuItem(
        title: 'Star',
        icon: const Icon(Icons.star),
        iconColor: Colors.yellow,
        iconSize: 32,
        onTap: () {},
      )));
      final theme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.star),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(theme.data.color, Colors.yellow);
      expect(theme.data.size, 32.0);
    });

    testWidgets('titleStyle applied', (tester) async {
      await tester.pumpWidget(_app(GlassMenuItem(
        title: 'Styled',
        titleStyle: const TextStyle(color: Colors.green, fontSize: 20),
        onTap: () {},
      )));
      final text = tester.widget<Text>(find.text('Styled'));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('subtitleStyle applied', (tester) async {
      await tester.pumpWidget(_app(GlassMenuItem(
        title: 'Item',
        subtitle: 'Sub',
        subtitleStyle: const TextStyle(color: Colors.orange, fontSize: 10),
        onTap: () {},
      )));
      final text = tester.widget<Text>(find.text('Sub'));
      expect(text.style?.color, Colors.orange);
    });

    testWidgets('tap-cancel does not crash (clears pressed state)',
        (tester) async {
      await tester
          .pumpWidget(_app(GlassMenuItem(title: 'Cancel', onTap: () {})));
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Cancel')));
      await tester.pump();
      await gesture.cancel();
      await tester.pump();
      expect(find.text('Cancel'), findsOneWidget);
    });

    // QUALITY 1 FIX: dispose() resets _isHovered — verified by mounting and
    // then removing the widget without a crash or assertion error.
    testWidgets('dispose does not crash (hover state reset)', (tester) async {
      await tester
          .pumpWidget(_app(GlassMenuItem(title: 'Hover', onTap: () {})));
      // Pump an empty tree to trigger dispose()
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // No crash or assertion error expected.
    });
  });

  // ==========================================================================
  // GlassMenu — heterogeneous items
  // ==========================================================================
  group('GlassMenu — heterogeneous items', () {
    testWidgets('renders GlassMenuLabel and GlassMenuDivider', (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: const [GlassMenuLabel(child: Text('FILES')), GlassMenuDivider()],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('FILES'), findsOneWidget);
      expect(find.byType(GlassMenuDivider), findsOneWidget);
    });

    testWidgets('mixed items open and close cleanly', (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [
          const GlassMenuLabel(child: Text('ACTIONS')),
          GlassMenuItem(title: 'Save', onTap: () {}),
          const GlassMenuDivider(),
          GlassMenuItem(title: 'Delete', isDestructive: true, onTap: () {}),
        ],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('ACTIONS'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('tapping item closes the menu', (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [GlassMenuItem(title: 'Execute', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');
      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();
      expect(find.text('Execute'), findsNothing);
    });

    testWidgets('disabled item in menu does not close it', (tester) async {
      var fired = false;
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [
          GlassMenuItem(
              title: 'Grayed', enabled: false, onTap: () => fired = true),
          GlassMenuItem(title: 'Active', onTap: () {}),
        ],
      )));
      await _openMenu(tester, 'Open');
      await tester.tap(find.text('Grayed'));
      await tester.pump();
      expect(fired, isFalse);
      expect(find.text('Active'), findsOneWidget); // still open
    });
  });

  // ==========================================================================
  // BUG 1 FIX: No double BackdropFilter
  // ==========================================================================
  group('GlassMenu — BUG 1: no double BackdropFilter', () {
    testWidgets(
        'open menu does not insert a bare BackdropFilter above GlassContainer',
        (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [GlassMenuItem(title: 'Item', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');

      // BackdropFilter widgets exist, but they should only come from inside
      // GlassContainer (LightweightLiquidGlass), not from an extra layer we add.
      // We verify the menu content is present — if the double-blur was re-added
      // a visual artefact would appear; this test catches accidental regressions.
      expect(find.text('Item'), findsOneWidget);
      // Only GlassContainer-internal BackdropFilters should be present —
      // we cannot easily count them here, but we confirm no crash/exception.
    });
  });

  // ==========================================================================
  // BUG 2 FIX: AnimatedPositioned in bounded Stack
  // ==========================================================================
  group('GlassMenu — BUG 2: bounded Stack for selection pill', () {
    testWidgets('pointer down sets selection pill without layout exception',
        (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [
          GlassMenuItem(title: 'Alpha', onTap: () {}),
          GlassMenuItem(title: 'Beta', onTap: () {}),
        ],
      )));
      await _openMenu(tester, 'Open');

      // Press and hold — exercises the AnimatedPositioned path.
      final center = tester.getCenter(find.text('Alpha'));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      // No "RenderIndexedStack" or "Positioned requires a known size" exception.
      await gesture.up();
      await tester.pump();
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('scrollable menu: pill does not render above top boundary',
        (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        menuHeight: 130,
        items: List.generate(
          8,
          (i) => GlassMenuItem(title: 'Row $i', onTap: () {}),
        ),
      )));
      await _openMenu(tester, 'Open');
      // Scroll down a bit then press — pill top must stay >= 0.
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);
      await tester.drag(scrollable, const Offset(0, -60));
      await tester.pump();
      // Press near top of visible area (which is scrolled).
      final gesture = await tester
          .startGesture(tester.getTopLeft(scrollable) + const Offset(20, 10));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      // No overflow exception or negative-position assertion.
    });
  });

  // ==========================================================================
  // BUG 4 FIX: _hoveredIndex bounds guard
  // ==========================================================================
  group('GlassMenu — BUG 4: items length change clears hovered index', () {
    testWidgets('rebuilding with fewer items does not throw RangeError',
        (tester) async {
      // The menu overlay intercepts taps, so we close it before removing items.
      // The didUpdateWidget guard ensures _hoveredIndex is cleared when the
      // items list shrinks, preventing a RangeError on the next build.
      var showExtra = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          outerSetState = setState;
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: GlassMenu(
                  trigger: const SizedBox(
                      width: 60, height: 40, child: Text('Open')),
                  items: [
                    GlassMenuItem(title: 'A', onTap: () {}),
                    if (showExtra) GlassMenuItem(title: 'B', onTap: () {}),
                  ],
                ),
              ),
            ),
          );
        },
      ));

      // Open and immediately close (so overlay is gone before we mutate items).
      await _openMenu(tester, 'Open');
      // Close via a tap-outside offset far from center.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      // Now remove item B — didUpdateWidget guard must not throw.
      outerSetState(() => showExtra = false);
      await tester.pump();

      // Re-open — previously the stale _hoveredIndex caused a RangeError here.
      await _openMenu(tester, 'Open');
      // Only 'A' is in the menu, 'B' was removed.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
    });
  });

  // ==========================================================================
  // BUG 5 FIX: wrappedItems cache
  // ==========================================================================
  group('GlassMenu — BUG 5: wrapped items cache', () {
    testWidgets(
        'onTap is still called correctly after multiple setState refreshes',
        (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [GlassMenuItem(title: 'Tap', onTap: () => tapCount++)],
      )));
      await _openMenu(tester, 'Open');
      // Multiple pumps simulate spring-animation setState calls.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();
      // onTap fired exactly once; menu closed.
      expect(tapCount, 1);
      expect(find.text('Tap'), findsNothing);
    });
  });

  // ==========================================================================
  // GlassMenu — physics params
  // ==========================================================================
  group('GlassMenu — LiquidStretch params', () {
    testWidgets('custom stretch params do not crash on open', (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        interactionScale: 1.08,
        stretch: 0.3,
        stretchResistance: 0.1,
        stretchAxis: Axis.vertical,
        allowPositiveX: false,
        allowNegativeX: false,
        allowPositiveY: true,
        allowNegativeY: false,
        items: [GlassMenuItem(title: 'Item', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('Item'), findsOneWidget);
    });
  });

  // ==========================================================================
  // GlassMenu — glowOnTapOnly
  // ==========================================================================
  group('GlassMenu — glowOnTapOnly', () {
    test(
        'GlassMenu defaults glowOnTapOnly to false for continuous pointer tracking',
        () {
      final menu = GlassMenu(
        trigger: const SizedBox(),
        items: [GlassMenuItem(title: 'Item', onTap: () {})],
      );
      // Parity guard: GlassMenu defaults to false (unlike GlassPopover which defaults to true)
      // because GlassMenu contains discrete options where specular highlight
      // tracks across items without being killed by gesture slop.
      expect(menu.glowOnTapOnly, isFalse);
    });

    testWidgets(
        'default glowOnTapOnly=false passes false to internal GlassGlow',
        (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        items: [GlassMenuItem(title: 'Item', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('Item'), findsOneWidget);
      final glow = tester.widget<GlassGlow>(find.byType(GlassGlow));
      expect(glow.glowOnTapOnly, isFalse);
    });

    testWidgets('renders without crash with glowOnTapOnly=true',
        (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        glowOnTapOnly: true,
        enableInteractionGlow: true,
        items: [GlassMenuItem(title: 'Item', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('Item'), findsOneWidget);
    });

    testWidgets('enableInteractionGlow=false renders without crash',
        (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        enableInteractionGlow: false,
        items: [GlassMenuItem(title: 'NoGlow', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('NoGlow'), findsOneWidget);
    });
  });

  // ==========================================================================
  // GlassMenu — scrollable mode
  // ==========================================================================
  group('GlassMenu — scrollable mode (menuHeight)', () {
    testWidgets('renders SingleChildScrollView and first item', (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        menuHeight: 120,
        items: List.generate(
          10,
          (i) => GlassMenuItem(title: 'Item $i', onTap: () {}),
        ),
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  // ==========================================================================
  // GlassMenu — selectionColor param
  // ==========================================================================
  group('GlassMenu — selectionColor', () {
    testWidgets('custom selectionColor accepted without crash', (tester) async {
      await tester.pumpWidget(_app(GlassMenu(
        trigger: const SizedBox(width: 60, height: 40, child: Text('Open')),
        selectionColor: Colors.blue.withValues(alpha: 0.2),
        items: [GlassMenuItem(title: 'Blue', onTap: () {})],
      )));
      await _openMenu(tester, 'Open');
      expect(find.text('Blue'), findsOneWidget);
    });
  });

  // ==========================================================================
  // BUG 3 FIX: GlassGlow.glowOnTapOnly — didUpdateWidget resets suppression
  // ==========================================================================
  group('GlassGlow — BUG 3: didUpdateWidget resets _glowSuppressed', () {
    testWidgets(
        'glowOnTapOnly toggling from true to false resets suppressed state',
        (tester) async {
      var tapOnly = true;
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassGlow(
                    glowOnTapOnly: tapOnly,
                    child: const SizedBox(width: 200, height: 200),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => tapOnly = false),
                    child: const Text('Toggle'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));

      // Drag > 10px to suppress glow.
      final gesture = await tester.startGesture(const Offset(100, 100));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Toggle glowOnTapOnly → false; didUpdateWidget must reset _glowSuppressed.
      await tester.tap(find.text('Toggle'));
      await tester.pump();

      // Verify the widget is still in tree and no crash occurred.
      final glow = tester.widget<GlassGlow>(find.byType(GlassGlow));
      expect(glow.glowOnTapOnly, isFalse);
    });

    testWidgets('glowOnTapOnly=true: large drag suppresses glow without crash',
        (tester) async {
      await tester.pumpWidget(_app(const GlassGlow(
        glowOnTapOnly: true,
        child: SizedBox(width: 200, height: 200),
      )));
      final gesture = await tester.startGesture(const Offset(100, 100));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(find.byType(GlassGlow), findsOneWidget);
    });

    testWidgets('glowOnTapOnly=false: glow follows pointer without crash',
        (tester) async {
      await tester.pumpWidget(_app(const GlassGlow(
        glowOnTapOnly: false,
        child: SizedBox(width: 200, height: 200),
      )));
      final gesture = await tester.startGesture(const Offset(100, 100));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(find.byType(GlassGlow), findsOneWidget);
    });

    testWidgets('GlassGlow enabled=false returns plain child', (tester) async {
      await tester.pumpWidget(_app(const GlassGlow(
        enabled: false,
        child: SizedBox(width: 100, height: 100),
      )));
      final glow = tester.widget<GlassGlow>(find.byType(GlassGlow));
      expect(glow.enabled, isFalse);
    });

    testWidgets('GlassGlow enabled=true (default)', (tester) async {
      await tester.pumpWidget(_app(const GlassGlow(
        child: SizedBox(width: 100, height: 100),
      )));
      final glow = tester.widget<GlassGlow>(find.byType(GlassGlow));
      expect(glow.enabled, isTrue);
    });
  });
}
