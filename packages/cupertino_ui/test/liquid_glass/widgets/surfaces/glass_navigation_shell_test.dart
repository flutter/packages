import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/effects/shared/glass_materialize_effect.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/glass_nav_pinned_host.dart';

void main() {
  setUp(() {
    // Headless test runs report no shader support; force the gate open so the
    // pinned path is exercised. Individual tests override to test the gate.
    GlassNavigationShellState.debugPinningSupported = true;
  });

  tearDown(() {
    GlassNavigationShellState.debugPinningSupported = null;
  });

  Widget shellApp(
    Widget home, {
    bool enabled = true,
    GlassSwipeCommitTransition swipeCommitTransition =
        GlassSwipeCommitTransition.effect,
  }) {
    return CupertinoApp(
      builder: (context, child) => GlassNavigationShell(
        enabled: enabled,
        swipeCommitTransition: swipeCommitTransition,
        child: child!,
      ),
      home: home,
    );
  }

  /// Settles the route transition and the post-frame registration handover.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump();
  }

  /// How materialized the pinned actions capsule is this frame, 0 to 1.
  ///
  /// Reads the effect wrapper the host puts around the capsule; a capsule
  /// that is not mounted at all reads as 0.
  double capsulePhase(WidgetTester tester) {
    final effects = find.descendant(
      of: find.byType(GlassNavPinnedHost),
      matching: find.byType(GlassMaterializeEffect),
    );
    for (final element in effects.evaluate()) {
      final effect = element.widget as GlassMaterializeEffect;
      if (effect.alignment == Alignment.centerRight) return effect.progress;
    }
    return 0.0;
  }

  /// The effect wrapper around the pinned actions capsule, if mounted.
  GlassMaterializeEffect? capsuleEffect(WidgetTester tester) {
    final effects = find.descendant(
      of: find.byType(GlassNavPinnedHost),
      matching: find.byType(GlassMaterializeEffect),
    );
    for (final element in effects.evaluate()) {
      final effect = element.widget as GlassMaterializeEffect;
      if (effect.alignment == Alignment.centerRight) return effect;
    }
    return null;
  }

  /// Commits a back-swipe onto a route with a capsule and returns the
  /// capsule's effect on every frame it is fading in.
  Future<List<GlassMaterializeEffect>> commitSwipe(
    WidgetTester tester, {
    required GlassSwipeCommitTransition transition,
  }) async {
    await tester.pumpWidget(shellApp(
      _Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      ),
      swipeCommitTransition: transition,
    ));
    await settle(tester);
    await _push(tester, const _Screen(title: 'Empty', actions: []));
    await settle(tester);

    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final gesture = await tester.startGesture(const Offset(2, 300));
    await gesture.moveTo(Offset(width * 0.48, 300));
    await tester.pump();
    await gesture.moveTo(Offset(width * 0.9, 300));
    await gesture.up();

    final frames = <GlassMaterializeEffect>[];
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final effect = capsuleEffect(tester);
      if (effect != null && effect.progress > 0.0 && effect.progress < 1.0) {
        frames.add(effect);
      }
    }
    await settle(tester);
    return frames;
  }

  /// How materialized the pinned back button is this frame, 0 to 1; -1 when
  /// it is not mounted at all.
  double backPhase(WidgetTester tester) {
    final effects = find.descendant(
      of: find.byType(GlassNavPinnedHost),
      matching: find.byType(GlassMaterializeEffect),
    );
    for (final element in effects.evaluate()) {
      final effect = element.widget as GlassMaterializeEffect;
      if (effect.alignment == Alignment.centerLeft) return effect.progress;
    }
    return -1.0;
  }

  /// The back button drawn by the shell, as opposed to any in-route fallback.
  Finder pinnedBack() => find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.back),
      );

  group('registration and hoisting', () {
    testWidgets('a screen with pinnedActions hands its items to the host',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            onTap: () {},
          ),
        ],
      )));
      await settle(tester);

      // The host renders the capsule above the navigator...
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsOneWidget,
      );
      // ...and the in-route bar holds only an unpainted measuring placeholder.
      expect(
        find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byType(GlassButtonGroup),
        ),
        findsNothing,
      );
    });

    testWidgets('no back button on a root route', (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);

      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });

    testWidgets('pushed route gets a pinned back button that pops',
        (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);

      await _push(tester, const _Screen(title: 'Detail', actions: []));
      await settle(tester);

      expect(find.text('Detail'), findsOneWidget);
      final back = find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.back),
      );
      expect(back, findsOneWidget);

      await tester.tap(back);
      await settle(tester);
      expect(find.text('Detail'), findsNothing);
      // Back at the root, the button is gone again.
      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });

    testWidgets('onBack overrides the default pop', (tester) async {
      var custom = 0;
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await _push(
        tester,
        _Screen(title: 'Detail', actions: const [], onBack: () => custom++),
      );
      await settle(tester);

      await tester.tap(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.back),
      ));
      await settle(tester);

      expect(custom, 1);
      expect(find.text('Detail'), findsOneWidget); // custom handler didn't pop
    });

    testWidgets('pinned items are tappable at rest', (tester) async {
      var taps = 0;
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            label: 'Add',
            onTap: () => taps++,
          ),
        ],
      )));
      await settle(tester);

      await tester.tap(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.add),
      ));
      expect(taps, 1);
    });

    testWidgets('custom items are measured at their intrinsic width',
        (tester) async {
      const wide = SizedBox(width: 120, height: 20);
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
          const GlassBarItem.custom(child: wide),
        ],
      )));
      await settle(tester);

      final capsule = tester.getSize(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byType(GlassButton),
      ));
      // One 46pt icon slot + the 120pt custom child.
      expect(capsule.width, greaterThanOrEqualTo(166));
    });

    testWidgets('in-place pinnedActions update reaches the host',
        (tester) async {
      await tester.pumpWidget(shellApp(const _TogglingScreen()));
      await settle(tester);
      expect(find.byIcon(CupertinoIcons.bell), findsNothing);

      await tester.tap(find.text('toggle'));
      await settle(tester);

      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.bell),
        ),
        findsOneWidget,
      );
    });
  });

  group('transitions', () {
    testWidgets('chrome renders mid-transition while items morph',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            id: 'add',
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.ellipsis),
            onTap: () {},
          ),
        ],
      )));
      await settle(tester);

      await _push(
        tester,
        _Screen(
          title: 'Detail',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              id: 'add',
              onTap: () {},
            ),
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.search),
              onTap: () {},
            ),
          ],
        ),
      );

      // Past the swap point: incoming side shows, matched item cross-fades.
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.search),
        ),
        findsOneWidget,
      );

      await settle(tester);
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.ellipsis),
        ),
        findsNothing,
      );
    });

    testWidgets(
        'exiting item smoothly fades out during morph without abrupt pop',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            id: 'add',
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.ellipsis),
            id: 'more',
            onTap: () {},
          ),
        ],
      )));
      await settle(tester);

      await _push(
        tester,
        _Screen(
          title: 'Detail',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.ellipsis),
              id: 'more',
              onTap: () {},
            ),
          ],
        ),
      );

      // Mid-transition: exiting item ('add') is still mounted with fading opacity
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsOneWidget,
      );

      await settle(tester);
      // Once settled, only the destination screen's items remain
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.ellipsis),
        ),
        findsOneWidget,
      );
    });

    testWidgets('capsule switches off when the destination has no actions',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);

      await _push(tester, const _Screen(title: 'Empty', actions: []));
      await settle(tester);

      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsNothing,
      );
      // The back button still pins: empty list opts in, it does not opt out.
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.back),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a capsule with nowhere to go dematerializes, it does not pop',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);

      await _push(tester, const _Screen(title: 'Empty', actions: []));
      // Part-way into the push the outgoing capsule must still be mounted and
      // mid-dissolve: a phase of exactly 0 or 1 here is the old hard switch.
      await tester.pump(const Duration(milliseconds: 120));
      final phase = capsulePhase(tester);
      expect(phase, greaterThan(0.0));
      expect(phase, lessThan(1.0));

      await settle(tester);
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsNothing,
      );
    });

    testWidgets('a settled capsule sits at a paint-neutral phase',
        (tester) async {
      // The effect wraps the capsule unconditionally so its glass shell is
      // never remounted as a transition starts; at rest it must be inert.
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);
      expect(capsulePhase(tester), 1.0);
    });

    testWidgets('the chrome holds still under an uncommitted back-swipe',
        (tester) async {
      // Dragging is not deciding. Until the pop commits there is no answer to
      // which route's chrome wins, so scrubbing the dissolve under the finger
      // reads as the bar guessing — and a swipe the user abandons should
      // never have half-dissolved anything.
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Empty', actions: []));
      await settle(tester);

      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final resting = capsulePhase(tester);

      final gesture = await tester.startGesture(const Offset(2, 300));
      await gesture.moveTo(Offset(width * 0.48, 300));
      await tester.pump();
      expect(
        capsulePhase(tester),
        resting,
        reason: 'the capsule must not move while the finger is still down',
      );

      // Committing releases it: the hold lifts and the chrome transitions.
      await gesture.moveTo(Offset(width * 0.9, 300));
      await gesture.up();

      // It must play, and play long enough to see. Two regressions live here:
      //
      // The hold was keyed on `userGestureInProgress`, which Cupertino leaves
      // true until the commit animation has finished, so the chrome stayed
      // frozen for the whole pop and snapped at the end.
      //
      // Then, re-timed over the route's remaining travel, it technically
      // animated but Cupertino sizes a committed swipe by how far the drag
      // got — a late release left about five frames, which reads as no
      // transition at all. Counting frames is what tells those apart; a bare
      // "did it move" assertion passes on both.
      var moving = 0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final phase = capsulePhase(tester);
        if (phase > resting && phase < 1.0) moving++;
      }
      expect(moving, greaterThanOrEqualTo(6),
          reason: 'the capsule must animate across the commit for long enough '
              'to be seen, not snap or flash past in a couple of frames');

      await settle(tester);
      expect(capsulePhase(tester), 1.0,
          reason: 'the root capsule is back once the pop commits');
    });

    testWidgets(
        'a committed back-swipe cross-fades plainly with '
        'GlassSwipeCommitTransition.crossFade', (tester) async {
      final frames = await commitSwipe(
        tester,
        transition: GlassSwipeCommitTransition.crossFade,
      );

      expect(frames, isNotEmpty,
          reason: 'the capsule must still fade in rather than snap');
      expect(frames.every((effect) => effect.plain), isTrue,
          reason: 'every frame of the commit is a plain cross-fade');
      expect(capsulePhase(tester), 1.0);
      expect(capsuleEffect(tester)!.plain, isFalse,
          reason: 'the next transition materializes again');
    });

    testWidgets('a committed back-swipe keeps the effect transition by default',
        (tester) async {
      final frames = await commitSwipe(
        tester,
        transition: GlassSwipeCommitTransition.effect,
      );

      expect(frames, isNotEmpty);
      expect(frames.any((effect) => effect.plain), isFalse,
          reason: 'without the opt-in a swipe plays the materialize as before');
    });

    testWidgets(
        'popping to a route with no pinned bar dissolves items without glyph blur (follow-up to #351)',
        (tester) async {
      Finder pinnedAdd() => find.descendant(
            of: find.byType(GlassNavPinnedHost),
            matching: find.byIcon(CupertinoIcons.add),
          );

      await tester.pumpWidget(shellApp(const _Screen(
        title: 'Root',
        actions: null,
      )));
      await settle(tester);

      await _push(
        tester,
        _Screen(
          title: 'Detail',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              onTap: () {},
            ),
          ],
        ),
      );
      await settle(tester);

      expect(capsulePhase(tester), 1.0);
      expect(pinnedAdd(), findsOneWidget);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump();

      // Over the pop transition, while the capsule is dematerializing, the
      // outgoing items should fade with the capsule glass (clusterPhaseAt)
      // and must never apply glyph blur (outSigma == 0).
      var testedFrames = 0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final phase = capsulePhase(tester);
        if (phase > 0.0 && phase < 1.0) {
          testedFrames++;
          final clusterChildFinder = find.descendant(
            of: find.byType(GlassNavPinnedHost),
            matching: find.byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_ClusterChild',
            ),
          );
          expect(
            clusterChildFinder,
            findsWidgets,
            reason: 'items remain mounted while capsule is dissolving',
          );
          for (final element in clusterChildFinder.evaluate()) {
            final child = element.widget;
            final blurSigma = (child as dynamic).blurSigma as double;
            final opacity = (child as dynamic).opacity as double;
            expect(
              blurSigma,
              0.0,
              reason:
                  'glyph blur must remain 0 when dissolving with no destination',
            );
            expect(
              opacity,
              closeTo(phase, 1e-4),
              reason: 'item opacity must track capsule glass phase',
            );
          }
        }
      }

      expect(testedFrames, greaterThan(0),
          reason: 'transition must have dematerializing frames');

      await settle(tester);
      expect(pinnedAdd(), findsNothing);
      expect(capsulePhase(tester), 0.0);
    });

    testWidgets('a cancelled back-swipe leaves the chrome exactly as it was',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Empty', actions: []));
      await settle(tester);

      // Scrub deep past the point the dissolve window used to open, then drag
      // back to the edge so the gesture is cancelled rather than committed.
      // Because the chrome never started moving there is nothing to rewind:
      // it reads the same at every point of an abandoned swipe.
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final resting = capsulePhase(tester);
      final gesture = await tester.startGesture(const Offset(2, 300));
      await gesture.moveTo(Offset(width * 0.48, 300));
      await tester.pump();
      expect(capsulePhase(tester), resting);

      await gesture.moveTo(const Offset(4, 300));
      await tester.pump();
      expect(capsulePhase(tester), resting);
      await gesture.up();
      await settle(tester);
      expect(capsulePhase(tester), resting,
          reason: 'an abandoned swipe leaves the chrome untouched');
      // Back where it started: the destination still has no capsule.
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsNothing,
      );
    });

    testWidgets('reduce motion switches instead of dissolving', (tester) async {
      await tester.pumpWidget(CupertinoApp(
        builder: (context, child) => GlassAccessibilityScope(
          reduceMotion: true,
          child: GlassNavigationShell(child: child!),
        ),
        home: _Screen(
          title: 'Root',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              onTap: () {},
            ),
          ],
        ),
      ));
      await settle(tester);

      await _push(tester, const _Screen(title: 'Empty', actions: []));
      await tester.pump(const Duration(milliseconds: 120));
      // Identity: fully present or fully gone, never in between.
      expect(capsulePhase(tester), anyOf(0.0, 1.0));
    });

    testWidgets('GlassEffectTransition.identity restores the hard switch',
        (tester) async {
      await tester.pumpWidget(CupertinoApp(
        builder: (context, child) => GlassNavigationShell(
          effectTransition: GlassEffectTransition.identity,
          child: child!,
        ),
        home: _Screen(
          title: 'Root',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              onTap: () {},
            ),
          ],
        ),
      ));
      await settle(tester);

      await _push(tester, const _Screen(title: 'Empty', actions: []));
      await tester.pump(const Duration(milliseconds: 120));
      expect(capsulePhase(tester), anyOf(0.0, 1.0));
    });

    testWidgets('entering chrome never flashes solid before it materializes',
        (tester) async {
      // Regression: a route's `animation` is a ProxyAnimation reporting itself
      // complete at 1.0 until the navigator attaches the real controller,
      // which happens after the first build — the build that registers the
      // bar. The shell read that as "fully entered" and painted the incoming
      // back button solid for one frame before it dropped back and animated.
      await tester.pumpWidget(shellApp(const _Screen(
        title: 'Root',
        actions: [],
      )));
      await settle(tester);

      await _push(tester, const _Screen(title: 'Detail', actions: []));

      var sawRamp = false;
      for (var i = 0; i < 30; i++) {
        await tester
            .pump(i == 0 ? Duration.zero : const Duration(milliseconds: 16));
        final phase = backPhase(tester);
        if (phase > 0.0 && phase < 1.0) sawRamp = true;
        // Before the ramp has started the button must be absent, never solid.
        if (!sawRamp) {
          expect(
            phase,
            lessThan(1.0),
            reason: 'frame $i painted the back button solid before the '
                'transition had begun',
          );
        }
      }
      expect(sawRamp, isTrue, reason: 'the back button should materialize');
    });

    testWidgets('chrome retreats under a non-participating route',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);

      await _push(
        tester,
        const CupertinoPageScaffold(child: Center(child: Text('Plain'))),
      );
      await settle(tester);

      // The plain route does not register; the host renders no chrome while
      // fully covered (the widget itself stays mounted at zero size).
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsNothing,
      );

      Navigator.of(tester.element(find.text('Plain'))).pop();
      await settle(tester);
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.add),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the back button is inert for the length of a push',
        (tester) async {
      var custom = 0;
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await _push(
        tester,
        _Screen(title: 'Detail', actions: const [], onBack: () => custom++),
      );

      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(pinnedBack(), warnIfMissed: false);
      await tester.pump();
      expect(custom, 0);

      await settle(tester);
      await tester.tap(pinnedBack());
      expect(custom, 1);
    });

    testWidgets('the back button is inert from the first frame of a pop',
        (tester) async {
      var custom = 0;
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await _push(
        tester,
        _Screen(title: 'Detail', actions: const [], onBack: () => custom++),
      );
      await settle(tester);

      // A pop leaves progress at 1.0 for its first frames, so by value alone
      // this is indistinguishable from being at rest — only the controller's
      // status says the transition is running.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pump();
      await tester.tap(pinnedBack(), warnIfMissed: false);
      await tester.pump();
      expect(custom, 0);

      await settle(tester);
    });

    testWidgets(
        'the back button is inert mid back-swipe and live again once '
        'a cancelled swipe rebounds', (tester) async {
      var custom = 0;
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await _push(
        tester,
        _Screen(title: 'Detail', actions: const [], onBack: () => custom++),
      );
      await settle(tester);

      final swipe = await tester.startGesture(const Offset(2, 300));
      await swipe.moveBy(const Offset(80, 0));
      await tester.pump();

      await tester.tap(pinnedBack(), warnIfMissed: false);
      await tester.pump();
      expect(custom, 0);

      // Cancelling springs the route back. The rebound's final value tick
      // lands on 1.0 before the controller reports itself completed, so the
      // chrome only learns it is at rest again from the status change.
      await swipe.moveBy(const Offset(-70, 0));
      await swipe.up();
      await settle(tester);

      await tester.tap(pinnedBack());
      expect(custom, 1);
      expect(find.text('Detail'), findsOneWidget);
    });

    testWidgets('pinned actions are inert mid-transition', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await _push(
        tester,
        _Screen(
          title: 'Detail',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              onTap: () => taps++,
            ),
          ],
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      final add = find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.add),
      );
      expect(add, findsOneWidget);
      await tester.tap(add, warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);

      await settle(tester);
      await tester.tap(add);
      expect(taps, 1);
    });
  });

  group("the chrome's own clock", () {
    GlassNavPinnedState state(WidgetTester tester) => tester
        .widget<GlassNavPinnedHost>(find.byType(GlassNavPinnedHost))
        .state;

    double progress(WidgetTester tester) => state(tester).progress;

    bool settled(WidgetTester tester) => state(tester).settled;

    /// Two frames: the clock starts the frame after the route's status turns.
    Future<void> start(WidgetTester tester) async {
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
    }

    testWidgets('a sprung push morphs over its duration, not its spring',
        (tester) async {
      await tester
          .pumpWidget(shellApp(const _Screen(title: 'Root', actions: [])));
      await settle(tester);
      tester.state<NavigatorState>(find.byType(Navigator)).push(
          _SpringRoute<void>(const _Screen(title: 'Detail', actions: [])));
      await tester.pump();
      await start(tester);

      // The spring is past halfway by 100ms and all but settled by 300ms;
      // the 500ms duration the route declares is a fifth and three fifths in.
      await tester.pump(const Duration(milliseconds: 100));
      expect(progress(tester), inExclusiveRange(0.1, 0.35));
      await tester.pump(const Duration(milliseconds: 200));
      expect(progress(tester), inExclusiveRange(0.5, 0.75));
      expect(settled(tester), isFalse);

      await settle(tester);
      expect(progress(tester), 1.0);
      expect(settled(tester), isTrue);
    });

    testWidgets('a curved push reads exactly as the route does',
        (tester) async {
      await tester
          .pumpWidget(shellApp(const _Screen(title: 'Root', actions: [])));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail', actions: []));
      await start(tester);
      await tester.pump(const Duration(milliseconds: 200));

      final route = ModalRoute.of(tester.element(find.text('Detail')))!;
      expect(progress(tester), closeTo(route.animation!.value, 0.04));
    });

    testWidgets('a pop that interrupts a push carries on from mid-morph',
        (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
          _SpringRoute<void>(const _Screen(title: 'Detail', actions: [])));
      await tester.pump();
      await start(tester);
      await tester.pump(const Duration(milliseconds: 200));
      final before = progress(tester);
      expect(before, inExclusiveRange(0.2, 0.6));

      // The spring is nearly home by now; the chrome is not, and must not
      // jump to the far end before coming back.
      navigator.pop();
      await tester.pump();
      await start(tester);
      expect(progress(tester), lessThanOrEqualTo(before));
      expect(progress(tester), greaterThan(before - 0.15));
    });

    testWidgets('the chrome is not settled until its run has ended',
        (tester) async {
      await tester
          .pumpWidget(shellApp(const _Screen(title: 'Root', actions: [])));
      await settle(tester);
      tester.state<NavigatorState>(find.byType(Navigator)).push(
            _SpringRoute<void>(
              const _Screen(title: 'Detail', actions: []),
              duration: const Duration(milliseconds: 1500),
            ),
          );
      await tester.pump();
      await start(tester);

      // The spring has come to rest; the declared second and a half has not.
      await tester.pump(const Duration(milliseconds: 800));
      final route = ModalRoute.of(tester.element(find.text('Detail')))!;
      expect(route.animation!.status, AnimationStatus.completed);
      expect(progress(tester), inExclusiveRange(0.5, 0.8));
      expect(settled(tester), isFalse);

      await settle(tester);
      expect(settled(tester), isTrue);
    });

    testWidgets(
        'an interactive back-swipe on a sprung route does not run the clock',
        (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        _SpringRoute<void>(const _Screen(title: 'Detail', actions: [])),
      );
      await settle(tester);

      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final gesture = await tester.startGesture(const Offset(2, 300));
      await gesture.moveTo(Offset(width * 0.5, 300));
      await tester.pump();

      // Holds still under gesture, not running on the clock.
      expect(progress(tester), 1.0);
      expect(settled(tester), isFalse);

      await gesture.up();
      await settle(tester);
      expect(progress(tester), 1.0);
      expect(settled(tester), isTrue);
    });
  });

  group('presented routes', () {
    /// The back button drawn by the route's own bar, as opposed to the shell's.
    Finder inRouteBack() => find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byIcon(CupertinoIcons.back),
        );

    /// Pushes a screen that shows a pinned back button.
    Future<void> pushDetail(WidgetTester tester) async {
      await _push(tester, const _Screen(title: 'Detail', actions: []));
      await settle(tester);
    }

    /// Exactly one copy of the back button is on screen, never two or none.
    void expectOneCopy(String when) {
      final copies =
          pinnedBack().evaluate().length + inRouteBack().evaluate().length;
      expect(copies, 1, reason: 'copies of the back button $when');
    }

    testWidgets('a modal popup takes the chrome back into the route',
        (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await pushDetail(tester);
      expect(pinnedBack(), findsOneWidget);

      showCupertinoModalPopup<void>(
        context: tester.element(find.text('Detail body')),
        builder: (_) => const SizedBox(height: 400),
      );
      await settle(tester);

      // The shell draws above the navigator, so it cannot draw beneath a route
      // pushed into it. The route renders its own buttons instead.
      expect(pinnedBack(), findsNothing);
      expect(inRouteBack(), findsOneWidget);
    });

    testWidgets('so does a dialog', (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await pushDetail(tester);

      showCupertinoDialog<void>(
        context: tester.element(find.text('Detail body')),
        builder: (_) => const CupertinoAlertDialog(title: Text('Alert')),
      );
      await settle(tester);

      expect(pinnedBack(), findsNothing);
      expect(inRouteBack(), findsOneWidget);
    });

    testWidgets('and a fullscreen dialog, which drives no exit transition',
        (tester) async {
      // `CupertinoRouteTransitionMixin.canTransitionTo` refuses one, so the
      // covered route's `secondaryAnimation` never runs and the retreat that
      // handles an ordinary push never starts.
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await pushDetail(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(CupertinoPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const CupertinoPageScaffold(
          child: Center(child: Text('Compose')),
        ),
      ));
      await settle(tester);

      expect(find.text('Compose'), findsOneWidget);
      expect(pinnedBack(), findsNothing);
    });

    testWidgets('the chrome is pinned again once the presentation is gone',
        (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await pushDetail(tester);

      final context = tester.element(find.text('Detail body'));
      showCupertinoDialog<void>(
        context: context,
        builder: (_) => const CupertinoAlertDialog(title: Text('Alert')),
      );
      await settle(tester);
      Navigator.of(context, rootNavigator: true).pop();
      await settle(tester);

      expect(pinnedBack(), findsOneWidget);
      expect(inRouteBack(), findsNothing);

      // ...and it is live again, not just drawn.
      await tester.tap(pinnedBack());
      await settle(tester);
      expect(find.text('Detail body'), findsNothing);
    });

    testWidgets('a committed swipe onto a non-pinned root keeps one copy',
        (tester) async {
      // Where the hand-back meets the commit-exit path. A committed swipe
      // plays from a frozen snapshot while the outgoing route is popped but
      // not yet unregistered, and the destination here contributes no chrome
      // of its own — so this is the thinnest the registry ever gets with the
      // shell still drawing.
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root')), // null actions: not pinned
      );
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail', actions: []));
      await settle(tester);
      expectOneCopy('at rest before the swipe');

      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final gesture = await tester.startGesture(const Offset(2, 300));
      await gesture.moveTo(Offset(width * 0.9, 300));
      await gesture.up();

      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final copies =
            pinnedBack().evaluate().length + inRouteBack().evaluate().length;
        expect(copies, lessThanOrEqualTo(1),
            reason: 'copies of the back button at commit frame $frame');
      }

      await settle(tester);
      // Root shows no back button at all, from either side.
      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });

    testWidgets('exactly one copy is on screen for every frame of the swap',
        (tester) async {
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await pushDetail(tester);
      expectOneCopy('at rest');

      final context = tester.element(find.text('Detail body'));
      showCupertinoDialog<void>(
        context: context,
        builder: (_) => const CupertinoAlertDialog(title: Text('Alert')),
      );
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expectOneCopy('at presentation frame $frame');
      }

      Navigator.of(context, rootNavigator: true).pop();
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expectOneCopy('at dismissal frame $frame');
      }
    });

    testWidgets('and for every frame of a push and pop between two routes',
        (tester) async {
      // The outgoing route has to keep its placeholder for the whole
      // transition: the shell is drawing a blend of both routes' items, and a
      // bar that took its own chrome back would slide a second copy out from
      // underneath the pinned one.
      await tester.pumpWidget(
        shellApp(const _Screen(title: 'Root', actions: [])),
      );
      await settle(tester);
      await pushDetail(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(CupertinoPageRoute<void>(
        builder: (_) => const _Screen(title: 'Third', actions: []),
      ));
      // The first frame is Flutter's offstage build of the incoming route,
      // where neither copy is on stage yet.
      await tester.pump(const Duration(milliseconds: 16));
      for (var frame = 1; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expectOneCopy('at push frame $frame');
      }

      navigator.pop();
      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expectOneCopy('at pop frame $frame');
      }
    });
  });

  group('pull-down menus', () {
    List<GlassBarItem> menuActions({String label = 'Copy'}) => [
          GlassBarItem.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            id: 'more',
            label: 'More',
            menuItems: [GlassMenuItem(title: label, onTap: () {})],
          ),
        ];

    testWidgets('a menu item opens the pull-down from the pinned capsule',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: menuActions(),
      )));
      await settle(tester);

      expect(find.text('Copy'), findsNothing);
      await tester.tap(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.ellipsis),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('a menu cannot be opened mid-transition', (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: menuActions(),
      )));
      await settle(tester);
      await _push(
        tester,
        _Screen(title: 'Detail', actions: menuActions(label: 'Delete')),
      );

      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.ellipsis),
        ),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(find.text('Copy'), findsNothing);
      expect(find.text('Delete'), findsNothing);

      await settle(tester);
    });

    testWidgets('an open menu is dismissed when navigation starts',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: menuActions(),
      )));
      await settle(tester);

      await tester.tap(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.ellipsis),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);

      // The capsule outlives the route, so nothing else would take the menu
      // down as the page slides out from under it.
      await _push(tester, const _Screen(title: 'Detail', actions: []));
      await settle(tester);

      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('only the first menu item in a cluster opens a menu',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            menuItems: [GlassMenuItem(title: 'First', onTap: () {})],
          ),
          GlassBarItem.menu(
            icon: const Icon(CupertinoIcons.square_arrow_up),
            menuItems: [GlassMenuItem(title: 'Second', onTap: () {})],
          ),
        ],
      )));
      await settle(tester);

      await tester.tap(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.square_arrow_up),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsNothing);

      await tester.tap(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.ellipsis),
      ));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('without a shell the menu still opens in-route',
        (tester) async {
      GlassNavigationShellState.debugPinningSupported = false;
      await tester.pumpWidget(CupertinoApp(
        home: _Screen(title: 'Root', actions: menuActions()),
      ));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('page-based navigators', () {
    testWidgets(
        'a pages update that drives a route animation does not mark '
        'the chrome dirty mid-build', (tester) async {
      // A declarative Navigator applies its pages inside didUpdateWidget —
      // the build phase. Wiring a secondary animation there
      // (ProxyAnimation.parent=) and starting a pop's reverse both notify
      // value listeners synchronously, so the shell's tick has to defer or
      // the chrome's ListenableBuilder is marked dirty mid-build.
      final key = GlobalKey<_PagesNavigatorState>();
      await tester.pumpWidget(_PagesApp(navigatorKey: key));
      await settle(tester);

      key.currentState!.push(const _Screen(title: 'Detail', actions: []));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await settle(tester);
      expect(find.text('Detail'), findsOneWidget);

      key.currentState!.pop();
      await tester.pump();
      expect(tester.takeException(), isNull);
      await settle(tester);
      expect(find.text('Detail'), findsNothing);
    });

    testWidgets('and neither does a route with no transition', (tester) async {
      // A zero-duration route completes its animation synchronously inside
      // the same didUpdateWidget, which is the case that notifies value
      // listeners rather than only status listeners.
      final key = GlobalKey<_PagesNavigatorState>();
      await tester.pumpWidget(_PagesApp(navigatorKey: key));
      await settle(tester);

      key.currentState!
          .push(const _Screen(title: 'Instant', actions: []), instant: true);
      await tester.pump();
      expect(tester.takeException(), isNull);
      await settle(tester);
      expect(find.text('Instant'), findsOneWidget);

      key.currentState!.pop();
      await tester.pump();
      expect(tester.takeException(), isNull);
      await settle(tester);
      expect(find.text('Instant'), findsNothing);
    });

    testWidgets(
        'a sprung route pushed mid-build does not mark the chrome dirty',
        (tester) async {
      final key = GlobalKey<_PagesNavigatorState>();
      await tester.pumpWidget(_PagesApp(navigatorKey: key));
      await settle(tester);

      key.currentState!.pushSpring(const _Screen(title: 'Detail', actions: []));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await settle(tester);
      expect(find.text('Detail'), findsOneWidget);

      key.currentState!.pop();
      await tester.pump();
      expect(tester.takeException(), isNull);
      await settle(tester);
      expect(find.text('Detail'), findsNothing);
    });
  });

  group('fallback rendering', () {
    Finder inRouteCapsule() => find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byType(GlassButtonGroup),
        );

    testWidgets('without a shell the bar renders the same items in-route',
        (tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: _Screen(
          title: 'Root',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              onTap: () {},
            ),
          ],
        ),
      ));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      expect(inRouteCapsule(), findsOneWidget);
    });

    testWidgets('in-route back button appears on pushed routes and pops',
        (tester) async {
      await tester.pumpWidget(const CupertinoApp(home: _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail', actions: []));
      await settle(tester);

      final back = find.descendant(
        of: find.byType(GlassAppBar),
        matching: find.byIcon(CupertinoIcons.back),
      );
      expect(back, findsOneWidget);
      await tester.tap(back);
      await settle(tester);
      expect(find.text('Detail'), findsNothing);
    });

    testWidgets('a disabled shell behaves like no shell', (tester) async {
      await tester.pumpWidget(shellApp(
        enabled: false,
        _Screen(
          title: 'Root',
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              onTap: () {},
            ),
          ],
        ),
      ));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      expect(inRouteCapsule(), findsOneWidget);
    });

    testWidgets('an unsupported device falls back in-route', (tester) async {
      GlassNavigationShellState.debugPinningSupported = false;
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
        ],
      )));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      expect(inRouteCapsule(), findsOneWidget);
    });
  });

  group('API guards', () {
    testWidgets('the two constructors cannot mix widget and data APIs',
        (tester) async {
      // Structurally impossible now: the plain constructor has no pinned
      // parameters and the pinned constructor has no widget parameters, so
      // the two APIs cannot be mixed on one bar.
      expect(
        const GlassAppBar.pinned().pinnedActions,
        isEmpty,
      );
      expect(const GlassAppBar(actions: [SizedBox()]).pinnedActions, isNull);
    });

    testWidgets('a spacer splits the actions into two capsules',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
          GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.search), onTap: () {}),
          const GlassBarItem.spacer(),
          GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.ellipsis), onTap: () {}),
        ],
      )));
      await settle(tester);

      final shells = find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byType(GlassButton),
      );
      expect(shells, findsNWidgets(2));
      expect(
          tester.getSize(shells.first).width, GlassNavPinnedMetrics.slot * 2);
      expect(tester.getSize(shells.last).width, GlassNavPinnedMetrics.slot);
    });

    testWidgets('pinning stays active at GlassQuality.minimal', (tester) async {
      // Regression: the gate borrowed the modal sheet morph's quality floor,
      // so a step down to `minimal` switched pinning off entirely. That is not
      // only a developer opt-in — GlassQualityAdapter steps down on its own
      // when frame times regress, so an adaptive decision about blur cost was
      // silently changing an unrelated layout behaviour.
      //
      // Pinning costs no shader; the pinned bar resolves its own quality, so
      // at `minimal` it should simply be a BackdropFilter-only bar that stays
      // put across routes.
      GlassNavigationShellState.debugPinningSupported = null;
      GlassNavigationShellState? found;
      await tester.pumpWidget(
        GlassTheme(
          data: GlassThemeData.simple(quality: GlassQuality.minimal),
          child: CupertinoApp(
            builder: (context, child) => GlassNavigationShell(child: child!),
            home: Builder(
              builder: (context) {
                found = GlassNavigationShell.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(found, isNotNull);
      expect(found!.isActive, isTrue);
    });

    testWidgets('an explicitly disabled shell is still inactive',
        (tester) async {
      // Guard for the other direction: dropping the quality gate must not
      // make `enabled: false` stop being honoured.
      GlassNavigationShellState.debugPinningSupported = null;
      GlassNavigationShellState? found;
      await tester.pumpWidget(CupertinoApp(
        builder: (context, child) =>
            GlassNavigationShell(enabled: false, child: child!),
        home: Builder(
          builder: (context) {
            found = GlassNavigationShell.maybeOf(context);
            return const SizedBox();
          },
        ),
      ));
      expect(found, isNotNull);
      expect(found!.isActive, isFalse);
    });

    testWidgets('maybeOf finds the shell from a route subtree', (tester) async {
      GlassNavigationShellState? found;
      await tester.pumpWidget(CupertinoApp(
        builder: (context, child) => GlassNavigationShell(child: child!),
        home: Builder(
          builder: (context) {
            found = GlassNavigationShell.maybeOf(context);
            return const SizedBox();
          },
        ),
      ));
      expect(found, isNotNull);
      expect(found!.isActive, isTrue);
    });
  });
}

/// A push that runs on a stiff spring rather than a duration, the way a zoom
/// transition does: most of its travel lands in the first hundred
/// milliseconds and the rest creeps in.
class _SpringRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _SpringRoute(
    this.screen, {
    this.duration = const Duration(milliseconds: 500),
    super.settings,
  });

  final Widget screen;
  final Duration duration;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  String? get title => null;

  @override
  Widget buildContent(BuildContext context) => screen;

  @override
  Simulation? createSimulation({required bool forward}) => SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 361, damping: 38),
        forward ? 0.0 : 1.0,
        forward ? 1.0 : 0.0,
        0.0,
      );
}

