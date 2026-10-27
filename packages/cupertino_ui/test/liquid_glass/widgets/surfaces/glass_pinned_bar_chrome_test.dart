// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
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
    bool shell = true,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return MaterialApp(
      builder: (context, child) {
        final content = Directionality(
          textDirection: textDirection,
          child: child!,
        );
        return shell ? GlassNavigationShell(child: content) : content;
      },
      home: Directionality(
        textDirection: textDirection,
        child: home,
      ),
    );
  }

  /// Settles the route transition and the post-frame registration handover.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump();
  }

  Finder inHost(Finder matching) =>
      find.descendant(of: find.byType(GlassNavPinnedHost), matching: matching);

  Finder inBar(Finder matching) =>
      find.descendant(of: find.byType(AppBar), matching: matching);

  group('horizontal inset', () {
    /// The chrome's own box, which is what the inset positions.
    Rect hostRect(WidgetTester tester) {
      final box =
          tester.renderObject<RenderBox>(find.byType(GlassNavPinnedHost));
      return box.localToGlobal(Offset.zero) & box.size;
    }

    testWidgets('defaults to the inset GlassAppBar draws its own chrome at',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      final screen =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final rect = hostRect(tester);
      expect(rect.left, GlassNavPinnedMetrics.horizontalPadding);
      expect(rect.right, screen - GlassNavPinnedMetrics.horizontalPadding);
    });

    testWidgets('follows the bar that registered it', (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
        horizontalInset: 16,
      )));
      await settle(tester);

      // A bar aligned to its app's page gutter rather than the package's
      // default steps sideways at every hand-over unless the shell follows it.
      final screen =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final rect = hostRect(tester);
      expect(rect.left, 16);
      expect(rect.right, screen - 16);
    });

    testWidgets('a push lands on the incoming route\'s guide', (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
        horizontalInset: 16,
      )));
      await settle(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const _MaterialBarScreen(
          title: 'Detail',
          actionIcon: CupertinoIcons.share,
          horizontalInset: 4,
        ),
      ));
      await settle(tester);

      expect(hostRect(tester).left, 4);
    });

    testWidgets(
        'a pop lands on the incoming route\'s guide from the first frame',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
        horizontalInset: 16,
      )));
      await settle(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const _MaterialBarScreen(
          title: 'Detail',
          actionIcon: CupertinoIcons.share,
          horizontalInset: 4,
        ),
      ));
      await settle(tester);
      expect(hostRect(tester).left, 4);

      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(hostRect(tester).left, 16);

      await settle(tester);
      expect(hostRect(tester).left, 16);
    });
  });

  group('buttonSettings', () {
    testWidgets('follows the route being entered, on push and pop (fixes #351)',
        (tester) async {
      const inboxSettings = LiquidGlassSettings(blur: 10, thickness: 20);
      const detailSettings = LiquidGlassSettings(blur: 30, thickness: 40);

      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
        buttonSettings: inboxSettings,
      )));
      await settle(tester);

      LiquidGlassSettings? currentSettings() {
        final scopeFinder = find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byType(DefaultButtonSettings),
        );
        if (scopeFinder.evaluate().isEmpty) return null;
        return tester.widget<DefaultButtonSettings>(scopeFinder.first).settings;
      }

      expect(currentSettings()?.blur, 10);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const _MaterialBarScreen(
          title: 'Detail',
          actionIcon: CupertinoIcons.share,
          buttonSettings: detailSettings,
        ),
      ));
      await settle(tester);
      expect(currentSettings()?.blur, 30);

      // On pop, the chrome adopts the destination's buttonSettings immediately
      // during the transition rather than holding the leaving route's look
      // until it snaps at completion.
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(currentSettings()?.blur, 10);

      await settle(tester);
      expect(currentSettings()?.blur, 10);
    });
  });

  group('platform view backdrop', () {
    /// Whether every glass capsule the shell draws is on the backdrop route.
    bool hostOnBackdrop(WidgetTester tester) => tester
        .widgetList<GlassButton>(inHost(find.byType(GlassButton)))
        .every((b) => b.platformViewBackdrop);

    testWidgets('is off unless the bar says otherwise', (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      expect(inHost(find.byType(GlassButton)), findsWidgets);
      expect(hostOnBackdrop(tester), isFalse);
    });

    testWidgets('reaches the capsule the shell draws', (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Map',
        actionIcon: CupertinoIcons.add,
        platformViewBackdrop: true,
      )));
      await settle(tester);

      // The material slot alone cannot do this: the shader reads a captured
      // backdrop the platform view is never part of, so only the flag moves
      // the hoisted copy onto the live BackdropFilter the in-route one uses.
      expect(inHost(find.byType(GlassButton)), findsWidgets);
      expect(hostOnBackdrop(tester), isTrue);
    });

    testWidgets('reaches the in-route capsules too', (tester) async {
      await tester.pumpWidget(shellApp(
        const _MaterialBarScreen(
          title: 'Map',
          actionIcon: CupertinoIcons.add,
          platformViewBackdrop: true,
        ),
        shell: false,
      ));
      await settle(tester);

      final group = tester.widget<GlassButtonGroup>(
        inBar(find.byType(GlassButtonGroup)),
      );
      expect(group.platformViewBackdrop, isTrue);
    });

    testWidgets('follows the route being entered, from its first frame',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Map',
        actionIcon: CupertinoIcons.add,
        platformViewBackdrop: true,
      )));
      await settle(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const _MaterialBarScreen(
          title: 'Detail',
          actionIcon: CupertinoIcons.share,
        ),
      ));
      await settle(tester);
      expect(hostOnBackdrop(tester), isFalse);

      // A change of route remounts the shell's surface, so the flip has to
      // land on the first frame of the pop rather than once it settles —
      // otherwise the returning capsule materializes through the shader and
      // pops to the backdrop at the end.
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(hostOnBackdrop(tester), isTrue);

      await settle(tester);
      expect(hostOnBackdrop(tester), isTrue);
    });
  });

  group('registration', () {
    testWidgets('a plain Material AppBar hands its items to the shell',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      // The shell renders the capsule above the navigator...
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);
      // ...and the bar itself is left holding only its measuring placeholder.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(GlassButtonGroup),
        ),
        findsNothing,
      );
    });

    testWidgets('hoisted only flips on the frame after registration',
        (tester) async {
      final hoists = <bool>[];
      await tester.pumpWidget(shellApp(_RecordingScreen(hoists: hoists)));

      // The shell needs a frame to render its copy, so the first build must
      // still report the bar as owning its own chrome.
      expect(hoists, [false]);

      await tester.pump();
      expect(hoists.last, isTrue);
    });

    testWidgets('unregisters when the bar leaves the tree', (tester) async {
      await tester.pumpWidget(shellApp(const _TogglingScreen()));
      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);

      await tester.tap(find.text('drop'));
      await settle(tester);

      expect(find.byType(GlassPinnedBarChrome), findsNothing);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsNothing);
    });

    testWidgets('a pushed route takes the chrome and hands it back on pop',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const _MaterialBarScreen(
          title: 'Thread',
          actionIcon: CupertinoIcons.search,
        ),
      ));
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.search)), findsOneWidget);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsNothing);
      // The back button is the shell's, not the AppBar's automatic one.
      expect(inHost(find.byIcon(CupertinoIcons.back)), findsOneWidget);

      navigator.pop();
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);
      expect(inHost(find.byIcon(CupertinoIcons.back)), findsNothing);
    });

    testWidgets('onBack overrides the default pop', (tester) async {
      var custom = 0;
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      tester.state<NavigatorState>(find.byType(Navigator)).push(
            MaterialPageRoute<void>(
              builder: (_) => _MaterialBarScreen(
                title: 'Thread',
                actionIcon: CupertinoIcons.search,
                onBack: () => custom++,
              ),
            ),
          );
      await settle(tester);

      await tester.tap(inHost(find.byIcon(CupertinoIcons.back)));
      await settle(tester);

      expect(custom, 1);
      expect(find.text('Thread'), findsOneWidget); // custom handler didn't pop
    });

    testWidgets('backButton: false suppresses the pinned back button',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      tester.state<NavigatorState>(find.byType(Navigator)).push(
            MaterialPageRoute<void>(
              builder: (_) => const _MaterialBarScreen(
                title: 'Thread',
                actionIcon: CupertinoIcons.search,
                backButton: false,
              ),
            ),
          );
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.search)), findsOneWidget);
      expect(inHost(find.byIcon(CupertinoIcons.back)), findsNothing);
    });
  });

  group('opting out', () {
    testWidgets('without a shell the bar keeps drawing its own chrome',
        (tester) async {
      await tester.pumpWidget(shellApp(
        shell: false,
        const _MaterialBarScreen(
          title: 'Inbox',
          actionIcon: CupertinoIcons.add,
        ),
      ));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      // The widget builds the in-route capsule itself: a bar written against
      // it never has to declare a fallback of its own.
      expect(inBar(find.byType(GlassButtonGroup)), findsOneWidget);
      expect(inBar(find.byIcon(CupertinoIcons.add)), findsOneWidget);
    });

    testWidgets('the in-route back button is built for you and pops',
        (tester) async {
      await tester.pumpWidget(shellApp(
        shell: false,
        const _MaterialBarScreen(
          title: 'Inbox',
          actionIcon: CupertinoIcons.add,
        ),
      ));
      await settle(tester);

      tester.state<NavigatorState>(find.byType(Navigator)).push(
            MaterialPageRoute<void>(
              builder: (_) => const _MaterialBarScreen(
                title: 'Thread',
                actionIcon: CupertinoIcons.search,
              ),
            ),
          );
      await settle(tester);

      final back = inBar(find.byIcon(CupertinoIcons.back));
      expect(back, findsOneWidget);
      await tester.tap(back);
      await settle(tester);

      expect(find.text('Thread'), findsNothing);
      // Root route again: no back button, here or anywhere.
      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });

    testWidgets('survives the screen resizing under an opaque route',
        (tester) async {
      // flutter/flutter#192030: the bar's portal child, laid out against the
      // overlay's size from before the resize, asserted.
      await tester.pumpWidget(shellApp(
        shell: false,
        const Scaffold(
          appBar: GlassAppBar.pinned(title: Text('Inbox')),
        ),
      ));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const SizedBox.expand(),
      ));
      await settle(tester);

      tester.view.physicalSize = tester.view.physicalSize.flipped;
      addTearDown(tester.view.resetPhysicalSize);
      await settle(tester);
      navigator.pop();
      await settle(tester);

      expect(find.text('Inbox'), findsOneWidget);
    });

    testWidgets('the in-route capsule matches the one the shell draws',
        (tester) async {
      // Larger than the default icon, which happened to fit the padded slot.
      const screen = _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
        actionIconSize: 30,
      );
      await tester.pumpWidget(shellApp(screen));
      await settle(tester);
      final pinned = tester.getSize(inHost(find.byType(GlassButton)).first);

      await tester.pumpWidget(shellApp(screen, shell: false));
      await settle(tester);
      final inRoute = tester.getSize(inBar(find.byType(GlassButtonGroup)));

      expect(inRoute, pinned);
    });

    testWidgets('an unsupported device falls back in-route', (tester) async {
      GlassNavigationShellState.debugPinningSupported = false;
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
      )));
      await settle(tester);

      expect(find.byType(GlassNavPinnedHost), findsNothing);
      // The widget builds the in-route capsule itself: a bar written against
      // it never has to declare a fallback of its own.
      expect(inBar(find.byType(GlassButtonGroup)), findsOneWidget);
      expect(inBar(find.byIcon(CupertinoIcons.add)), findsOneWidget);
    });

    testWidgets('enabled: false keeps a route out of the shell entirely',
        (tester) async {
      await tester.pumpWidget(shellApp(const _MaterialBarScreen(
        title: 'Inbox',
        actionIcon: CupertinoIcons.add,
        enabled: false,
      )));
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.add)), findsNothing);
      expect(inBar(find.byIcon(CupertinoIcons.add)), findsOneWidget);
    });

    testWidgets('flipping enabled off releases a live registration',
        (tester) async {
      await tester.pumpWidget(shellApp(const _TogglingScreen()));
      await settle(tester);
      expect(inHost(find.byIcon(CupertinoIcons.add)), findsOneWidget);

      await tester.tap(find.text('disable'));
      await settle(tester);

      expect(inHost(find.byIcon(CupertinoIcons.add)), findsNothing);
      expect(inBar(find.byIcon(CupertinoIcons.add)), findsOneWidget);
    });
    testWidgets(
        'actions item order remains consistent in RTL when modal sheet is opened (fixes #374)',
        (tester) async {
      await tester.pumpWidget(shellApp(
        const _TwoActionScreen(),
        textDirection: TextDirection.rtl,
      ));
      await settle(tester);

      final shareBefore =
          tester.getCenter(inHost(find.byIcon(CupertinoIcons.share))).dx;
      final settingsBefore =
          tester.getCenter(inHost(find.byIcon(CupertinoIcons.settings))).dx;

      // In the hoisted host, slot 0 (share) is to the left of slot 1 (settings).
      expect(shareBefore, lessThan(settingsBefore));

      // Open a modal bottom sheet, triggering handover to in-route chrome.
      await tester.tap(find.text('open sheet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final shareAfter =
          tester.getCenter(inBar(find.byIcon(CupertinoIcons.share))).dx;
      final settingsAfter =
          tester.getCenter(inBar(find.byIcon(CupertinoIcons.settings))).dx;

      // Item order must not flip between hoisted and handed-over states.
      expect(shareAfter, lessThan(settingsAfter));

      // Dismiss the bottom sheet.
      Navigator.of(tester.element(find.text('open sheet'))).pop();
      await settle(tester);

      final shareDismissed =
          tester.getCenter(inHost(find.byIcon(CupertinoIcons.share))).dx;
      final settingsDismissed =
          tester.getCenter(inHost(find.byIcon(CupertinoIcons.settings))).dx;

      expect(shareDismissed, lessThan(settingsDismissed));
      expect(shareDismissed, shareBefore);
      expect(settingsDismissed, settingsBefore);
    });

    testWidgets(
        'leading item order remains consistent in RTL when modal sheet is opened',
        (tester) async {
      await tester.pumpWidget(shellApp(
        const _TwoLeadingScreen(),
        textDirection: TextDirection.rtl,
      ));
      await settle(tester);

      final shareBefore =
          tester.getCenter(inHost(find.byIcon(CupertinoIcons.share))).dx;
      final settingsBefore =
          tester.getCenter(inHost(find.byIcon(CupertinoIcons.settings))).dx;

      expect(shareBefore, lessThan(settingsBefore));

      // Open a modal bottom sheet, triggering handover to in-route chrome.
      await tester.tap(find.text('open sheet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final shareAfter =
          tester.getCenter(inBar(find.byIcon(CupertinoIcons.share))).dx;
      final settingsAfter =
          tester.getCenter(inBar(find.byIcon(CupertinoIcons.settings))).dx;

      expect(shareAfter, lessThan(settingsAfter));
    });

    testWidgets(
        'custom item preserves ambient RTL directionality during handover',
        (tester) async {
      TextDirection? hoistedDirection;

      await tester.pumpWidget(shellApp(
        GlassPinnedBarChrome(
          backButton: false,
          actions: [
            GlassBarItem.custom(
              child: Builder(
                builder: (context) {
                  hoistedDirection = Directionality.of(context);
                  return const Text('test');
                },
              ),
            ),
          ],
          builder: (context, chrome) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: chrome.actions,
            ),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const SizedBox(height: 200),
                  );
                },
                child: const Text('open sheet'),
              ),
            ),
          ),
        ),
        textDirection: TextDirection.rtl,
      ));
      await settle(tester);

      expect(hoistedDirection, TextDirection.rtl);

      await tester.tap(find.text('open sheet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customFinder = inBar(find.text('test'));
      expect(customFinder, findsOneWidget);
      final handedOverDirection =
          Directionality.of(tester.element(customFinder));
      expect(handedOverDirection, TextDirection.rtl);
    });
  });

  testWidgets('a spacer splits the in-route actions into two capsules',
      (tester) async {
    late GlassPinnedBarChromeData data;
    await tester.pumpWidget(shellApp(
      GlassPinnedBarChrome(
        actions: [
          GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
          GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.search), onTap: () {}),
          const GlassBarItem.spacer(),
          GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.ellipsis), onTap: () {}),
        ],
        builder: (context, chrome) {
          data = chrome;
          return Row(children: chrome.actions);
        },
      ),
      shell: false,
    ));
    await settle(tester);

    // One widget per shell, which the shell's own cluster matches.
    expect(data.actions, hasLength(2));
    expect(find.byType(GlassButtonGroup), findsNWidgets(2));
  });

  testWidgets(
      'buttonSize sizes both hoisted and in-route chrome identically (#425)',
      (tester) async {
    Widget buildScreen() => GlassPinnedBarChrome(
          buttonSize: 48,
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              background: GlassBarItemBackground.separate,
              onTap: () {},
            ),
          ],
          builder: (context, chrome) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: chrome.leading,
              actions: chrome.actions,
            ),
          ),
        );

    await tester.pumpWidget(shellApp(buildScreen()));
    await settle(tester);
    final pinnedSize = tester.getSize(inHost(find.byType(GlassButton)).first);
    expect(pinnedSize, const Size(48, 48));

    await tester.pumpWidget(shellApp(buildScreen(), shell: false));
    await settle(tester);
    final inRouteSize = tester.getSize(inBar(find.byType(GlassButtonGroup)));
    expect(inRouteSize, const Size(48, 48));
  });

  group('passive GlassBarItem.custom (#432)', () {
    testWidgets(
      'GlassBarItem.custom without onTap adds no button in-route and forwards taps to child',
      (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await tester.pumpWidget(CupertinoApp(
          home: CupertinoPageScaffold(
            child: GlassAppBar.pinned(
              title: const Text('Title'),
              actions: [
                GlassBarItem.custom(
                  child: CupertinoButton(
                    onPressed: () => taps++,
                    child: const Icon(
                      CupertinoIcons.gear_alt_fill,
                      semanticLabel: 'Settings',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));

        final node = tester.getSemantics(find.bySemanticsLabel('Settings'));
        expect(
          node,
          isSemantics(
            label: 'Settings',
            isButton: true,
            hasTapAction: true,
          ),
        );
        expect(
          node.parent,
          isNot(isSemantics(isButton: true, hasTapAction: true)),
        );
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await tester.tap(find.bySemanticsLabel('Settings'));
        expect(taps, 1);
        handle.dispose();
      },
    );

    testWidgets(
      'GlassBarItem.custom without onTap adds no button when hoisted in GlassNavigationShell and forwards taps to child',
      (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await tester.pumpWidget(CupertinoApp(
          builder: (context, child) => GlassNavigationShell(child: child!),
          home: CupertinoPageScaffold(
            navigationBar: GlassAppBar.pinned(
              title: const Text('Title'),
              actions: [
                GlassBarItem.custom(
                  onTap: null,
                  child: CupertinoButton(
                    onPressed: () => taps++,
                    child: const Icon(
                      CupertinoIcons.gear_alt_fill,
                      semanticLabel: 'Settings',
                    ),
                  ),
                ),
              ],
            ),
            child: const SizedBox.expand(),
          ),
        ));
        await settle(tester);

        expect(inHost(find.bySemanticsLabel('Settings')), findsOneWidget);
        final node = tester.getSemantics(
          inHost(find.bySemanticsLabel('Settings')),
        );
        expect(
          node,
          isSemantics(
            label: 'Settings',
            isButton: true,
            hasTapAction: true,
          ),
        );
        expect(
          node.parent,
          isNot(isSemantics(isButton: true, hasTapAction: true)),
        );
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await tester.tap(inHost(find.bySemanticsLabel('Settings')));
        expect(taps, 1);
        handle.dispose();
      },
    );

    testWidgets(
      'GlassBarItem.custom without onTap with background: none adds no outer button and forwards taps to child',
      (tester) async {
        final handle = tester.ensureSemantics();
        for (final useShell in [false, true]) {
          var taps = 0;
          await tester.pumpWidget(shellApp(
            shell: useShell,
            Scaffold(
              appBar: GlassAppBar.pinned(
                title: const Text('Title'),
                actions: [
                  GlassBarItem.custom(
                    background: GlassBarItemBackground.none,
                    child: CupertinoButton(
                      onPressed: () => taps++,
                      child: const Icon(
                        CupertinoIcons.gear_alt_fill,
                        semanticLabel: 'Settings',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
          await settle(tester);

          final finder = useShell
              ? inHost(find.bySemanticsLabel('Settings'))
              : find.bySemanticsLabel('Settings');
          final node = tester.getSemantics(finder);
          expect(
            node,
            isSemantics(
              label: 'Settings',
              isButton: true,
              hasTapAction: true,
            ),
          );
          expect(
            node.parent,
            isNot(isSemantics(isButton: true, hasTapAction: true)),
          );
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await tester.tap(finder);
          expect(taps, 1);
        }
        handle.dispose();
      },
    );

    testWidgets(
      'labelled passive GlassBarItem.custom exposes exact label without button role or tap action, and dims when disabled',
      (tester) async {
        final handle = tester.ensureSemantics();
        for (final useShell in [false, true]) {
          for (final background in [
            GlassBarItemBackground.shared,
            GlassBarItemBackground.none,
          ]) {
            await tester.pumpWidget(shellApp(
              shell: useShell,
              Scaffold(
                appBar: GlassAppBar.pinned(
                  title: const Text('Title'),
                  actions: [
                    GlassBarItem.custom(
                      label: '3 unread messages',
                      enabled: false,
                      background: background,
                      child: const Text('3'),
                    ),
                  ],
                ),
              ),
            ));
            await settle(tester);

            final finder = useShell
                ? inHost(find.bySemanticsLabel('3 unread messages'))
                : find.bySemanticsLabel('3 unread messages');
            final node = tester.getSemantics(finder);
            expect(node.label, '3 unread messages');
            expect(
              node,
              isNot(isSemantics(isButton: true, hasTapAction: true)),
            );

            final textFinder =
                useShell ? inHost(find.text('3')) : find.text('3');
            final opacityFinder = find.ancestor(
              of: textFinder,
              matching: find.byWidgetPredicate(
                (w) => w is Opacity && w.opacity == 0.5,
              ),
            );
            expect(opacityFinder, findsOneWidget);
          }
        }
        handle.dispose();
      },
    );

    testWidgets(
      'GlassBarItem.custom with onTap still acts as a button',
      (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await tester.pumpWidget(shellApp(
          shell: false,
          Scaffold(
            appBar: GlassAppBar.pinned(
              title: const Text('Title'),
              actions: [
                GlassBarItem.custom(
                  label: 'Inbox',
                  onTap: () => taps++,
                  child: const Text('3'),
                ),
              ],
            ),
          ),
        ));
        await settle(tester);

        final node = tester.getSemantics(find.bySemanticsLabel('Inbox'));
        expect(
          node,
          isSemantics(
            label: 'Inbox',
            isButton: true,
            hasTapAction: true,
          ),
        );
        await tester.tap(find.text('3'));
        expect(taps, 1);
        handle.dispose();
      },
    );

    testWidgets(
      'fitGlassNavStripGroups skips passive custom items in overflow menu',
      (tester) async {
        final groups = groupGlassNavBarItems(
          [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              label: 'Add',
              onTap: () {},
            ),
            const GlassBarItem.custom(
              axisBehavior: GlassBarItemAxisBehavior.verticalPreferred,
              child: Text('Badge'),
            ),
          ],
          axis: Axis.vertical,
        );

        // Tight budget forces the second item into overflow; since it is
        // passive, no empty overflow menu is appended.
        final fitted = fitGlassNavStripGroups(groups, 50.0);
        expect(fitted, hasLength(1));
        expect(fitted.single.items, hasLength(1));
      },
    );

    testWidgets(
      'standalone GlassButtonGroup.icons with passive GlassButtonGroupItem and GlassButton.custom(excludeFromSemantics: true) add no outer button semantics',
      (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await tester.pumpWidget(CupertinoApp(
          home: CupertinoPageScaffold(
            child: Column(
              children: [
                GlassButtonGroup.icons(
                  useOwnLayer: true,
                  items: [
                    GlassButtonGroupItem(
                      icon: CupertinoButton(
                        onPressed: () => taps++,
                        child: const Icon(
                          CupertinoIcons.bell_fill,
                          semanticLabel: 'Notifications',
                        ),
                      ),
                    ),
                  ],
                ),
                GlassButton.custom(
                  useOwnLayer: true,
                  canRequestFocus: false,
                  excludeFromSemantics: true,
                  onTap: () {},
                  child: CupertinoButton(
                    onPressed: () => taps++,
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      semanticLabel: 'Profile',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));

        for (final label in ['Notifications', 'Profile']) {
          final node = tester.getSemantics(find.bySemanticsLabel(label));
          expect(
            node,
            isSemantics(
              label: label,
              isButton: true,
              hasTapAction: true,
            ),
          );
          expect(
            node.parent,
            isNot(isSemantics(isButton: true, hasTapAction: true)),
          );
          await tester.tap(find.bySemanticsLabel(label));
        }
        expect(taps, 2);
        handle.dispose();
      },
    );
  });
}

/// A screen whose bar is a plain Flutter [AppBar] that still pins.
///
/// Mirrors the shape an app with its own design system would use: the items
/// are declared once as data and the resolved slots go straight into the bar.
class _MaterialBarScreen extends StatelessWidget {
  const _MaterialBarScreen({
    required this.title,
    required this.actionIcon,
    this.onBack,
    this.backButton = true,
    this.enabled = true,
    this.horizontalInset,
    this.platformViewBackdrop = false,
    this.buttonSettings,
    this.actionIconSize,
  });

  final String title;
  final IconData actionIcon;
  final double? actionIconSize;
  final VoidCallback? onBack;
  final bool backButton;
  final bool enabled;
  final double? horizontalInset;
  final bool platformViewBackdrop;
  final LiquidGlassSettings? buttonSettings;

  @override
  Widget build(BuildContext context) {
    return GlassPinnedBarChrome(
      actions: [
        GlassBarItem.icon(
          icon: Icon(actionIcon, size: actionIconSize),
          onTap: () {},
        ),
      ],
      backButton: backButton,
      onBack: onBack,
      enabled: enabled,
      horizontalInset: horizontalInset,
      platformViewBackdrop: platformViewBackdrop,
      buttonSettings: buttonSettings,
      builder: (context, chrome) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          leading: chrome.leading,
          actions: chrome.actions,
        ),
        body: Center(child: Text('$title body')),
      ),
    );
  }
}

/// A screen that can drop its [GlassPinnedBarChrome] or disable it in place.
class _TogglingScreen extends StatefulWidget {
  const _TogglingScreen();

  @override
  State<_TogglingScreen> createState() => _TogglingScreenState();
}

class _TogglingScreenState extends State<_TogglingScreen> {
  bool _mounted = true;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => setState(() => _mounted = false),
            child: const Text('drop'),
          ),
          TextButton(
            onPressed: () => setState(() => _enabled = false),
            child: const Text('disable'),
          ),
        ],
      ),
    );

    Widget bar(List<Widget> actions) => Scaffold(
          appBar: AppBar(title: const Text('Inbox'), actions: actions),
          body: body,
        );

    if (!_mounted) return bar(const []);
    return GlassPinnedBarChrome(
      actions: [
        GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
      ],
      enabled: _enabled,
      builder: (context, chrome) => bar(chrome.actions),
    );
  }
}

/// A screen that records every `hoisted` value its builder is handed.
class _RecordingScreen extends StatelessWidget {
  const _RecordingScreen({required this.hoists});

  final List<bool> hoists;

  @override
  Widget build(BuildContext context) {
    return GlassPinnedBarChrome(
      actions: [
        GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: () {}),
      ],
      builder: (context, chrome) {
        hoists.add(chrome.hoisted);
        return const Scaffold(body: SizedBox());
      },
    );
  }
}

class _TwoActionScreen extends StatelessWidget {
  const _TwoActionScreen();

  @override
  Widget build(BuildContext context) {
    return GlassPinnedBarChrome(
      actions: [
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.share),
          onTap: () {},
        ),
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.settings),
          onTap: () {},
        ),
      ],
      backButton: false,
      builder: (context, chrome) => Scaffold(
        appBar: AppBar(
          title: const Text('Title'),
          automaticallyImplyLeading: false,
          actions: chrome.actions,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => const SizedBox(height: 200),
              );
            },
            child: const Text('open sheet'),
          ),
        ),
      ),
    );
  }
}

class _TwoLeadingScreen extends StatelessWidget {
  const _TwoLeadingScreen();

  @override
  Widget build(BuildContext context) {
    return GlassPinnedBarChrome(
      actions: const [],
      leading: [
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.share),
          onTap: () {},
        ),
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.settings),
          onTap: () {},
        ),
      ],
      backButton: false,
      builder: (context, chrome) => Scaffold(
        appBar: AppBar(
          title: const Text('Title'),
          automaticallyImplyLeading: false,
          leadingWidth: 120,
          leading: chrome.leading,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => const SizedBox(height: 200),
              );
            },
            child: const Text('open sheet'),
          ),
        ),
      ),
    );
  }
}
