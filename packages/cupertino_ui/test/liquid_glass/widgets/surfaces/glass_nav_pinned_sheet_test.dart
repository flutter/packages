import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/glass_nav_pinned_host.dart';

void main() {
  setUp(() {
    GlassNavigationShellState.debugPinningSupported = true;
    GlassModalSheet.debugMorphSupportsBlending = true;
  });

  tearDown(() {
    GlassNavigationShellState.debugPinningSupported = null;
    GlassModalSheet.debugMorphSupportsBlending = null;
  });

  Widget shellApp(Widget home) => CupertinoApp(
        builder: (context, child) => GlassNavigationShell(child: child!),
        home: home,
      );

  /// Settles the route transition and the post-frame registration handover.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump();
  }

  Finder inHost(Finder matching) => find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: matching,
      );

  /// What the capsule holding [icon] is painted at, on the side of the
  /// hand-over [scope] selects: the first [Opacity] under the trigger there is
  /// the one the trigger empties.
  double capsuleOpacity(WidgetTester tester, Finder scope, IconData icon) {
    final trigger = find.ancestor(
      of: find.descendant(of: scope, matching: find.byIcon(icon)),
      matching: find.byType(GlassMorphTrigger),
    );
    return tester
        .widget<Opacity>(
          find
              .descendant(of: trigger.first, matching: find.byType(Opacity))
              .first,
        )
        .opacity;
  }

  double hostCapsuleOpacity(WidgetTester tester, [IconData? icon]) =>
      capsuleOpacity(
        tester,
        find.byType(GlassNavPinnedHost),
        icon ?? CupertinoIcons.add,
      );

  double barCapsuleOpacity(WidgetTester tester, [IconData? icon]) =>
      capsuleOpacity(
        tester,
        find.byType(GlassPinnedBarChrome),
        icon ?? CupertinoIcons.add,
      );

  /// Whether the bar paints [icon] at all, as opposed to laying out its
  /// unpainted placeholder for the shell's copy.
  bool barPaints(WidgetTester tester, IconData icon) => !find
      .ancestor(
        of: find.descendant(
          of: find.byType(GlassPinnedBarChrome),
          matching: find.byIcon(icon),
        ),
        matching: find.byType(Opacity),
      )
      .evaluate()
      .any((e) => (e.widget as Opacity).opacity == 0.0);

  group('a sheet item in the pinned chrome', () {
    testWidgets('presents out of the hoisted capsule, which the shell keeps',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen()));
      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);
      expect(hostCapsuleOpacity(tester), 1.0);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump();

      // The morph empties the capsule it came out of, so keeping it hoisted
      // draws nothing above the sheet — and handing it back would take the
      // anchor out from under the droplet.
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);
      expect(hostCapsuleOpacity(tester), 0.0);
    });

    testWidgets('hands the rest of the chrome back to the route',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen()));
      await settle(tester);
      final route = ModalRoute.of(tester.element(find.text('body')))!;
      final shell = tester.state<GlassNavigationShellState>(
        find.byType(GlassNavigationShell),
      );
      expect(inHost(find.byIcon(CupertinoIcons.bookmark)), findsOneWidget);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Every other capsule sits under the sheet with the rest of the page:
      // the shell draws above the Navigator, where the sheet cannot cover it.
      expect(shell.isHoisting(route), isFalse);
      expect(shell.presentingSheetItem(route)?.id, 'add');
      expect(inHost(find.byIcon(CupertinoIcons.bookmark)), findsNothing);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);

      // The bar draws the bookmark itself and leaves the emptied capsule's
      // slot as the placeholder it already had.
      expect(barPaints(tester, CupertinoIcons.bookmark), isTrue);
      expect(barPaints(tester, CupertinoIcons.add), isFalse);
    });

    testWidgets('empties the capsule rather than the glyph it was tapped on',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen()));
      await settle(tester);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump();

      // The neighbouring icon goes with it: on screen the cluster is one
      // control, and a droplet out of a hole in it reads as a second object.
      expect(hostCapsuleOpacity(tester, CupertinoIcons.share), 0.0);
    });

    testWidgets('is inert while a transition is running', (tester) async {
      await tester.pumpWidget(shellApp(const _Screen()));
      await settle(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        CupertinoPageRoute<void>(builder: (_) => const _Screen(title: 'Next')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Mid-transition the item is not hit-testable at all, which is the
      // point — a miss here is the assertion, not a flake.
      await tester.tap(
        inHost(find.byIcon(CupertinoIcons.add)).first,
        warnIfMissed: false,
      );
      await tester.pump();

      expect(hostCapsuleOpacity(tester), 1.0);
      await settle(tester);
    });

    testWidgets('presents out of the hoisted capsule for a bar drawing its own',
        (tester) async {
      var presented = 0;
      GlassMorphAnchor? seen;
      await tester.pumpWidget(shellApp(_OwnBarScreen(
        onPresent: (anchor) {
          presented++;
          seen = anchor;
        },
      )));
      await settle(tester);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();

      // The hoisted capsule is the shell's, so a registrant that draws the
      // items itself still gets a real anchor.
      expect(presented, 1);
      expect(seen, isNotNull);
    });

    testWidgets('lets go of a capsule no sheet claimed', (tester) async {
      await tester.pumpWidget(shellApp(_OwnBarScreen(
        onPresent: (anchor) => showCupertinoDialog<void>(
          context: tester.element(find.text('body')),
          builder: (_) => const SizedBox(),
        ),
      )));
      await settle(tester);
      final route = ModalRoute.of(tester.element(find.text('body')))!;
      final shell = tester.state<GlassNavigationShellState>(
        find.byType(GlassNavigationShell),
      );

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Nothing emptied the capsule by the end of the presentation's first
      // frame, so it is an ordinary presentation and the chrome hands back.
      expect(shell.isHoisting(route), isFalse);
      expect(shell.presentingSheetItem(route), isNull);
      expect(find.byType(GlassNavPinnedHost), findsNothing);
    });

    testWidgets('keeps the capsule through a sheet presented frames later',
        (tester) async {
      // A presenter that sizes its sheet to its content measures that
      // content offscreen first, which costs frames between the tap and the
      // push. The hold has to outlast that gap.
      await tester.pumpWidget(shellApp(_OwnBarScreen(
        onPresent: (anchor) async {
          final binding = WidgetsBinding.instance;
          await binding.endOfFrame;
          await binding.endOfFrame;
          final context = tester.element(find.text('body'));
          if (!context.mounted) return;
          await GlassModalSheet.show<void>(
            context: context,
            morphFrom: anchor,
            builder: (_) => const SizedBox(height: 200),
          );
        },
      )));
      await settle(tester);
      final route = ModalRoute.of(tester.element(find.text('body')))!;
      final shell = tester.state<GlassNavigationShellState>(
        find.byType(GlassNavigationShell),
      );

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      // Nothing is presented yet: the chrome stays hoisted as it was.
      await tester.pump();
      expect(shell.isHoisting(route), isTrue);
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);

      // The sheet lands, and the capsule it morphs out of is still the
      // shell's to keep.
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(shell.isHoisting(route), isFalse);
      expect(shell.presentingSheetItem(route), isNotNull);
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);
    });

    testWidgets(
        'dismissing the sheet restores the capsule and re-hoists chrome',
        (tester) async {
      await tester.pumpWidget(shellApp(const _Screen()));
      await settle(tester);
      final route = ModalRoute.of(tester.element(find.text('body')))!;
      final shell = tester.state<GlassNavigationShellState>(
        find.byType(GlassNavigationShell),
      );

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump();

      expect(hostCapsuleOpacity(tester), 0.0);
      expect(shell.isHoisting(route), isFalse);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await settle(tester);

      expect(hostCapsuleOpacity(tester), 1.0);
      expect(shell.isHoisting(route), isTrue);
      expect(shell.presentingSheetItem(route), isNull);
      expect(inHost(find.byIcon(CupertinoIcons.bookmark)), findsOneWidget);
    });

    testWidgets('presents out of the leading capsule when declared in leading',
        (tester) async {
      await tester.pumpWidget(shellApp(const _LeadingScreen()));
      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);
      expect(hostCapsuleOpacity(tester), 1.0);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump();

      expect(hostCapsuleOpacity(tester), 0.0);
    });

    testWidgets('is reported to a bar that draws its own chrome',
        (tester) async {
      final seen = <GlassPinnedBarChromeData>[];
      await tester.pumpWidget(shellApp(_ChromeScreen(onBuild: seen.add)));
      await settle(tester);
      expect(seen.last.hoisted, isTrue);
      expect(seen.last.presenting, isNull);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.add)));
      await tester.pump();
      await tester.pump();

      expect(seen.last.hoisted, isFalse);
      expect(seen.last.presenting?.id, 'add');

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await settle(tester);

      expect(seen.last.hoisted, isTrue);
      expect(seen.last.presenting, isNull);
    });
  });

  group('a sheet item drawn in-route', () {
    testWidgets('presents through its own capsule', (tester) async {
      await tester.pumpWidget(const CupertinoApp(home: _Screen()));
      await settle(tester);
      expect(find.byType(GlassNavPinnedHost), findsNothing);
      expect(barCapsuleOpacity(tester), 1.0);

      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pump();
      await tester.pump();

      expect(barCapsuleOpacity(tester), 0.0);
    });
  });
}

