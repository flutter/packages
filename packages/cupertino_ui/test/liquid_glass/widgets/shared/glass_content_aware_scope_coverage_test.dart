// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for the content-aware brightness system.
// These exercise branches NOT covered by glass_content_aware_scope_test.dart:
//   - requestSample coalescing and after-dispose guard
//   - manual register(): custom grids, brightness getter, double cancel,
//     cancel-during-delivery, null/throwing controlBox providers
//   - second GlassContentAwareContent assert + non-matching detach
//   - synthetic scroll notifications: double Start, End without Start,
//     Overscroll, UserScroll fall-through, ScrollMetrics (idle vs scrolling)
//   - didUpdateWidget sampleInterval restart (active and idle)
//   - _sample early returns: no content, no subscriptions, control outside
//     the boundary, all-controls-skipped
//   - backgroundColor: explicit param and ambient-dark default
//   - consumer flipDuration/flipCurve precedence (widget > scope > default)
//   - consumer didUpdateWidget: override swaps and grid changes
//   - consumer without MediaQuery ancestor

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> _settleSample(
  WidgetTester tester,
  GlassContentAwareScopeState scope,
) {
  return tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await scope.sampleNow();
  });
}

ScrollMetrics _metrics() => FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 1000,
      pixels: 100,
      viewportDimension: 600,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 3.0,
    );

