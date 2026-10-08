import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_materialize_scope.dart';
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
    List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
  }) {
    return CupertinoApp(
      localizationsDelegates: localizationsDelegates,
      builder: (context, child) =>
          GlassNavigationShell(enabled: enabled, child: child!),
      home: home,
    );
  }

  /// Settles the route transition and the post-frame registration handover.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump();
  }

  /// The [Semantics] node an item declares, rather than the merged semantics
  /// tree, so the assertion does not need a semantics handle.
  Finder semanticsLabelled(String label) => find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == label,
      );

  Finder inHost(Finder matching) => find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: matching,
      );

  /// Every [GlassMaterializeScope] above [finder], nearest first.
  Iterable<GlassMaterializeScope> scopesAbove(Finder finder) => find
      .ancestor(of: finder, matching: find.byType(GlassMaterializeScope))
      .evaluate()
      .map((e) => e.widget as GlassMaterializeScope);

  /// The [GlassMaterializeScope] closest above [finder].
  GlassMaterializeScope nearestScope(WidgetTester tester, Finder finder) =>
      scopesAbove(finder).first;

  group('the automatic back button', () {
    testWidgets('a back-only cluster is still the 44pt circle', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail'));
      await settle(tester);

      // The shell it renders now comes from the same cluster machinery as the
      // actions capsule, so this asserts the geometry has not shifted: 44pt
      // square, where the capsule's 22pt radius clamps to exactly a circle.
      expect(
        tester.getSize(inHost(find.byType(GlassButton))),
        const Size(
          GlassNavPinnedMetrics.backDiameter,
          GlassNavPinnedMetrics.backDiameter,
        ),
      );
    });

    testWidgets('its label comes from CupertinoLocalizations', (tester) async {
      await tester.pumpWidget(shellApp(
        const _Screen(title: 'Root'),
        localizationsDelegates: const [
          _StubCupertinoLocalizationsDelegate(),
          DefaultWidgetsLocalizations.delegate,
        ],
      ));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail'));
      await settle(tester);

      expect(inHost(semanticsLabelled('Atrás')), findsOneWidget);
    });

    testWidgets('defaults to the untranslated label with no delegates',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail'));
      await settle(tester);

      expect(inHost(semanticsLabelled('Back')), findsOneWidget);
    });
  });

  group('replace versus supplement', () {
    testWidgets('a leading item replaces the back button', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, _Screen(title: 'Detail', leading: [_cancel()]));
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.xmark)), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });

    testWidgets('leadingItemsSupplementBackButton shows both', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(
          tester,
          _Screen(
            title: 'Detail',
            leading: [_cancel()],
            supplement: true,
          ));
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.back)), findsOneWidget);
      expect(inHost(find.byIcon(CupertinoIcons.xmark)), findsOneWidget);
      // Two shells, because the back button shares its background with nothing.
      expect(inHost(find.byType(GlassButton)), findsNWidgets(2));
    });

    testWidgets('backButton: false wins over supplementing', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(
          tester,
          _Screen(
            title: 'Detail',
            leading: [_cancel()],
            supplement: true,
            backButton: false,
          ));
      await settle(tester);

      expect(find.byIcon(CupertinoIcons.back), findsNothing);
      expect(inHost(find.byIcon(CupertinoIcons.xmark)), findsOneWidget);
    });

    testWidgets('a leading on a root route pins without a back button',
        (tester) async {
      await tester.pumpWidget(
        shellApp(_Screen(title: 'Root', leading: [_cancel()])),
      );
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.xmark)), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });
  });

  group('backgrounds', () {
    testWidgets('an item that hides its background gets no glass shell',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        leading: [
          const GlassBarItem.custom(
            child: SizedBox(width: 44, height: 44, child: Text('avatar')),
            background: GlassBarItemBackground.none,
          ),
        ],
      )));
      await settle(tester);

      expect(inHost(find.text('avatar')), findsOneWidget);
      expect(inHost(find.byType(GlassButton)), findsNothing);
    });

    testWidgets(
        'an item that draws its own glass dissolves through the materialize '
        'scope, not a layer', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, _Screen(title: 'Detail', leading: [_ownCapsule()]));

      // Mid cross-fade, where an ordinary item is painted under an opacity
      // layer. A glass surface under one has no backdrop to sample, so the
      // cluster hands the fade to the surface itself instead.
      await tester.pump(const Duration(milliseconds: 250));
      final scope = nearestScope(tester, inHost(find.text('capsule')));
      expect(scope.glassProgress, lessThan(1.0));
      expect(scope.glassProgress, greaterThan(0.0));
      expect(scope.contentSigma, greaterThan(0.0));

      await settle(tester);
      expect(
        nearestScope(tester, inHost(find.text('capsule'))).glassProgress,
        1.0,
      );
    });

    testWidgets('two items that draw their own glass take turns',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        leading: [_ownCapsule(id: #cluster)],
      )));
      await settle(tester);
      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            leading: [_ownCapsule(id: #cluster, label: 'pill')],
          ));

      // A matched pair of plain items cross-fades; two glass surfaces cannot,
      // because each would sample the other. Before the swap only the
      // outgoing one is drawn, dissolving; after it only the incoming one.
      await tester.pump(const Duration(milliseconds: 200));
      final outgoing = nearestScope(tester, inHost(find.text('capsule')));
      expect(outgoing.glassProgress, lessThan(1.0));
      expect(outgoing.glassProgress, greaterThan(0.0));
      expect(
          nearestScope(tester, inHost(find.text('pill'))).glassProgress, 0.0);

      await tester.pump(const Duration(milliseconds: 100));
      expect(
        nearestScope(tester, inHost(find.text('capsule'))).glassProgress,
        0.0,
      );
      final incoming = nearestScope(tester, inHost(find.text('pill')));
      expect(incoming.glassProgress, lessThan(1.0));
      expect(incoming.glassProgress, greaterThan(0.0));
    });

    testWidgets(
        'plain content that hides its background keeps the cluster fade',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(
          tester,
          _Screen(
            title: 'Detail',
            leading: [
              const GlassBarItem.custom(
                child: SizedBox(width: 44, height: 44, child: Text('avatar')),
                background: GlassBarItemBackground.none,
              ),
              _ownCapsule(),
            ],
          ));
      await tester.pump(const Duration(milliseconds: 250));

      // Both sit under the group's own materialize; only the glass item gets
      // the cluster's fade as a scope of its own. The avatar is faded at
      // paint, as before.
      final avatarScopes = scopesAbove(inHost(find.text('avatar')));
      final capsuleScopes = scopesAbove(inHost(find.text('capsule')));
      expect(capsuleScopes.length, avatarScopes.length + 1);
    });

    testWidgets(
        'a cluster only one route has dissolves through the materialize',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, _Screen(title: 'Detail', leading: [_cancel()]));

      // Inside the materialize window. The menu wrapper around every group
      // used to install a resting scope of its own here, so the group's
      // shell never saw this fade and popped in solid at the window's start.
      await tester.pump(const Duration(milliseconds: 350));
      final scope =
          nearestScope(tester, inHost(find.byIcon(CupertinoIcons.xmark)));
      expect(scope.glassProgress, lessThan(1.0));
      expect(scope.glassProgress, greaterThan(0.0));
    });

    testWidgets('a separate item is its own shell beside a shared capsule',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        leading: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.xmark),
            background: GlassBarItemBackground.separate,
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.search),
            onTap: () {},
          ),
        ],
      )));
      await settle(tester);

      final shells = inHost(find.byType(GlassButton));
      expect(shells, findsNWidgets(2));
      // The lone separate item is the 44pt circle; the two shared ones are one
      // capsule at the taller icon-slot height.
      expect(
        tester.getSize(shells.first).height,
        GlassNavPinnedMetrics.backDiameter,
      );
      expect(
        tester.getSize(shells.last).height,
        GlassNavPinnedMetrics.slot,
      );
    });
    testWidgets('a lone shell grows into a shared capsule', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      await _push(tester, const _Screen(title: 'Detail'));
      await settle(tester);

      // The back button shares with nothing, so it is the circular shell.
      Size shell() => tester.getSize(inHost(find.byType(GlassButton)));
      expect(shell().height, GlassNavPinnedMetrics.backDiameter);

      await _push(
          tester,
          _Screen(
            title: 'Library',
            backButton: false,
            leading: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.sidebar_left),
                onTap: () {},
              ),
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.slider_horizontal_3),
                onTap: () {},
              ),
            ],
          ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Mid-morph both dimensions are in flight, which is the whole point:
      // one element, geometry animating, no remount. The gel swell can carry
      // them past both endpoints while the shell puffs, so the upper bound is
      // the swollen size, not the destination's.
      const swollen = 1.0 + GlassNavPinnedMetrics.swellAmount;
      final mid = shell();
      expect(mid.height, greaterThan(GlassNavPinnedMetrics.backDiameter));
      expect(mid.height, lessThan(GlassNavPinnedMetrics.slot * swollen));
      expect(mid.width, greaterThan(GlassNavPinnedMetrics.backDiameter));
      expect(mid.width, lessThan(GlassNavPinnedMetrics.slot * 2 * swollen));

      await settle(tester);
      expect(
        shell(),
        const Size(
          GlassNavPinnedMetrics.slot * 2,
          GlassNavPinnedMetrics.slot,
        ),
      );
    });
  });

  group('anchoring', () {
    testWidgets('a leading cluster grows away from the leading edge',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        leading: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            id: 'add',
            onTap: () {},
          ),
        ],
      )));
      await settle(tester);
      final before = tester.getTopLeft(inHost(find.byIcon(CupertinoIcons.add)));

      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            leading: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.add),
                id: 'add',
                onTap: () {},
              ),
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.search),
                id: 'search',
                onTap: () {},
              ),
            ],
          ));
      await settle(tester);

      // The matched item holds its place while the capsule grows trailing-ward.
      // Anchored at the trailing edge instead, it would have shifted by a slot.
      expect(
        tester.getTopLeft(inHost(find.byIcon(CupertinoIcons.add))).dx,
        moreOrLessEquals(before.dx, epsilon: 0.5),
      );
    });

    test('matchGlassNavActions counts positions from the anchored edge', () {
      final a =
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {});
      final b = GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.search), onTap: () {});
      final c = GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.bell), onTap: () {});

      // Leading-anchored: the first item of each cluster is the same slot.
      final leading = matchGlassNavActions(
        [a as GlassBarActionItem],
        [b as GlassBarActionItem, c as GlassBarActionItem],
        anchoredAtStart: true,
      );
      expect(leading.singleWhere((s) => s.toItem == b).fromItem, same(a));
      expect(leading.singleWhere((s) => s.toItem == c).isEnter, isTrue);

      // Trailing-anchored: the last item of each cluster is, which is the
      // existing default.
      final trailing = matchGlassNavActions([a], [b, c]);
      expect(trailing.singleWhere((s) => s.toItem == c).fromItem, same(a));
      expect(trailing.singleWhere((s) => s.toItem == b).isEnter, isTrue);
    });

    testWidgets('trailing action groups align to the trailing edge',
        (tester) async {
      final selectItem = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.checkmark),
        background: GlassBarItemBackground.separate,
        onTap: () {},
      );
      final menuItem = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.ellipsis),
        background: GlassBarItemBackground.separate,
        onTap: () {},
      );
      final navUp = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.chevron_up),
        background: GlassBarItemBackground.shared,
        onTap: () {},
      );
      final navDown = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.chevron_down),
        background: GlassBarItemBackground.shared,
        onTap: () {},
      );

      await tester.pumpWidget(shellApp(_Screen(
        title: 'Inbox',
        actions: [selectItem, menuItem],
      )));
      await settle(tester);

      await _push(
        tester,
        _Screen(
          title: 'Detail',
          actions: [navUp, navDown],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final buttons = inHost(find.byType(GlassButton));
      expect(buttons, findsWidgets);

      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.chevron_up)), findsOneWidget);
      expect(inHost(find.byIcon(CupertinoIcons.chevron_down)), findsOneWidget);
      expect(inHost(find.byIcon(CupertinoIcons.checkmark)), findsNothing);
    });
  });

  group('interaction', () {
    testWidgets('leading items are tappable at rest and inert mid-transition',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        leading: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.xmark),
            onTap: () => taps++,
          ),
        ],
      )));
      await settle(tester);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.xmark)));
      expect(taps, 1);

      // Mid-push the chrome shows a blend of two routes, so taps are swallowed.
      // Before the midpoint the leading cluster is still the outgoing route's.
      await _push(tester, const _Screen(title: 'Detail'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(inHost(find.byIcon(CupertinoIcons.xmark)),
          warnIfMissed: false);
      await settle(tester);
      expect(taps, 1);
    });
  });

  group('fallback rendering', () {
    testWidgets('without a shell the leading items render in-route',
        (tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: _Screen(title: 'Root', leading: [_cancel()]),
      ));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      expect(
        find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byIcon(CupertinoIcons.xmark),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a bare leading item renders in-route without a shell',
        (tester) async {
      await tester.pumpWidget(const CupertinoApp(
        home: _Screen(
          title: 'Root',
          leading: [
            GlassBarItem.custom(
              child: Text('avatar'),
              background: GlassBarItemBackground.none,
            ),
          ],
        ),
      ));
      await settle(tester);

      expect(find.text('avatar'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.byType(GlassButtonGroup),
        ),
        findsNothing,
      );
    });
  });

  group('spacers', () {
    // How far a capsule moves when a menu is set apart beside it.
    const travel = GlassNavPinnedMetrics.slot + GlassNavPinnedMetrics.groupGap;

    testWidgets('a spacer splits a leading run into two shells',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        leading: [
          _icon(CupertinoIcons.sidebar_left),
          _icon(CupertinoIcons.slider_horizontal_3),
          const GlassBarItem.spacer(),
          _icon(CupertinoIcons.xmark),
        ],
      )));
      await settle(tester);

      final shells = inHost(find.byType(GlassButton));
      expect(shells, findsNWidgets(2));
      expect(
        tester.getSize(shells.first),
        const Size(GlassNavPinnedMetrics.slot * 2, GlassNavPinnedMetrics.slot),
      );
      expect(
        tester.getTopLeft(shells.last).dx - tester.getTopRight(shells.first).dx,
        GlassNavPinnedMetrics.groupGap,
      );
    });

    testWidgets('a capsule follows its items to a new place', (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          _icon(CupertinoIcons.add, id: 'add'),
          _icon(CupertinoIcons.search, id: 'search'),
        ],
      )));
      await settle(tester);

      Finder capsule() => find.ancestor(
            of: inHost(find.byIcon(CupertinoIcons.add)),
            matching: find.byType(GlassButton),
          );
      final element = tester.element(capsule());
      final before = tester.getTopRight(capsule()).dx;

      // The destination sets a menu apart at the trailing edge. Paired by
      // position, the capsule would morph into the menu's circle and a second
      // one would materialize beside it; paired by its items, it moves aside
      // for the menu instead.
      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            actions: [
              _icon(CupertinoIcons.add, id: 'add'),
              _icon(CupertinoIcons.search, id: 'search'),
              const GlassBarItem.spacer(),
              _icon(CupertinoIcons.ellipsis, id: 'more'),
            ],
          ));

      var last = before;
      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.element(capsule()), same(element));
        // It travels, rather than covering the whole distance in one frame.
        final edge = tester.getTopRight(capsule()).dx;
        expect((edge - last).abs(), lessThan(travel));
        last = edge;
      }

      await settle(tester);
      expect(tester.element(capsule()), same(element));
      expect(
        tester.getTopRight(capsule()).dx,
        before - travel,
      );
    });

    testWidgets('a capsule set apart buds out of its neighbour',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          _icon(CupertinoIcons.add, id: 'add'),
          _icon(CupertinoIcons.search, id: 'search'),
        ],
      )));
      await settle(tester);

      Finder shell(IconData icon) => find.ancestor(
            of: inHost(find.byIcon(icon)),
            matching: find.byType(GlassButton),
          );
      bool ownLayer(IconData icon) =>
          tester.widget<GlassButton>(shell(icon)).useOwnLayer;
      expect(ownLayer(CupertinoIcons.add), isTrue);

      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            actions: [
              _icon(CupertinoIcons.add, id: 'add'),
              _icon(CupertinoIcons.search, id: 'search'),
              const GlassBarItem.spacer(),
              _icon(CupertinoIcons.ellipsis, id: 'more'),
            ],
          ));
      await tester.pump(const Duration(milliseconds: 16));

      // The menu's shell is there from the first frame, inside the capsule it
      // buds from, and the two draw into one layer so their glass joins.
      expect(
        tester
            .getRect(shell(CupertinoIcons.add))
            .overlaps(tester.getRect(shell(CupertinoIcons.ellipsis))),
        isTrue,
      );
      expect(ownLayer(CupertinoIcons.add), isFalse);
      expect(ownLayer(CupertinoIcons.ellipsis), isFalse);

      // Mid-bud the capsule swells as it reshapes; the bud stays on its centre
      // line rather than sinking with the swell.
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester.getCenter(shell(CupertinoIcons.ellipsis)).dy,
        moreOrLessEquals(
          tester.getCenter(shell(CupertinoIcons.add)).dy,
          epsilon: 0.5,
        ),
      );

      // At rest they have parted, and each has its own layer again.
      await settle(tester);
      expect(
        tester
            .getRect(shell(CupertinoIcons.add))
            .overlaps(tester.getRect(shell(CupertinoIcons.ellipsis))),
        isFalse,
      );
      expect(ownLayer(CupertinoIcons.add), isTrue);
      expect(ownLayer(CupertinoIcons.ellipsis), isTrue);
    });

    testWidgets('a capsule set apart merges back on the way out',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [_icon(CupertinoIcons.add, id: 'add')],
      )));
      await settle(tester);
      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            actions: [
              _icon(CupertinoIcons.add, id: 'add'),
              const GlassBarItem.spacer(),
              _icon(CupertinoIcons.ellipsis, id: 'more'),
            ],
          ));
      await settle(tester);

      Finder shell(IconData icon) => find.ancestor(
            of: inHost(find.byIcon(icon)),
            matching: find.byType(GlassButton),
          );
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Late in the pop the menu's shell is inside the capsule it is merging
      // into, both still in the shared layer.
      expect(
        tester
            .getRect(shell(CupertinoIcons.add))
            .overlaps(tester.getRect(shell(CupertinoIcons.ellipsis))),
        isTrue,
      );
      expect(
        tester.widget<GlassButton>(shell(CupertinoIcons.ellipsis)).useOwnLayer,
        isFalse,
      );

      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.ellipsis)), findsNothing);
    });

    testWidgets('under reduce motion a capsule set apart materializes',
        (tester) async {
      await tester.pumpWidget(CupertinoApp(
        builder: (context, child) => GlassAccessibilityScope(
          reduceMotion: true,
          child: GlassNavigationShell(child: child!),
        ),
        home: _Screen(
          title: 'Root',
          actions: [_icon(CupertinoIcons.add, id: 'add')],
        ),
      ));
      await settle(tester);

      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            actions: [
              _icon(CupertinoIcons.add, id: 'add'),
              const GlassBarItem.spacer(),
              _icon(CupertinoIcons.ellipsis, id: 'more'),
            ],
          ));
      await tester.pump(const Duration(milliseconds: 16));

      // Nothing buds: the menu is not drawn until the switch.
      expect(inHost(find.byIcon(CupertinoIcons.ellipsis)), findsNothing);
      expect(
        tester
            .widget<GlassButton>(find.ancestor(
              of: inHost(find.byIcon(CupertinoIcons.add)),
              matching: find.byType(GlassButton),
            ))
            .useOwnLayer,
        isTrue,
      );
    });

    testWidgets('a shell that dissolves closes its gap as it goes',
        (tester) async {
      await tester.pumpWidget(shellApp(_Screen(
        title: 'Root',
        actions: [
          _icon(CupertinoIcons.add, id: 'add'),
          const GlassBarItem.spacer(),
          _icon(CupertinoIcons.ellipsis, id: 'more'),
        ],
      )));
      await settle(tester);
      Finder capsule() => find.ancestor(
            of: inHost(find.byIcon(CupertinoIcons.add)),
            matching: find.byType(GlassButton),
          );
      final before = tester.getTopRight(capsule()).dx;

      await _push(
          tester,
          _Screen(
            title: 'Detail',
            backButton: false,
            actions: [_icon(CupertinoIcons.add, id: 'add')],
          ));

      var last = before;
      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final edge = tester.getTopRight(capsule()).dx;
        expect((edge - last).abs(), lessThan(travel));
        last = edge;
      }

      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.ellipsis)), findsNothing);
      expect(
        tester.getTopRight(capsule()).dx,
        before + travel,
      );
    });
  });
}