Future<void> _push(WidgetTester tester, Widget screen) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.push(CupertinoPageRoute<void>(builder: (_) => screen));
  await tester.pump();
}

/// A minimal screen with a pinned bar.
class _Screen extends StatelessWidget {
  const _Screen({required this.title, this.actions, this.onBack});

  final String title;
  final List<GlassBarItem>? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // Screens with actions use the pinned constructor; a null actions list
    // means this screen deliberately uses the widget-based bar and does not
    // participate in pinning.
    final items = actions;
    return GlassScaffold(
      appBar: items == null
          ? GlassAppBar(title: Text(title))
          : GlassAppBar.pinned(
              title: Text(title),
              actions: items,
              onBack: onBack,
            ),
      body: Center(child: Text('$title body')),
    );
  }
}

/// A screen whose actions change with setState.
class _TogglingScreen extends StatefulWidget {
  const _TogglingScreen();

  @override
  State<_TogglingScreen> createState() => _TogglingScreenState();
}

class _TogglingScreenState extends State<_TogglingScreen> {
  bool _extra = false;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar.pinned(
        title: const Text('Toggle'),
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
          if (_extra)
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.bell),
              onTap: () {},
            ),
        ],
      ),
      body: Center(
        child: CupertinoButton(
          onPressed: () => setState(() => _extra = !_extra),
          child: const Text('toggle'),
        ),
      ),
    );
  }
}

