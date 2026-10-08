import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ── Standalone reproduction apps ─────────────────────────────────────────────

class ImperativeReproApp extends StatelessWidget {
  const ImperativeReproApp({
    super.key,
    this.nested = true,
    this.navigatorKey,
  });
  final bool nested;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    final navKey = navigatorKey ?? GlobalKey<NavigatorState>();
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: Navigator(
        key: navKey,
        onGenerateRoute: (_) => CupertinoPageRoute<void>(
          builder: (_) => nested
              ? Navigator(
                  onGenerateRoute: (_) => CupertinoPageRoute<void>(
                    builder: (_) => _MenuScreen(
                      onStartActivity: () => navKey.currentState!.push<void>(
                        CupertinoPageRoute<void>(
                          builder: (_) => const _DestinationScreen(),
                        ),
                      ),
                    ),
                  ),
                )
              : _MenuScreen(
                  onStartActivity: () => navKey.currentState!.push<void>(
                    CupertinoPageRoute<void>(
                      builder: (_) => const _DestinationScreen(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class DeclarativeReproApp extends StatefulWidget {
  const DeclarativeReproApp({super.key, this.nested = true});
  final bool nested;

  @override
  State<DeclarativeReproApp> createState() => _DeclarativeReproAppState();
}

class _DeclarativeReproAppState extends State<DeclarativeReproApp> {
  bool _showDestination = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: Navigator(
        pages: [
          CupertinoPage<void>(
            key: const ValueKey('root-page'),
            child: widget.nested
                ? Navigator(
                    pages: [
                      CupertinoPage<void>(
                        key: const ValueKey('tab-menu-page'),
                        child: _MenuScreen(
                          onStartActivity: () =>
                              setState(() => _showDestination = true),
                        ),
                      ),
                    ],
                    onDidRemovePage: (_) {},
                  )
                : _MenuScreen(
                    onStartActivity: () =>
                        setState(() => _showDestination = true),
                  ),
          ),
          if (_showDestination)
            const CupertinoPage<void>(
              key: ValueKey('destination-page'),
              child: _DestinationScreen(),
            ),
        ],
        onDidRemovePage: (_) => setState(() => _showDestination = false),
      ),
    );
  }
}

class _MenuScreen extends StatelessWidget {
  const _MenuScreen({required this.onStartActivity});
  final VoidCallback onStartActivity;

  @override
  Widget build(BuildContext context) => GlassScaffold(
        background: const ColoredBox(color: Color(0xFF34264F)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('Page A'),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Timeline'),
                    GlassMenu(
                      menuAlignment: GlassMenuAlignment.bottomRight,
                      menuWidth: 192,
                      menuPadding: const EdgeInsets.all(8),
                      triggerBuilder: (context, toggle) => CupertinoButton(
                        key: const ValueKey('open-menu'),
                        onPressed: toggle,
                        child: const Icon(CupertinoIcons.add),
                      ),
                      items: [
                        GlassMenuItem(
                          title: 'Start Activity',
                          height: 48,
                          onTap: onStartActivity,
                        ),
                        GlassMenuItem(title: 'Log', height: 48, onTap: () {}),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}

class _DestinationScreen extends StatelessWidget {
  const _DestinationScreen();

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
        backgroundColor: Color(0xFF102E42),
        navigationBar: CupertinoNavigationBar(middle: Text('Page B')),
        child: Center(child: Text('Destination page')),
      );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('Issue #274 — Menu dismissal during navigation', () {
    for (final nested in [false, true]) {
      testWidgets(
          'Imperative push: menu dismisses safely during transition (nested=$nested)',
          (tester) async {
        await tester.pumpWidget(
          LiquidGlassWidgets.wrap(child: ImperativeReproApp(nested: nested)),
        );
        await tester.pumpAndSettle();

        // Open the menu
        await tester.tap(find.byKey(const ValueKey('open-menu')));
        await tester.pumpAndSettle();
        expect(find.text('Start Activity'), findsOneWidget);

        // Tap the navigation item
        await tester.tap(find.text('Start Activity'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Destination page is active, no exceptions thrown
        expect(tester.takeException(), isNull);
        expect(find.text('Destination page'), findsOneWidget);
        expect(find.text('Start Activity'), findsNothing,
            reason:
                'The outgoing menu must not linger over the destination page.');

        await tester.pumpAndSettle();
        expect(find.text('Destination page'), findsOneWidget);
      });

      testWidgets(
          'Declarative Navigator.pages (go_router): zero assertion errors during update (nested=$nested)',
          (tester) async {
        await tester.pumpWidget(
          LiquidGlassWidgets.wrap(child: DeclarativeReproApp(nested: nested)),
        );
        await tester.pumpAndSettle();

        // Open the menu
        await tester.tap(find.byKey(const ValueKey('open-menu')));
        await tester.pumpAndSettle();
        expect(find.text('Start Activity'), findsOneWidget);

        // Trigger declarative navigation — in 1.4.1 this threw:
        // 'SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks'
        await tester.tap(find.text('Start Activity'));
        await tester.pump();

        expect(tester.takeException(), isNull,
            reason:
                'Declarative navigation update must never throw build-phase assertions.');

        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Destination page'), findsOneWidget);
        expect(find.text('Start Activity'), findsNothing);

        await tester.pumpAndSettle();
        expect(find.text('Destination page'), findsOneWidget);
      });
    }

    testWidgets(
        'GlassPopover also navigates declaratively without assertion errors',
        (tester) async {
      bool showDest = false;
      await tester.pumpWidget(
        CupertinoApp(
          home: StatefulBuilder(
            builder: (context, setState) => Navigator(
              pages: [
                CupertinoPage<void>(
                  key: const ValueKey('popover-page'),
                  child: CupertinoPageScaffold(
                    child: Center(
                      child: GlassPopover(
                        trigger: const Text('Open Popover'),
                        contentBuilder: (context, close) => CupertinoButton(
                          onPressed: () => setState(() => showDest = true),
                          child: const Text('Go Dest'),
                        ),
                      ),
                    ),
                  ),
                ),
                if (showDest)
                  const CupertinoPage<void>(
                    key: ValueKey('dest-page'),
                    child: CupertinoPageScaffold(
                      child: Center(child: Text('Popover Dest')),
                    ),
                  ),
              ],
              onDidRemovePage: (_) => setState(() => showDest = false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Popover'));
      await tester.pumpAndSettle();
      expect(find.text('Go Dest'), findsOneWidget);

      await tester.tap(find.text('Go Dest'));
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason:
              'GlassPopover declarative update must not throw build-phase assertions.');

      await tester.pumpAndSettle();
      expect(find.text('Popover Dest'), findsOneWidget);
    });

    testWidgets(
        'GlassMenu with GlassButton.custom triggerBuilder opens and navigates cleanly',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GlassMenu(
                triggerBuilder: (context, toggleMenu) => GlassButton.custom(
                  onTap: toggleMenu,
                  child: const Text('Open Navigation Menu'),
                ),
                items: [
                  GlassMenuItem(
                    title: 'Start Activity (Navigates to Page)',
                    onTap: () {
                      Navigator.of(
                              tester.element(find.text('Open Navigation Menu')))
                          .push(
                        CupertinoPageRoute<void>(
                          builder: (_) => const CupertinoPageScaffold(
                            child: Center(child: Text('Activity Dashboard')),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap trigger
      final menuTrigger = find.text('Open Navigation Menu');
      expect(menuTrigger, findsOneWidget);
      await tester.tap(menuTrigger);
      await tester.pumpAndSettle();

      // Menu opens
      final startItem = find.text('Start Activity (Navigates to Page)');
      expect(startItem, findsOneWidget);

      // Navigate
      await tester.tap(startItem);
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.text('Activity Dashboard'), findsOneWidget);
    });

    testWidgets(
        'GlassMenu OverlayPortal targets OverlayChildLocation.nearestOverlay',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GlassMenu(
                triggerBuilder: (context, toggle) => CupertinoButton(
                  onPressed: toggle,
                  child: const Text('Open'),
                ),
                items: [
                  GlassMenuItem(title: 'Item 1', onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      );

      final portal = tester.widget<OverlayPortal>(
        find.descendant(
          of: find.byType(GlassMenu),
          matching: find.byType(OverlayPortal),
        ),
      );

      expect(
        portal.overlayLocation,
        OverlayChildLocation.nearestOverlay,
        reason:
            'the menu morph must attach to the nearest overlay so it remains '
            'confined to the route and does not linger over destination pages (#274)',
      );
    });

    testWidgets(
        'GlassMenu renders accurately over trigger inside nested layout with offset',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Row(
              children: [
                // 100px sidebar offsetting the nested navigator/overlay
                const SizedBox(width: 100),
                Expanded(
                  child: Navigator(
                    onGenerateRoute: (_) => CupertinoPageRoute<void>(
                      builder: (context) => CupertinoPageScaffold(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40, top: 40),
                            child: GlassMenu(
                              menuWidth: 150,
                              triggerBuilder: (context, toggle) =>
                                  CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: toggle,
                                child: const Text('NestedMenuTrigger'),
                              ),
                              items: [
                                GlassMenuItem(
                                  title: 'NestedMenuItem',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('NestedMenuTrigger'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('NestedMenuItem'), findsOneWidget);

      // Trigger is at global X = 100 (sidebar) + 40 (padding) = 140
      final triggerRect = tester.getRect(find.byType(CupertinoButton));
      expect(triggerRect.left, 140.0);
      expect(triggerRect.top, 40.0);

      // The menu body must open relative to the trigger at 140, NOT double-offset to 240!
      final itemRect = tester.getRect(find.text('NestedMenuItem'));
      expect(itemRect.left, greaterThanOrEqualTo(100.0));
      expect(itemRect.left, lessThan(200.0));
    });
  });
}
