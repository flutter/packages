// Regression tests for GitHub issue #175:
// _RenderLightweightGlass (and _RenderGlassEffect) never called
// markNeedsCompositingBitsUpdate() after async shader load, leaving a stale
// needsCompositing=false even when alwaysNeedsCompositing became true.
//
// These tests drive the render pipeline through a pumpAndSettle() so the
// framework runs _updateCompositingBits(). After the pump, needsCompositing
// must equal alwaysNeedsCompositing — the invariant the framework guarantees
// when markNeedsCompositingBitsUpdate() is called at the right time.
//
// alwaysNeedsCompositing is @protected on RenderObject; we access it
// intentionally here to verify the invariant, hence the ignore directive.
// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Minimal widget scaffold that exercises LightweightLiquidGlass without
/// requiring the real shader asset (which is unavailable in unit tests).
Widget _buildTabBar({
  required int selectedIndex,
  required void Function(int) onTabSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: LiquidGlassWidgets.wrap(
        child: SizedBox(
          height: 80,
          child: GlassTabBar.bottom(
            selectedIndex: selectedIndex,
            onTabSelected: onTabSelected,
            quality: GlassQuality.standard,
            tabs: const [
              GlassTab(label: 'A', icon: Icon(Icons.home)),
              GlassTab(label: 'B', icon: Icon(Icons.search)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Walks the render tree and returns all render objects whose runtimeType
/// name matches [typeName].
List<RenderObject> _findByTypeName(RenderObject root, String typeName) {
  final results = <RenderObject>[];
  void visit(RenderObject ro) {
    if (ro.runtimeType.toString() == typeName) results.add(ro);
    ro.visitChildren(visit);
  }

  visit(root);
  return results;
}

void main() {
  group('Compositing bits contract — issue #175', () {
    // ── _RenderLightweightGlass (Standard / GlassTabBar.bottom) ──────────────

    group('_RenderLightweightGlass', () {
      testWidgets(
        'needsCompositing == alwaysNeedsCompositing after initial pump '
        '(shader is null in test env → alwaysNeedsCompositing is false)',
        (tester) async {
          await tester.pumpWidget(_buildTabBar(
            selectedIndex: 0,
            onTabSelected: (_) {},
          ));
          await tester.pumpAndSettle();

          final ros = _findByTypeName(
            tester.binding.renderViews.first,
            '_RenderLightweightGlass',
          );

          expect(
            ros,
            isNotEmpty,
            reason: '_RenderLightweightGlass not found. '
                'Has the widget structure changed?',
          );

          for (final ro in ros) {
            expect(
              ro.needsCompositing,
              equals(ro.alwaysNeedsCompositing),
              reason: 'needsCompositing=${ro.needsCompositing} does not match '
                  'alwaysNeedsCompositing=${ro.alwaysNeedsCompositing}. '
                  'markNeedsCompositingBitsUpdate() was not called when the '
                  'predicate changed (stale bit — issue #175).',
            );
          }
        },
      );

      testWidgets(
        'needsCompositing == alwaysNeedsCompositing after tab switch '
        '(exercises the settings setter path)',
        (tester) async {
          int index = 0;
          late StateSetter outerSetState;

          await tester.pumpWidget(
            StatefulBuilder(builder: (context, s) {
              outerSetState = s;
              return _buildTabBar(
                selectedIndex: index,
                onTabSelected: (i) => outerSetState(() => index = i),
              );
            }),
          );
          await tester.pump();

          // Trigger a settings update via tab switch.
          await tester.tap(find.text('B').first, warnIfMissed: false);
          await tester.pumpAndSettle();

          final ros = _findByTypeName(
            tester.binding.renderViews.first,
            '_RenderLightweightGlass',
          );

          for (final ro in ros) {
            expect(
              ro.needsCompositing,
              equals(ro.alwaysNeedsCompositing),
              reason: 'Stale needsCompositing after settings update.',
            );
          }
        },
      );
    });

    // ── AdaptiveLiquidGlassLayer ─────────────────────────────────────────────

    group('AdaptiveLiquidGlassLayer compositing invariant', () {
      testWidgets(
        'needsCompositing == alwaysNeedsCompositing with blur > 0',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AdaptiveLiquidGlassLayer(
                  settings: const LiquidGlassSettings(blur: 8),
                  child: const SizedBox(width: 200, height: 200),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Covers both _RenderGlassEffect (Premium) and
          // _RenderLightweightGlass (Standard) depending on which path
          // the adaptive layer chose at runtime.
          for (final name in [
            '_RenderGlassEffect',
            '_RenderLightweightGlass',
          ]) {
            final ros = _findByTypeName(
              tester.binding.renderViews.first,
              name,
            );
            for (final ro in ros) {
              expect(
                ro.needsCompositing,
                equals(ro.alwaysNeedsCompositing),
                reason: '$name compositing bit is stale with blur=8.',
              );
            }
          }
        },
      );

      testWidgets(
        'needsCompositing == alwaysNeedsCompositing with blur == 0',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AdaptiveLiquidGlassLayer(
                  settings: const LiquidGlassSettings(blur: 0),
                  child: const SizedBox(width: 200, height: 200),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          for (final name in [
            '_RenderGlassEffect',
            '_RenderLightweightGlass',
          ]) {
            final ros = _findByTypeName(
              tester.binding.renderViews.first,
              name,
            );
            for (final ro in ros) {
              expect(
                ro.needsCompositing,
                equals(ro.alwaysNeedsCompositing),
                reason: '$name compositing bit is stale with blur=0.',
              );
            }
          }
        },
      );
    });
  });
}