GlassBarItem _icon(IconData icon, {Object? id}) =>
    GlassBarItem.icon(icon: Icon(icon), id: id, onTap: () {});

/// A custom item that is a glass surface in its own right.
GlassBarItem _ownCapsule({Object? id, String label = 'capsule'}) =>
    GlassBarItem.custom(
      id: id,
      background: GlassBarItemBackground.own,
      child: GlassButton.custom(
        onTap: () {},
        child: Text(label),
      ),
    );

GlassBarItem _cancel() => GlassBarItem.icon(
      icon: const Icon(CupertinoIcons.xmark),
      onTap: () {},
    );

Future<void> _push(WidgetTester tester, Widget screen) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.push(CupertinoPageRoute<void>(builder: (_) => screen));
  await tester.pump();
}

/// A minimal screen with a pinned bar.
class _Screen extends StatelessWidget {
  const _Screen({
    required this.title,
    this.leading = const [],
    this.actions = const [],
    this.backButton = true,
    this.supplement = false,
  });

  final String title;
  final List<GlassBarItem> leading;
  final List<GlassBarItem> actions;
  final bool backButton;
  final bool supplement;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar.pinned(
        title: Text(title),
        leading: leading,
        actions: actions,
        backButton: backButton,
        leadingItemsSupplementBackButton: supplement,
      ),
      body: Center(child: Text('$title body')),
    );
  }
}

/// [DefaultCupertinoLocalizations] with a translated back label, standing in
/// for a real localisation bundle.
class _StubCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const _StubCupertinoLocalizations();

  @override
  String get backButtonLabel => 'Atrás';
}

class _StubCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _StubCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const _StubCupertinoLocalizations();

  @override
  bool shouldReload(_StubCupertinoLocalizationsDelegate old) => false;
}
