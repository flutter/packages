import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/glass_nav_pinned_host.dart';

class _Screen extends StatelessWidget {
  const _Screen({required this.title, this.actions, this.buttonSettings});

  final String title;
  final List<GlassBarItem>? actions;
  final LiquidGlassSettings? buttonSettings;

  @override
  Widget build(BuildContext context) {
    final items = actions;
    return GlassScaffold(
      appBar: items == null
          ? GlassAppBar(title: Text(title))
          : GlassAppBar.pinned(
              title: Text(title),
              buttonSettings: buttonSettings,
              actions: items,
            ),
      body: Center(child: Text('$title body')),
    );
  }
}

void main() {
  setUp(() {
    // Force the gate open so the pinned path is exercised in headless tests.
    GlassNavigationShellState.debugPinningSupported = true;
  });

  tearDown(() {
    GlassNavigationShellState.debugPinningSupported = null;
  });

  Widget shellApp(Widget home) {
    return CupertinoApp(
      builder: (context, child) => GlassNavigationShell(child: child!),
      home: home,
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump();
  }

  group('GlassNavPinnedHost tintColor shell and settings', () {
    testWidgets(
        'separate item with tintColor creates shell with clear bodyMode and tint',
        (tester) async {
      const tint = Color(0xFFFF9500);

      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Tinted Screen',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.heart_fill),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: tint,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      final glassButtons = tester.widgetList<GlassButton>(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byType(GlassButton),
        ),
      );

      expect(glassButtons, isNotEmpty);
      final shellButton = glassButtons.first;
      expect(shellButton.settings, isNotNull);
      expect(shellButton.settings!.glassColor, tint);
      expect(shellButton.settings!.bodyMode, GlassBodyMode.clear);
    });

    testWidgets('tinted shell keeps the bar\'s buttonSettings under its tint',
        (tester) async {
      const tint = Color(0xFF007AFF);

      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Tinted Screen',
            buttonSettings: LiquidGlassSettings.ios27Light,
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.checkmark),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: tint,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      final shellButton = tester
          .widgetList<GlassButton>(
            find.descendant(
              of: find.byType(GlassNavPinnedHost),
              matching: find.byType(GlassButton),
            ),
          )
          .first;

      expect(
        shellButton.settings,
        LiquidGlassSettings.ios27Light.copyWith(
          glassColor: tint,
          bodyMode: GlassBodyMode.clear,
        ),
      );
    });

    testWidgets(
        'separate item without tintColor creates shell with null settings',
        (tester) async {
      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Untinted Screen',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: null,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      final glassButtons = tester.widgetList<GlassButton>(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byType(GlassButton),
        ),
      );

      expect(glassButtons, isNotEmpty);
      final shellButton = glassButtons.first;
      expect(shellButton.settings, isNull);
    });
  });

  group('GlassNavPinnedHost foreground luminance flip', () {
    testWidgets(
        'bright tint (luminance > 0.35) flips icon color to high-contrast black',
        (tester) async {
      // Yellow: luminance ~0.67 > 0.35
      const brightYellow = Color(0xFFFFCC00);

      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Yellow Tint',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.star_fill),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: brightYellow,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      final iconFinder = find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.star_fill),
      );
      expect(iconFinder, findsOneWidget);

      final iconTheme = IconTheme.of(tester.element(iconFinder));
      expect(iconTheme.color, const Color(0xFF000000));
    });

    testWidgets(
        'dark tint (luminance <= 0.35) flips icon color to high-contrast white',
        (tester) async {
      // iOS active blue: luminance ~0.21 <= 0.35
      const darkBlue = Color(0xFF007AFF);

      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Blue Tint',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.bookmark_fill),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: darkBlue,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      final iconFinder = find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.bookmark_fill),
      );
      expect(iconFinder, findsOneWidget);

      final iconTheme = IconTheme.of(tester.element(iconFinder));
      expect(iconTheme.color, const Color(0xFFFFFFFF));
    });

    testWidgets('untinted item falls back to CupertinoColors.label',
        (tester) async {
      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Untinted',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.bell),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: null,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      final iconFinder = find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.bell),
      );
      expect(iconFinder, findsOneWidget);

      final iconElement = tester.element(iconFinder);
      final iconTheme = IconTheme.of(iconElement);
      final expectedLabel = CupertinoColors.label.resolveFrom(iconElement);
      expect(iconTheme.color, expectedLabel);
    });
  });

  group('GlassNavPinnedHost route transitions with tintColor', () {
    testWidgets(
        'transition between tinted items forwards tintColor across animation frames',
        (tester) async {
      const tintA = Color(0xFFFF2D55); // Pink/red
      const tintB = Color(0xFF34C759); // Green

      await tester.pumpWidget(
        shellApp(
          _Screen(
            title: 'Screen A',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: tintA,
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      // Verify Screen A button has tintA
      var shellButtons = tester.widgetList<GlassButton>(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byType(GlassButton),
        ),
      );
      expect(shellButtons.first.settings?.glassColor, tintA);

      // Push Screen B with tintB
      final navState = tester.state<NavigatorState>(find.byType(Navigator));
      navState.push(
        CupertinoPageRoute<void>(
          builder: (_) => _Screen(
            title: 'Screen B',
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.check_mark),
                onTap: () {},
                background: GlassBarItemBackground.separate,
                tintColor: tintB,
              ),
            ],
          ),
        ),
      );

      // Pump halfway through the route transition to exercise interpolation/forwarding paths
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Pinned host should remain rendered during transition without throwing
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);

      // Complete transition
      await settle(tester);

      // Verify Screen B action button has tintB (ignoring untinted back button)
      shellButtons = tester.widgetList<GlassButton>(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byType(GlassButton),
        ),
      );
      final tintedButtonsB =
          shellButtons.where((b) => b.settings?.glassColor != null).toList();
      expect(tintedButtonsB, hasLength(1));
      expect(tintedButtonsB.single.settings?.glassColor, tintB);

      // Pop back to Screen A
      navState.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(GlassNavPinnedHost), findsOneWidget);

      await settle(tester);
      shellButtons = tester.widgetList<GlassButton>(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byType(GlassButton),
        ),
      );
      final tintedButtonsA =
          shellButtons.where((b) => b.settings?.glassColor != null).toList();
      expect(tintedButtonsA, hasLength(1));
      expect(tintedButtonsA.single.settings?.glassColor, tintA);
    });
  });
}