void main() {
  group('GlassContentAwareScopeState — sampling guards', () {
    testWidgets('requestSample coalesces and is a no-op after dispose',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(child: Container()),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      scope.requestSample();
      scope.requestSample(); // coalesced — _samplePending short-circuits
      await tester.pump();
      // Dispose, then request again: the !mounted guard returns.
      await tester.pumpWidget(Container());
      scope.requestSample();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposing the scope cancels live registrations',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(child: Container()),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final sub = scope.register(
        controlBox: () => null,
        onBrightnessChanged: (_) {},
        initialBrightness: Brightness.light,
      );
      // Tear the scope down while the registration is still live.
      await tester.pumpWidget(Container());
      // Cancelling afterwards is a safe no-op.
      sub.cancel();
      expect(tester.takeException(), isNull);
    });

    testWidgets('samples are skipped while the boundary is mid-paint',
        (tester) async {
      // Regression guard: the mid-paint check must stay inside an assert
      // closure — debugNeedsPaint is debug-only and reading it in profile/
      // release builds throws (which the defensive catch would swallow,
      // silently disabling the sampler).
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: GlassContentAwareContent(
            child: const ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final boundary = tester.renderObject(
        find
            .descendant(
                of: find.byType(GlassContentAwareContent),
                matching: find.byType(RepaintBoundary))
            .first,
      ) as RenderRepaintBoundary;
      var flips = 0;
      final sub = scope.register(
        controlBox: () => boundary,
        onBrightnessChanged: (_) => flips++,
        initialBrightness: Brightness.light,
      );
      boundary.markNeedsPaint();
      // Returns before capturing — the boundary is dirty.
      await scope.sampleNow();
      expect(flips, 0);
      await tester.pump();
      sub.cancel();
    });

    testWidgets('sampling without content or subscriptions is inert',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          // No GlassContentAwareContent and no consumers.
          child: ListView(children: [Container(height: 2000)]),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      // No subscriptions → first early return.
      await scope.sampleNow();
      // Subscription but no content → boundary early return.
      final sub = scope.register(
        controlBox: () => null,
        onBrightnessChanged: (_) {},
        initialBrightness: Brightness.light,
      );
      await scope.sampleNow();
      expect(sub.brightness, Brightness.light);
      sub.cancel();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'controls that are unmounted, outside the boundary, or throwing '
        'are skipped', (tester) async {
      final barKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: Column(
            children: [
              // Content boundary only covers the top half of the screen.
              Expanded(
                child: GlassContentAwareContent(
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
              // The "control" lives below the boundary — its rect cannot
              // intersect the captured image.
              SizedBox(key: barKey, height: 80, width: 400),
            ],
          ),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));

      var outsideFlips = 0;
      final outside = scope.register(
        controlBox: () =>
            barKey.currentContext!.findRenderObject() as RenderBox,
        onBrightnessChanged: (_) => outsideFlips++,
        initialBrightness: Brightness.light,
      );
      final unmounted = scope.register(
        controlBox: () => null,
        onBrightnessChanged: (_) {},
        initialBrightness: Brightness.light,
      );
      // With every control skipped, work.isEmpty returns before capturing.
      await _settleSample(tester, scope);
      expect(outsideFlips, 0);
      expect(outside.brightness, Brightness.light);
      unmounted.cancel();
      outside.cancel();
      outside.cancel(); // double-cancel is safe

      // A throwing provider lands in the defensive catch.
      final throwing = scope.register(
        controlBox: () => throw StateError('boom'),
        onBrightnessChanged: (_) {},
        initialBrightness: Brightness.light,
      );
      await _settleSample(tester, scope);
      expect(throwing.brightness, Brightness.light);
      throwing.cancel();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'a verdict callback can cancel a later subscription mid-'
        'delivery', (tester) async {
      final contentKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: GlassContentAwareContent(
            child: ColoredBox(key: contentKey, color: const Color(0xFF000000)),
          ),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      RenderBox box() =>
          contentKey.currentContext!.findRenderObject() as RenderBox;

      late GlassContentAwareSubscription second;
      var secondFlips = 0;
      final first = scope.register(
        controlBox: box,
        onBrightnessChanged: (_) => second.cancel(),
        initialBrightness: Brightness.light,
        gridColumns: 2,
        gridRows: 2,
      );
      second = scope.register(
        controlBox: box,
        onBrightnessChanged: (_) => secondFlips++,
        initialBrightness: Brightness.light,
      );
      await _settleSample(tester, scope);
      // First flipped dark and cancelled the second before delivery.
      expect(first.brightness, Brightness.dark);
      expect(secondFlips, 0);
      first.cancel();
    });

    testWidgets('explicit backgroundColor decides unpainted pixels',
        (tester) async {
      // The content paints nothing, so every pixel is transparent and the
      // verdict is decided entirely by the substituted background.
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          backgroundColor: const Color(0xFF000000),
          child: GlassContentAwareContent(
            child: const SizedBox.expand(),
          ),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final contentBox = tester
          .renderObject(find.byType(GlassContentAwareContent)) as RenderBox;
      var flipped = Brightness.light;
      final sub = scope.register(
        controlBox: () => contentBox,
        onBrightnessChanged: (b) => flipped = b,
        initialBrightness: Brightness.light,
      );
      await _settleSample(tester, scope);
      expect(flipped, Brightness.dark);
      sub.cancel();
    });

    testWidgets('default background follows a dark ambient brightness',
        (tester) async {
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.dark),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: GlassContentAwareScope(
            child: GlassContentAwareContent(
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      final contentBox = tester
          .renderObject(find.byType(GlassContentAwareContent)) as RenderBox;
      var flipped = Brightness.light;
      final sub = scope.register(
        controlBox: () => contentBox,
        onBrightnessChanged: (b) => flipped = b,
        initialBrightness: Brightness.light,
      );
      await _settleSample(tester, scope);
      expect(flipped, Brightness.dark);
      sub.cancel();
    });
  });

  group('GlassContentAwareScope — scroll notification handling', () {
    testWidgets('synthetic notifications drive the sampler state machine',
        (tester) async {
      late BuildContext innerContext;
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: Builder(builder: (context) {
            innerContext = context;
            return Container();
          }),
        ),
      ));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));

      // End without Start: early return, sampler stays idle.
      ScrollEndNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isFalse);

      // UserScrollNotification falls through every branch.
      UserScrollNotification(
        metrics: _metrics(),
        context: innerContext,
        direction: ScrollDirection.idle,
      ).dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isFalse);

      // Start begins periodic sampling; a second Start is a no-op.
      ScrollStartNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isTrue);
      ScrollStartNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isTrue);

      // Let the periodic timer tick a few times (no content — inert).
      await tester.pump(const Duration(milliseconds: 400));

      // Metrics change while scrolling: no extra idle sample is scheduled.
      ScrollMetricsNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();

      // End cancels the timer and schedules the trailing sample.
      ScrollEndNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isFalse);

      // Metrics change while idle: schedules a one-off sample.
      ScrollMetricsNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();

      // Overscroll (without a Start) also wakes the sampler.
      OverscrollNotification(
        metrics: _metrics(),
        context: innerContext,
        overscroll: 12,
      ).dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isTrue);

      // Disposing the scope cancels the running timer.
      await tester.pumpWidget(Container());
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing sampleInterval restarts an active sampler',
        (tester) async {
      late BuildContext innerContext;
      Widget scopeWith(Duration interval) => MaterialApp(
            home: GlassContentAwareScope(
              sampleInterval: interval,
              child: Builder(builder: (context) {
                innerContext = context;
                return Container();
              }),
            ),
          );

      await tester.pumpWidget(scopeWith(const Duration(milliseconds: 180)));
      final scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));

      // Idle interval change: nothing to restart.
      await tester.pumpWidget(scopeWith(const Duration(milliseconds: 120)));
      expect(scope.isScrollSamplingActive, isFalse);

      ScrollStartNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isTrue);

      // Active interval change: timer is recreated with the new period.
      await tester.pumpWidget(scopeWith(const Duration(milliseconds: 60)));
      expect(scope.isScrollSamplingActive, isTrue);
      // Unrelated rebuild with the same interval: timer untouched.
      await tester.pumpWidget(scopeWith(const Duration(milliseconds: 60)));
      expect(scope.isScrollSamplingActive, isTrue);
      await tester.pump(const Duration(milliseconds: 200));

      ScrollEndNotification(metrics: _metrics(), context: innerContext)
          .dispatch(innerContext);
      await tester.pump();
      expect(scope.isScrollSamplingActive, isFalse);
    });
  });

  group('GlassContentAwareContent', () {
    testWidgets('a second content region under one scope asserts',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: Column(children: [
            Expanded(child: GlassContentAwareContent(child: Container())),
            Expanded(child: GlassContentAwareContent(child: Container())),
          ]),
        ),
      ));
      expect(tester.takeException(), isAssertionError);
      // Removing the second region exercises the non-matching detach.
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: Column(children: [
            Expanded(child: GlassContentAwareContent(child: Container())),
          ]),
        ),
      ));
      await tester.pumpWidget(Container());
      expect(tester.takeException(), isNull);
    });
  });

  group('GlassContentAwareBrightness — flip timing precedence', () {
    testWidgets('scope flipDuration/flipCurve apply to registered controls',
        (tester) async {
      final override = ValueNotifier<Brightness>(Brightness.light);
      addTearDown(override.dispose);
      double? darkAmount;
      // No scope here — the widget-level override must win over defaults.
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareBrightness(
          brightnessOverride: override,
          flipDuration: const Duration(milliseconds: 400),
          flipCurve: Curves.linear,
          builder: (context, brightness, t) {
            darkAmount = t;
            return const SizedBox.expand();
          },
        ),
      ));
      override.value = Brightness.dark;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Linear curve, 400 ms duration → exactly halfway after 200 ms.
      expect(darkAmount, closeTo(0.5, 0.01));
      await tester.pump(const Duration(milliseconds: 200));
      expect(darkAmount, 1.0);
    });

    testWidgets('scope timing is used when the widget does not override it',
        (tester) async {
      double? darkAmount;
      late GlassContentAwareScopeState scope;
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          flipDuration: const Duration(milliseconds: 600),
          flipCurve: Curves.linear,
          child: Stack(children: [
            Positioned.fill(
              child: GlassContentAwareContent(
                child: const ColoredBox(color: Color(0xFF000000)),
              ),
            ),
            Positioned.fill(
              child: GlassContentAwareBrightness(
                builder: (context, brightness, t) {
                  darkAmount = t;
                  return const SizedBox.expand();
                },
              ),
            ),
          ]),
        ),
      ));
      scope = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scope);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(darkAmount, closeTo(0.5, 0.01));
      await tester.pump(const Duration(milliseconds: 300));
      expect(darkAmount, 1.0);
    });
  });

  group('GlassContentAwareBrightness — configuration changes', () {
    testWidgets('override can be attached, swapped, and removed',
        (tester) async {
      final a = ValueNotifier<Brightness>(Brightness.light);
      final b = ValueNotifier<Brightness>(Brightness.dark);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      Brightness? built;
      Widget host(ValueListenable<Brightness>? override) => MaterialApp(
            home: GlassContentAwareScope(
              child: GlassContentAwareBrightness(
                brightnessOverride: override,
                builder: (context, brightness, t) {
                  built = brightness;
                  return const SizedBox.expand();
                },
              ),
            ),
          );

      // No override: registered with the scope (no content → ambient).
      await tester.pumpWidget(host(null));
      expect(built, Brightness.light);

      // Attach: adopts the override value (and deregisters from the scope).
      await tester.pumpWidget(host(b));
      await tester.pumpAndSettle();
      expect(built, Brightness.dark);

      // Swap to another listenable.
      await tester.pumpWidget(host(a));
      await tester.pumpAndSettle();
      expect(built, Brightness.light);
      // The detached listenable no longer drives the control.
      b.value = Brightness.light;
      a.value = Brightness.dark;
      await tester.pumpAndSettle();
      expect(built, Brightness.dark);

      // Remove: re-registers with the scope, keeping the last verdict.
      await tester.pumpWidget(host(null));
      await tester.pumpAndSettle();
      expect(built, Brightness.dark);
    });

    testWidgets('changing the grid re-registers the control', (tester) async {
      Widget host(int columns) => MaterialApp(
            home: GlassContentAwareScope(
              child: GlassContentAwareBrightness(
                gridColumns: columns,
                gridRows: columns == 6 ? 1 : 2,
                builder: (context, brightness, t) => const SizedBox.expand(),
              ),
            ),
          );
      await tester.pumpWidget(host(6));
      await tester.pumpWidget(host(2));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds without a MediaQuery ancestor', (tester) async {
      Brightness? built;
      double? darkAmount;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: GlassContentAwareBrightness(
          builder: (context, brightness, t) {
            built = brightness;
            darkAmount = t;
            return const SizedBox.expand();
          },
        ),
      ));
      // No MediaQuery → ambient defaults to light, no override is injected.
      expect(built, Brightness.light);
      expect(darkAmount, 0.0);
      expect(tester.takeException(), isNull);
    });
  });
}