/// A screen whose first trailing group presents a sheet out of its capsule,
/// followed by a group of its own.
class _Screen extends StatelessWidget {
  const _Screen({this.title = 'Home'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar.pinned(
        title: Text(title),
        backButton: false,
        actions: [
          GlassBarItem.sheet(
            icon: const Icon(CupertinoIcons.add),
            id: 'add',
            onPresent: (anchor) => GlassModalSheet.show<void>(
              context: context,
              morphFrom: anchor,
              builder: (_) => const SizedBox(height: 200),
            ),
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.share),
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.bookmark),
            background: GlassBarItemBackground.separate,
            onTap: () {},
          ),
        ],
      ),
      body: const Center(child: Text('body')),
    );
  }
}

/// A screen that registers with the shell directly, drawing its own bar — the
/// shape `GlassPinnedBarChrome`'s own doc points such an app at.
class _OwnBarScreen extends StatefulWidget {
  const _OwnBarScreen({required this.onPresent});

  final void Function(GlassMorphAnchor? anchor) onPresent;

  @override
  State<_OwnBarScreen> createState() => _OwnBarScreenState();
}

class _OwnBarScreenState extends State<_OwnBarScreen> {
  GlassNavigationShellState? _shell;
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shell = GlassNavigationShell.maybeOf(context);
    _route = ModalRoute.of(context);
    _shell?.register(
      _route!,
      GlassNavBarRegistration(
        actions: [
          GlassBarItem.sheet(
            icon: const Icon(CupertinoIcons.add),
            onPresent: widget.onPresent,
          ),
        ],
        showsBackButton: false,
      ),
    );
  }

  @override
  void dispose() {
    if (_route != null) _shell?.unregister(_route!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      const CupertinoPageScaffold(child: Center(child: Text('body')));
}

/// A screen whose one leading group presents a sheet out of its capsule.
class _LeadingScreen extends StatelessWidget {
  const _LeadingScreen();

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar.pinned(
        title: const Text('Leading'),
        backButton: false,
        leading: [
          GlassBarItem.sheet(
            icon: const Icon(CupertinoIcons.add),
            onPresent: (anchor) => GlassModalSheet.show<void>(
              context: context,
              morphFrom: anchor,
              builder: (_) => const SizedBox(height: 200),
            ),
          ),
        ],
      ),
      body: const Center(child: Text('body')),
    );
  }
}

/// A screen pinning through [GlassPinnedBarChrome], reporting each frame's
/// chrome as a bar drawing its own would read it.
class _ChromeScreen extends StatelessWidget {
  const _ChromeScreen({required this.onBuild});

  final void Function(GlassPinnedBarChromeData chrome) onBuild;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          GlassPinnedBarChrome(
            backButton: false,
            actions: [
              GlassBarItem.sheet(
                icon: const Icon(CupertinoIcons.add),
                id: 'add',
                onPresent: (anchor) => GlassModalSheet.show<void>(
                  context: context,
                  morphFrom: anchor,
                  builder: (_) => const SizedBox(height: 200),
                ),
              ),
            ],
            builder: (context, chrome) {
              onBuild(chrome);
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: chrome.actions,
              );
            },
          ),
          const Expanded(child: Center(child: Text('body'))),
        ],
      ),
    );
  }
}