/// A root-level page-based Navigator under the shell whose pages change
/// with setState BELOW the shell — the way go_router's Router sits inside
/// an app's builder-installed shell. The rebuild that applies the pages then
/// starts beneath the chrome, not above it.
class _PagesApp extends StatelessWidget {
  const _PagesApp({required this.navigatorKey});

  final GlobalKey<_PagesNavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      builder: (context, _) => GlassNavigationShell(
        child: _PagesNavigator(key: navigatorKey),
      ),
    );
  }
}

class _PagesNavigator extends StatefulWidget {
  const _PagesNavigator({super.key});

  @override
  State<_PagesNavigator> createState() => _PagesNavigatorState();
}

class _PagesNavigatorState extends State<_PagesNavigator> {
  final _pages = <Page<void>>[
    const CupertinoPage<void>(
      key: ValueKey('root'),
      child: _Screen(title: 'Root', actions: []),
    ),
  ];

  void push(Widget screen, {bool instant = false}) => setState(() {
        final key = ValueKey(_pages.length);
        _pages.add(
          instant
              ? _InstantPage(key: key, child: screen)
              : CupertinoPage<void>(key: key, child: screen),
        );
      });

  void pushSpring(Widget screen,
          {Duration duration = const Duration(milliseconds: 500)}) =>
      setState(() {
        final key = ValueKey(_pages.length);
        _pages.add(
          _SpringPage(key: key, child: screen, duration: duration),
        );
      });

  void pop() => setState(() => _pages.removeLast());

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: List.of(_pages),
      onDidRemovePage: (page) => _pages.remove(page),
    );
  }
}

/// A page whose route has no transition, like a `NoTransitionPage`.
class _InstantPage extends Page<void> {
  const _InstantPage({required this.child, super.key});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder<void>(
        settings: this,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => child,
      );
}

/// A page whose route runs on a spring simulation.
class _SpringPage extends Page<void> {
  const _SpringPage({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Route<void> createRoute(BuildContext context) => _SpringRoute<void>(
        child,
        duration: duration,
        settings: this,
      );
}
