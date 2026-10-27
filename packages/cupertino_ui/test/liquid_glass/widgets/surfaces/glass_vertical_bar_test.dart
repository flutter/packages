// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/status_bar_row.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_vertical_layout.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/vertical_bar_background.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/vertical_bar_regions.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/glass_nav_pinned_host.dart';

/// iPhone Duo's outer display in portrait, as the iOS 27.1 simulator reports
/// it: a zero top inset, the status bar and the 84pt strip on the right.
const _outerPortrait = Size(466, 678);
const _outerPortraitPadding = EdgeInsets.fromLTRB(0, 0, 84, 34);

/// iPhone Duo's inner display held upright: an 82pt top inset beside the
/// status cluster, and no strip.
const _innerPortrait = Size(669, 951);
const _innerPortraitPadding = EdgeInsets.fromLTRB(0, 82, 0, 34);

/// An occlusion region UIKit reports, as Flutter would surface it.
DisplayFeature _cutout(double left, double top, double right, double bottom) =>
    DisplayFeature(
      bounds: Rect.fromLTRB(left, top, right, bottom),
      type: DisplayFeatureType.cutout,
      state: DisplayFeatureState.unknown,
    );

/// The outer display's regions in portrait, from the 27.1 simulator: the
/// status cluster at the top of the strip, and the camera inside it.
final _outerPortraitRegions = [
  _cutout(399, 29, 436, 66),
  _cutout(382, 0, 466, 170),
];

void main() {
  setUp(() {
    GlassNavigationShellState.debugPinningSupported = true;
  });

  tearDown(() {
    GlassNavigationShellState.debugPinningSupported = null;
    VerticalBarRegions.instance.debugReset();
  });

  /// A widget test on iOS, the only platform that reserves a strip.
  void testDuo(String description, WidgetTesterCallback callback) =>
      testWidgets(
        description,
        callback,
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );

  /// Puts the test view into a posture, restored when the test ends.
  void setScreen(
    WidgetTester tester, {
    Size size = _outerPortrait,
    EdgeInsets padding = _outerPortraitPadding,
  }) {
    const dpr = 3.0;
    tester.view
      ..devicePixelRatio = dpr
      ..physicalSize = size * dpr
      ..viewPadding = FakeViewPadding(
        left: padding.left * dpr,
        top: padding.top * dpr,
        right: padding.right * dpr,
        bottom: padding.bottom * dpr,
      )
      ..padding = FakeViewPadding(
        left: padding.left * dpr,
        top: padding.top * dpr,
        right: padding.right * dpr,
        bottom: padding.bottom * dpr,
      );
    addTearDown(tester.view.reset);
  }

  Widget shellApp(
    Widget home, {
    GlassVerticalBarBehavior behavior = GlassVerticalBarBehavior.automatic,
    GlassVerticalBarCompression compression =
        GlassVerticalBarCompression.automatic,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return CupertinoApp(
      builder: (context, child) => Directionality(
        textDirection: textDirection,
        child: GlassNavigationShell(
          verticalBarBehavior: behavior,
          verticalBarCompression: compression,
          child: child!,
        ),
      ),
      home: home,
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump();
  }

  /// The centre of [icon] as drawn by the shell.
  Offset pinned(WidgetTester tester, IconData icon) => tester.getCenter(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(icon),
        ),
      );

  group('GlassVerticalBar.resolve', () {
    GlassVerticalBarData? resolve({
      EdgeInsets viewPadding = _outerPortraitPadding,
      Size size = _outerPortrait,
      TargetPlatform platform = TargetPlatform.iOS,
      TextDirection textDirection = TextDirection.ltr,
      List<DisplayFeature> displayFeatures = const [],
      GlassVerticalBarEdge? systemEdge,
      GlassVerticalBarCompression compression =
          GlassVerticalBarCompression.automatic,
    }) =>
        GlassVerticalBar.resolve(
          systemEdge: systemEdge,
          viewPadding: viewPadding,
          size: size,
          platform: platform,
          textDirection: textDirection,
          displayFeatures: displayFeatures,
          compression: compression,
        );

    test('finds the strip on the side with the only lateral inset', () {
      final bar = resolve()!;
      expect(bar.edge, GlassVerticalBarEdge.trailing);
      expect(bar.width, 84);
      expect(bar.top, 170);
      expect(bar.bottom, 24);
      expect(bar.collapsesTabBar, isFalse);
    });

    test('keeps the physical side under RTL, where it is the leading edge', () {
      expect(
        resolve(textDirection: TextDirection.rtl)!.edge,
        GlassVerticalBarEdge.leading,
      );
    });

    test('is null with a top inset: inner portrait keeps horizontal bars', () {
      expect(
        resolve(
          viewPadding: const EdgeInsets.fromLTRB(0, 82, 0, 34),
          size: const Size(669, 951),
        ),
        isNull,
      );
    });

    test('is null for a regular iPhone in landscape, inset on both sides', () {
      expect(
        resolve(
          viewPadding: const EdgeInsets.fromLTRB(62, 0, 62, 20),
          size: const Size(874, 402),
        ),
        isNull,
      );
    });

    test('is null off iOS', () {
      expect(resolve(platform: TargetPlatform.android), isNull);
    });

    test('keeps clear of the camera at one end in outer landscape', () {
      const size = Size(678, 466);
      final left = resolve(
        viewPadding: const EdgeInsets.fromLTRB(84, 0, 0, 34),
        size: size,
      )!;
      expect(left.top, 82);
      expect(left.bottom, 24);
      final right = resolve(
        viewPadding: const EdgeInsets.fromLTRB(0, 0, 84, 34),
        size: size,
      )!;
      expect(right.top, 24);
      expect(right.bottom, 82);
    });

    test('starts below the status cluster on the inner display in landscape',
        () {
      final bar = resolve(size: const Size(951, 669))!;
      expect(bar.top, 120);
      expect(bar.bottom, 24);
    });

    test('follows the system to the left in Split View, below the status bar',
        () {
      final bar = resolve(
        viewPadding: const EdgeInsets.fromLTRB(84, 24, 0, 20),
        size: const Size(472, 669),
      )!;
      expect(bar.edge, GlassVerticalBarEdge.leading);
      expect(bar.width, 84);
      expect(bar.top, 24 + 24);
      expect(bar.rowTop, 24 + 24);
      expect(bar.bottom, 24);
      expect(bar.collapsesTabBar, isFalse);
    });

    test('collapses the tab bar as the compression asks', () {
      const landscape = Size(678, 466);
      expect(resolve(size: landscape)!.collapsesTabBar, isTrue);
      expect(
        resolve(
          size: landscape,
          compression: GlassVerticalBarCompression.prefersTabBar,
        )!
            .collapsesTabBar,
        isFalse,
      );
      expect(
        resolve(compression: GlassVerticalBarCompression.prefersBarItems)!
            .collapsesTabBar,
        isTrue,
      );
    });

    test('starts below the status cluster UIKit reports', () {
      expect(resolve(displayFeatures: _outerPortraitRegions)!.top, 170);
      // A live activity grows the cluster; the controls follow it down.
      final grown = resolve(displayFeatures: [_cutout(382, 0, 466, 214)])!;
      expect(grown.top, 214);
      expect(grown.bottom, 24);
    });

    test('keeps clear of the camera region at either end', () {
      const size = Size(678, 466);
      final left = resolve(
        viewPadding: const EdgeInsets.fromLTRB(84, 0, 0, 34),
        size: size,
        displayFeatures: [_cutout(0, 0, 84, 82)],
      )!;
      expect(left.top, 82);
      expect(left.bottom, 24);
      final right = resolve(
        viewPadding: const EdgeInsets.fromLTRB(0, 0, 84, 34),
        size: size,
        displayFeatures: [_cutout(594, 384, 678, 466)],
      )!;
      expect(right.top, 24);
      expect(right.bottom, 82);
    });

    test('ignores regions outside the strip, and folds and hinges', () {
      final bar = resolve(
        size: const Size(951, 669),
        displayFeatures: [
          // The inner display's hinge, and a region on the far side.
          const DisplayFeature(
            bounds: Rect.fromLTRB(455, 0, 495, 669),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
          _cutout(0, 0, 60, 300),
          _cutout(867, 0, 951, 120),
        ],
      )!;
      expect(bar.top, 120);
      expect(bar.bottom, 24);
    });

    test('keeps a strip on the edge UIKit names where it gives no inset', () {
      // The left-hand app in Split View: no lateral inset, no status bar.
      const split = Size(469, 669);
      const padding = EdgeInsets.only(bottom: 34);
      expect(resolve(viewPadding: padding, size: split), isNull);

      final bar = resolve(
        viewPadding: padding,
        size: split,
        systemEdge: GlassVerticalBarEdge.leading,
      )!;
      expect(bar.edge, GlassVerticalBarEdge.leading);
      expect(bar.width, 84);
      expect(bar.systemInset, isFalse);
      // No status cluster or camera in this window's strip.
      expect(bar.top, 24);
      expect(bar.bottom, 24);
    });

    test('follows the insets over the edge where UIKit gives both', () {
      final bar = resolve(systemEdge: GlassVerticalBarEdge.trailing)!;
      expect(bar.systemInset, isTrue);
      expect(bar.top, 170);
    });
  });

  group('GlassNavigationShell', () {
    testDuo('publishes the strip to its subtree', (tester) async {
      setScreen(tester);
      GlassVerticalBarData? seen;
      await tester.pumpWidget(shellApp(Builder(builder: (context) {
        seen = GlassVerticalBar.maybeOf(context);
        return const SizedBox();
      })));
      expect(seen?.edge, GlassVerticalBarEdge.trailing);
    });

    testDuo('follows the regions Flutter reports', (tester) async {
      setScreen(tester);
      tester.view.displayFeatures = [_cutout(382, 0, 466, 214)];
      GlassVerticalBarData? seen;
      await tester.pumpWidget(shellApp(Builder(builder: (context) {
        seen = GlassVerticalBar.maybeOf(context);
        return const SizedBox();
      })));
      expect(seen?.top, 214);
    });

    testDuo('follows the regions UIKit reports while Flutter does not',
        (tester) async {
      setScreen(tester);
      const channel = MethodChannel('liquid_glass_widgets/reserved_regions');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'verticalBarEdge') return null;
        expect(call.method, 'observe');
        return [
          [382.0, 0.0, 466.0, 190.0],
        ];
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      GlassVerticalBarData? seen;
      await tester.pumpWidget(shellApp(Builder(builder: (context) {
        seen = GlassVerticalBar.maybeOf(context);
        return const SizedBox();
      })));
      // The table until UIKit answers.
      expect(seen?.top, 170);
      await tester.pump();
      expect(seen?.top, 190);

      // The cluster grows with a live activity.
      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('didChange', [
          [382.0, 0.0, 466.0, 214.0],
        ])),
        (_) {},
      );
      await tester.pump();
      expect(seen?.top, 214);
    });

    testDuo('publishes the fold UIKit reports, and dialogs avoid it',
        (tester) async {
      setScreen(
        tester,
        size: const Size(951, 669),
        padding: const EdgeInsets.fromLTRB(0, 0, 84, 34),
      );
      const channel = MethodChannel('liquid_glass_widgets/reserved_regions');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'verticalBarEdge') return null;
        // Half folded: the cluster, and the fold the division's margins
        // reach to.
        return [
          [867.0, 0.0, 951.0, 120.0, 0.0],
          [475.0, 0.0, 475.0, 669.0, 1.0],
        ];
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await tester.pump();
      final fold = MediaQuery.displayFeaturesOf(
              tester.element(find.text('Root body')))
          .singleWhere((feature) => feature.type == DisplayFeatureType.hinge);
      expect(fold.bounds, const Rect.fromLTRB(475, 0, 475, 669));
      expect(fold.state, DisplayFeatureState.postureHalfOpened);

      GlassDialog.show<void>(
        context: tester.element(find.text('Root body')),
        title: 'Delete message?',
        actions: [GlassDialogAction(label: 'Delete', onPressed: () {})],
      );
      await settle(tester);
      expect(
        tester.getCenter(find.byType(GlassDialog)).dx,
        closeTo(475 / 2, 0.05),
      );
    });

    testDuo('insets the content for a strip UIKit leaves to the app',
        (tester) async {
      // The left-hand app in Split View: no lateral inset, only the edge.
      setScreen(
        tester,
        size: const Size(469, 669),
        padding: const EdgeInsets.only(bottom: 34),
      );
      const channel = MethodChannel('liquid_glass_widgets/reserved_regions');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'verticalBarEdge' ? 'leading' : [],
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await tester.pump();
      final context = tester.element(find.text('Root body'));
      expect(MediaQuery.paddingOf(context).left, 84);
      expect(MediaQuery.viewPaddingOf(context).left, 84);
      expect(MediaQuery.paddingOf(context).right, 0);
    });

    testDuo('publishes nothing when disabled', (tester) async {
      setScreen(tester);
      GlassVerticalBarEdge? seen = GlassVerticalBarEdge.leading;
      await tester.pumpWidget(shellApp(
        Builder(builder: (context) {
          seen = GlassVerticalBar.edgeOf(context);
          return const SizedBox();
        }),
        behavior: GlassVerticalBarBehavior.disabled,
      ));
      expect(seen, isNull);
    });

    testDuo('publishes nothing on a regular iPhone', (tester) async {
      setScreen(
        tester,
        size: const Size(402, 874),
        padding: const EdgeInsets.fromLTRB(0, 62, 0, 34),
      );
      GlassVerticalBarEdge? seen = GlassVerticalBarEdge.leading;
      await tester.pumpWidget(shellApp(Builder(builder: (context) {
        seen = GlassVerticalBar.edgeOf(context);
        return const SizedBox();
      })));
      expect(seen, isNull);
    });
  });

  group('pinned chrome in the strip', () {
    testDuo('stacks the back button and the groups down the strip',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      _push(
        tester,
        _Screen(title: 'Detail', actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.share),
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.heart),
            onTap: () {},
          ),
        ]),
      );
      await settle(tester);

      // The column is 12pt in from the strip's inner edge at x 382, so its
      // controls are centred at x 406 + 24.
      final back = pinned(tester, CupertinoIcons.back);
      final share = pinned(tester, CupertinoIcons.share);
      final heart = pinned(tester, CupertinoIcons.heart);
      expect(back.dx, closeTo(418, 0.01));
      expect(share.dx, closeTo(418, 0.01));
      expect(heart.dx, closeTo(418, 0.01));

      // The back button is the 48pt circle at y 170; the shared capsule
      // follows 12pt below it, 50pt a slot.
      expect(back.dy, 170 + 24);
      expect(share.dy, 170 + 48 + 12 + 25);
      expect(heart.dy, share.dy + 50);
    });

    testDuo('keeps the title leading in a row at the top', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);

      final title = tester.getRect(find.text('Root'));
      expect(title.left, 20);
      expect(title.center.dy, closeTo(24 + 24, 0.5));
    });

    testDuo('leaves custom content in the horizontal row', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(_Screen(title: 'Root', actions: [
        GlassBarItem.custom(child: const Text('Custom')),
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.bell),
          onTap: () {},
        ),
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.star),
          axisBehavior: GlassBarItemAxisBehavior.horizontalOnly,
          onTap: () {},
        ),
      ])));
      await settle(tester);

      final custom = tester.getRect(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.text('Custom'),
      ));
      final star = pinned(tester, CupertinoIcons.star);
      final bell = pinned(tester, CupertinoIcons.bell);

      // Custom content and the horizontal-only icon share the row at the top
      // of the content, ending against the strip.
      expect(custom.center.dy, closeTo(48, 0.5));
      expect(star.dy, closeTo(48, 0.5));
      expect(star.dx, lessThan(382));
      // The icon goes vertical.
      expect(bell.dx, closeTo(418, 0.01));
      expect(bell.dy, 170 + 24);
    });

    testDuo('verticalPreferred pulls custom content into the strip',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(_Screen(title: 'Root', actions: [
        GlassBarItem.custom(
          child: const SizedBox(width: 20, height: 20, child: Text('3')),
          axisBehavior: GlassBarItemAxisBehavior.verticalPreferred,
        ),
      ])));
      await settle(tester);

      final badge = tester.getCenter(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.text('3'),
      ));
      expect(badge.dx, closeTo(418, 0.5));
      expect(badge.dy, greaterThan(170));
    });

    testDuo('overflows into a ••• menu above a tab bar', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(_TabsScreen(actions: [
        for (final icon in [
          CupertinoIcons.share,
          CupertinoIcons.heart,
          CupertinoIcons.flag,
          CupertinoIcons.bell,
          CupertinoIcons.tag,
        ])
          GlassBarItem.icon(
            icon: Icon(icon),
            label: '$icon',
            background: GlassBarItemBackground.separate,
            onTap: () {},
          ),
      ])));
      await settle(tester);

      // 170 to the tab bar's top at 678 - 24 - 212 = 442, less 12: room for
      // four 48pt circles and their gaps, the last of them the overflow.
      final host = find.byType(GlassNavPinnedHost);
      expect(
        find.descendant(of: host, matching: find.byIcon(CupertinoIcons.share)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: host, matching: find.byIcon(CupertinoIcons.flag)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: host, matching: find.byIcon(CupertinoIcons.bell)),
        findsNothing,
      );
      final more = pinned(tester, CupertinoIcons.ellipsis);
      expect(more.dy + 24, lessThanOrEqualTo(442 - 12));
    });

    testDuo('stays horizontal under GlassVerticalBarBehavior.disabled',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(
        _Screen(title: 'Root', actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.bell),
            onTap: () {},
          ),
        ]),
        behavior: GlassVerticalBarBehavior.disabled,
      ));
      await settle(tester);

      // The bar's own row, at the top of the screen, as before.
      expect(pinned(tester, CupertinoIcons.bell).dy, lessThan(44));
    });

    testDuo('tells a bar drawing its own chrome that the strip is drawn for it',
        (tester) async {
      setScreen(tester);
      final chrome = <GlassPinnedBarChromeData>[];
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      // Kept out of the shell, as a nested navigator's routes are, so the
      // strip is drawn in-route and the chrome is never hoisted.
      _push(
        tester,
        GlassPinnedBarChrome(
          enabled: false,
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.share),
              onTap: () {},
            ),
          ],
          builder: (context, data) {
            chrome.add(data);
            return const SizedBox.expand();
          },
        ),
      );
      await settle(tester);

      expect(chrome.last.hoisted, isFalse);
      expect(chrome.last.inStrip, isTrue);
      expect(chrome.last.leading, isNull);
      expect(chrome.last.actions, isEmpty);
      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
    });

    testDuo('draws the strip in-route against the screen, not the bar',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      // A bar laid out clear of the strip, as one under a SafeArea is.
      _push(
        tester,
        SafeArea(
          child: GlassPinnedBarChrome(
            enabled: false,
            actions: [
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.share),
                onTap: () {},
              ),
            ],
            builder: (context, chrome) => const SizedBox.expand(),
          ),
        ),
      );
      await settle(tester);

      // Where the shell draws them, not 84pt into the content.
      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.back)).dx,
        closeTo(418, 0.01),
      );
      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.share)).dx,
        closeTo(418, 0.01),
      );
    });

    testDuo('redraws the strip for a screen that changed while it was covered',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(GlassPinnedBarChrome(
        enabled: false,
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.share),
            onTap: () {},
          ),
        ],
        builder: (context, chrome) => const SizedBox.expand(),
      )));
      await settle(tester);
      _push(tester, const _Screen(title: 'Covering'));
      await settle(tester);

      // Unfolded to the inner display under the covering route: drawn where
      // it is for a screen that started out that size.
      setScreen(
        tester,
        size: const Size(1040, 720),
        padding: const EdgeInsets.fromLTRB(0, 0, 84, 20),
      );
      await settle(tester);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await settle(tester);

      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.share)).dx,
        closeTo(992, 0.01),
      );
    });

    testDuo('puts the horizontal row where the bar says its header is',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(GlassPinnedBarChrome(
        stripRowTop: 100,
        actions: [
          GlassBarItem.custom(child: const Text('Pro')),
        ],
        builder: (context, chrome) => const SizedBox.expand(),
      )));
      await settle(tester);

      final pro = tester.getCenter(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.text('Pro'),
      ));
      expect(pro.dy, closeTo(100 + 24, 0.5));
    });

    testDuo('stays horizontal and in-route under GlassVerticalBar.disabled',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(GlassVerticalBar.disabled(
        child: _Screen(title: 'Root', actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.bell),
            onTap: () {},
          ),
        ]),
      )));
      await settle(tester);

      // Not handed to the shell, which would pin it in the strip...
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.bell),
        ),
        findsNothing,
      );
      // ...but drawn by the bar, in its horizontal row clear of the strip.
      final bell = tester.getCenter(find.byIcon(CupertinoIcons.bell));
      expect(bell.dx, lessThan(382));
      expect(bell.dy, lessThan(100));
    });
  });

  group('GlassTabBar in the strip', () {
    testDuo('becomes an icon-only capsule at the bottom of the strip',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _TabsScreen()));
      await settle(tester);

      expect(find.byType(TabBarVerticalLayout), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      // Four tabs: 6 + 4 × 50 + 6, ending 24pt above the screen's bottom.
      final profile = tester.getCenter(
        find.byIcon(CupertinoIcons.person_crop_circle),
      );
      expect(profile.dx, closeTo(418, 0.01));
      expect(profile.dy, closeTo(678 - 24 - 6 - 25, 0.01));
    });

    testDuo('selects a tab on a tap', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _TabsScreen()));
      await settle(tester);

      await tester.tap(find.byIcon(CupertinoIcons.book));
      await settle(tester);
      expect(find.text('Library body'), findsOneWidget);
    });

    testDuo('swells under a held finger, then shows the labels',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _TabsScreen()));
      await settle(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(CupertinoIcons.book)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      // Swollen, but no labels yet, and the tab is not selected on touch.
      expect(find.text('Library'), findsNothing);
      expect(find.text('Home body'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Library'), findsWidgets);
      expect(find.text('Home body'), findsOneWidget);

      // Lifting the finger selects the tab under it and hides the labels.
      await gesture.up();
      await settle(tester);
      expect(find.text('Library body'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
    });

    testDuo(
        'shows the labels as soon as a finger drags, and selects where it '
        'lets go', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _TabsScreen()));
      await settle(tester);

      final from = tester.getCenter(find.byIcon(CupertinoIcons.house).first);
      final gesture = await tester.startGesture(from);
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('Home'), findsWidgets);

      final profile = tester.getCenter(
        find.byIcon(CupertinoIcons.person_crop_circle).first,
      );
      await gesture.moveTo(profile);
      await tester.pump();
      await gesture.up();
      await settle(tester);
      expect(find.text('Profile body'), findsOneWidget);
    });

    testDuo('collapses to the selected tab and opens on a tap', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(
        const _TabsScreen(),
        compression: GlassVerticalBarCompression.prefersBarItems,
      ));
      await settle(tester);

      expect(find.byIcon(CupertinoIcons.house), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.book), findsNothing);

      await tester.tap(find.byIcon(CupertinoIcons.house));
      await settle(tester);
      expect(find.byIcon(CupertinoIcons.book), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.book));
      await settle(tester);
      expect(find.text('Library body'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.house), findsNothing);
    });

    testDuo('brings its own layer outside a GlassScaffold', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(
        Stack(
          children: [
            Positioned.fill(
              child: GlassTabBar.bottom(
                quality: GlassQuality.premium,
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const [
                  GlassTab(icon: Icon(CupertinoIcons.house), label: 'Home'),
                  GlassTab(icon: Icon(CupertinoIcons.book), label: 'Library'),
                ],
              ),
            ),
          ],
        ),
      ));
      await settle(tester);

      final capsule = tester.widget<GlassButton>(find.descendant(
        of: find.byType(TabBarVerticalLayout),
        matching: find.byType(GlassButton),
      ));
      expect(capsule.useOwnLayer, isTrue);
    });

    testDuo('stays horizontal on a regular iPhone', (tester) async {
      setScreen(
        tester,
        size: const Size(402, 874),
        padding: const EdgeInsets.fromLTRB(0, 62, 0, 34),
      );
      await tester.pumpWidget(shellApp(const _TabsScreen()));
      await settle(tester);

      expect(find.byType(TabBarVerticalLayout), findsNothing);
      expect(find.text('Home'), findsWidgets);
    });
  });

  group('GlassTabBar.searchable in the strip', () {
    testDuo('puts search in the capsule, after the tabs', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _SearchableTabsScreen()));
      await settle(tester);

      expect(find.byType(TabBarVerticalLayout), findsOneWidget);
      // Four tabs and search: 6 + 5 × 50 + 6, ending 24pt above the bottom.
      final search = tester.getCenter(find.byIcon(CupertinoIcons.search));
      expect(search.dx, closeTo(418, 0.01));
      expect(search.dy, closeTo(678 - 24 - 6 - 25, 0.01));
      final profile = tester.getCenter(
        find.byIcon(CupertinoIcons.person_crop_circle),
      );
      expect(profile.dy, closeTo(search.dy - 50, 0.01));
    });

    testDuo('opens its field across the top of the content', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _SearchableTabsScreen()));
      await settle(tester);
      expect(find.byType(GlassTextField), findsNothing);

      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);

      final field = tester.getRect(find.byType(GlassTextField));
      expect(field.left, 20);
      expect(field.top, 24);
      expect(field.height, 44);
      // Then the ✕, 10pt on, ending at the strip.
      final close = tester.getRect(
        find.ancestor(
          of: find.byIcon(CupertinoIcons.xmark),
          matching: find.byType(GlassButton),
        ),
      );
      expect(close.left, field.right + 10);
      expect(close.right, 466 - 84);
      expect(close.width, 44);
    });

    testDuo('keeps the title beside its field on the inner display',
        (tester) async {
      setScreen(
        tester,
        size: const Size(951, 669),
        padding: const EdgeInsets.fromLTRB(0, 0, 84, 34),
      );
      await tester.pumpWidget(shellApp(const _SearchableTabsScreen()));
      await settle(tester);
      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);

      // A regular width: a 280pt field and a 48pt ✕ at the row's end.
      final field = tester.getRect(find.byType(GlassTextField));
      expect(field.width, 280);
      expect(field.height, 48);
      final close = tester.getRect(
        find.ancestor(
          of: find.byIcon(CupertinoIcons.xmark),
          matching: find.byType(GlassButton),
        ),
      );
      expect(close.left, field.right + 12);
      expect(close.right, 951 - 84);
      expect(close.width, 48);
    });

    testDuo('closes on the ✕ and on choosing a tab', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _SearchableTabsScreen()));
      await settle(tester);

      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);
      await tester.tap(find.byIcon(CupertinoIcons.xmark));
      await settle(tester);
      expect(find.byType(GlassTextField), findsNothing);
      expect(find.text('Home body'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);
      expect(find.text('Search body'), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.book));
      await settle(tester);
      expect(find.byType(GlassTextField), findsNothing);
      expect(find.text('Library body'), findsOneWidget);
    });

    testDuo('leaves search out without its pill', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(
        shellApp(const _SearchableTabsScreen(showPill: false)),
      );
      await settle(tester);

      // The capsule holds the four tabs alone and ends where search would.
      expect(find.byType(TabBarVerticalLayout), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.search), findsNothing);
      final profile = tester.getCenter(
        find.byIcon(CupertinoIcons.person_crop_circle),
      );
      expect(profile.dy, closeTo(678 - 24 - 6 - 25, 0.01));
    });
  });

  group('large titles in the strip', () {
    /// The title the app bar draws in the strip's row.
    Finder rowTitle() => find.descendant(
          of: find.byType(GlassAppBar),
          matching: find.text('Mailboxes'),
        );

    testDuo('lifts the title into the row, at 28pt', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _LargeTitleScreen()));
      await settle(tester);

      expect(find.text('Mailboxes'), findsOneWidget);
      final title = tester.getRect(rowTitle());
      expect(title.left, 20);
      expect(title.center.dy, closeTo(24 + 24, 0.5));
      expect(
        tester
            .widget<RichText>(
              find.descendant(of: rowTitle(), matching: find.byType(RichText)),
            )
            .text
            .style!
            .fontSize,
        28,
      );
      // The content starts below the row, as natively.
      expect(tester.getTopLeft(find.text('Row 0')).dy, 82);
    });

    testDuo('keeps the row against the strip in right to left', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(
        const _LargeTitleScreen(),
        textDirection: TextDirection.rtl,
      ));
      await settle(tester);

      // The strip stays on the right, where the title now starts: it ends
      // against the strip, and the item that stays horizontal crosses to the
      // other side of the content.
      expect(tester.getRect(rowTitle()).right, 466 - 84 - 2);
      expect(pinned(tester, CupertinoIcons.pencil).dx, lessThan(466 / 2));
    });

    testDuo('scrolls the row away with the content', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _LargeTitleScreen()));
      await settle(tester);
      final state = tester.state<_LargeTitleScreenState>(
        find.byType(_LargeTitleScreen),
      );
      final title = tester.getRect(rowTitle());
      final edit = pinned(tester, CupertinoIcons.pencil);

      state.title.scrollController.jumpTo(29);
      await tester.pump();
      expect(tester.getRect(rowTitle()).top, title.top - 29);
      expect(pinned(tester, CupertinoIcons.pencil).dy, edit.dy - 29);
      // The strip itself stays put.
      expect(pinned(tester, CupertinoIcons.add).dy, 170 + 24);

      state.title.scrollController.jumpTo(200);
      await tester.pump();
      final opacities = tester
          .widgetList<Opacity>(
            find.ancestor(of: rowTitle(), matching: find.byType(Opacity)),
          )
          .map((opacity) => opacity.opacity);
      expect(opacities, contains(0.0));
    });

    testDuo('turns its search bar into a magnifier at the bottom of the strip',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(
        shellApp(const _LargeTitleScreen(searchable: true)),
      );
      await settle(tester);

      expect(find.byType(GlassSearchBar), findsNothing);
      final search = tester.getCenter(find.byIcon(CupertinoIcons.search));
      expect(
          search,
          offsetMoreOrLessEquals(
            const Offset(418, 678 - 24 - 24),
            epsilon: 0.01,
          ));
      final shell = tester.state<GlassNavigationShellState>(
        find.byType(GlassNavigationShell),
      );
      expect(shell.verticalBarBottom, 48 + 24);
    });

    testDuo('opens the search along the bottom and hides the bar',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(
        shellApp(const _LargeTitleScreen(searchable: true)),
      );
      await settle(tester);
      final state = tester.state<_LargeTitleScreenState>(
        find.byType(_LargeTitleScreen),
      );

      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);

      expect(state.title.isSearchPresented, isTrue);
      final field = tester.getRect(find.byType(GlassSearchBar));
      expect(field.left, 20);
      expect(field.right, 466 - 84);
      expect(field.bottom, 678 - 24);
      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.xmark)),
        offsetMoreOrLessEquals(
          const Offset(418, 678 - 24 - 24),
          epsilon: 0.01,
        ),
      );
      // The field takes focus as it opens.
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<GlassSearchBar>(),
        isNotNull,
      );
      // The navigation bar hides, and the content moves into its place.
      final hidden = tester
          .widgetList<AnimatedOpacity>(find.ancestor(
            of: find.byIcon(CupertinoIcons.add),
            matching: find.byType(AnimatedOpacity),
          ))
          .map((opacity) => opacity.opacity);
      expect(hidden, contains(0.0));
      expect(tester.getTopLeft(find.text('Row 0')).dy, 24);

      await tester.tap(find.byIcon(CupertinoIcons.xmark));
      await settle(tester);
      expect(state.title.isSearchPresented, isFalse);
      expect(find.byType(GlassSearchBar), findsNothing);
      expect(tester.getTopLeft(find.text('Row 0')).dy, 82);
    });

    testDuo('caps the search field on the inner display', (tester) async {
      setScreen(
        tester,
        size: const Size(951, 669),
        padding: const EdgeInsets.fromLTRB(0, 0, 84, 34),
      );
      await tester.pumpWidget(
        shellApp(const _LargeTitleScreen(searchable: true)),
      );
      await settle(tester);
      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);

      final field = tester.getRect(find.byType(GlassSearchBar));
      expect(field.width, 372);
      expect(field.right, 951 - 84);
    });

    testDuo('closes the search on leaving the strip', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(
        shellApp(const _LargeTitleScreen(searchable: true)),
      );
      await settle(tester);
      final state = tester.state<_LargeTitleScreenState>(
        find.byType(_LargeTitleScreen),
      );
      await tester.tap(find.byIcon(CupertinoIcons.search));
      await settle(tester);
      expect(state.title.isSearchPresented, isTrue);

      // Unfolded to inner portrait, where bars are horizontal.
      setScreen(
        tester,
        size: const Size(669, 951),
        padding: const EdgeInsets.fromLTRB(0, 82, 0, 34),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(state.title.isSearchPresented, isFalse);
      expect(find.byType(GlassSearchBar), findsOneWidget);
    });

    testDuo('stays in the scroll view on a regular iPhone', (tester) async {
      setScreen(
        tester,
        size: const Size(402, 874),
        padding: const EdgeInsets.fromLTRB(0, 62, 0, 34),
      );
      await tester.pumpWidget(
        shellApp(const _LargeTitleScreen(searchable: true)),
      );
      await settle(tester);

      expect(find.text('Mailboxes'), findsNWidgets(2));
      expect(find.byType(GlassSearchBar), findsOneWidget);
    });
  });

  group('the status bar row in inner portrait', () {
    /// The status cluster in the top-right corner, from the 27.1 simulator.
    final cluster = _cutout(535, 0, 669, 82);

    StatusBarRow? resolve({
      Size size = _innerPortrait,
      EdgeInsets viewPadding = _innerPortraitPadding,
      List<DisplayFeature>? displayFeatures,
      TargetPlatform platform = TargetPlatform.iOS,
    }) =>
        StatusBarRow.resolve(
          size: size,
          viewPadding: viewPadding,
          displayFeatures: displayFeatures ?? [cluster],
          platform: platform,
        );

    test('runs from the title inset to just short of the cluster', () {
      final row = resolve()!;
      expect(row.left, 20);
      expect(row.right, 669 - 535 + 2);
      expect(row.top, 24);
      expect(row.bottom, 72);
    });

    test('mirrors for a cluster in the top-left corner', () {
      final row = resolve(displayFeatures: [_cutout(0, 0, 134, 82)])!;
      expect(row.left, 134 + 2);
      expect(row.right, 20);
    });

    test('is null without a cluster as tall as the top inset', () {
      expect(resolve(displayFeatures: const []), isNull);
      // A Dynamic Island stops short of the inset and of both sides.
      expect(
        resolve(
          size: const Size(402, 874),
          viewPadding: const EdgeInsets.fromLTRB(0, 62, 0, 34),
          displayFeatures: [_cutout(138, 11, 264, 48)],
        ),
        isNull,
      );
      // The strip's own cluster leaves no top inset.
      expect(
        resolve(
          size: _outerPortrait,
          viewPadding: _outerPortraitPadding,
          displayFeatures: _outerPortraitRegions,
        ),
        isNull,
      );
    });

    test('is null off iOS', () {
      expect(resolve(platform: TargetPlatform.android), isNull);
    });

    testDuo('lays the pinned chrome and the title out beside the cluster',
        (tester) async {
      setScreen(
        tester,
        size: _innerPortrait,
        padding: _innerPortraitPadding,
      );
      // As on the device: the cluster comes from the package's own reading of
      // UIKit's regions, not from Flutter.
      VerticalBarRegions.instance.value = [cluster];
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);
      _push(
        tester,
        _Screen(title: 'Detail', actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.share),
            onTap: () {},
          ),
        ]),
      );
      await settle(tester);

      // The 44pt back circle starts 20pt in, centred in the row at y 24–72.
      final back = pinned(tester, CupertinoIcons.back);
      expect(back.dx, closeTo(20 + 22, 0.01));
      expect(back.dy, closeTo(48, 0.01));
      // The action ends 2pt short of the cluster at x 535.
      final share = tester.getRect(find.descendant(
        of: find.byType(GlassNavPinnedHost),
        matching: find.byIcon(CupertinoIcons.share),
      ));
      // A capsule is 46pt in the bar's 44pt band, as in any bar.
      expect(share.center.dy, closeTo(48, 1));
      expect(share.right, lessThanOrEqualTo(533));
      // The title leads, beside the back button, in the same row.
      final title = tester.getRect(find.text('Detail'));
      expect(title.center.dy, closeTo(48, 0.5));
      expect(title.left, greaterThan(back.dx + 22));
      expect(title.center.dx, lessThan(669 / 2));
    });

    testDuo('starts the content under the status bar', (tester) async {
      setScreen(
        tester,
        size: _innerPortrait,
        padding: _innerPortraitPadding,
      );
      tester.view.displayFeatures = [cluster];
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);

      // The row sits inside the 82pt inset, so the bar adds nothing below it.
      final effect = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      expect(effect.topFadeHeight, 82 + 20);
    });
  });

  group('GlassScaffold in the strip', () {
    testDuo('drops the bottom fade for a bar that left the bottom edge',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _TabsScreen()));
      await settle(tester);

      final effect = tester.widget<GlassScrollEdgeEffect>(
        find.byType(GlassScrollEdgeEffect),
      );
      expect(effect.fadeBottom, isFalse);
      // The pinned bar's title row, 24pt down and 48pt tall, plus the fade.
      expect(effect.topFadeHeight, 24 + 48 + 20);
    });

    testDuo('shrinks the top fade as a large title scrolls away',
        (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _LargeTitleScreen()));
      await settle(tester);
      final state = tester.state<_LargeTitleScreenState>(
        find.byType(_LargeTitleScreen),
      );
      double fade() => tester
          .widget<GlassScrollEdgeEffect>(find.byType(GlassScrollEdgeEffect))
          .topFadeHeight;

      expect(fade(), 24 + 48 + 20);
      state.title.scrollController.jumpTo(200);
      await tester.pump();
      expect(fade(), 24 + 48 + 20 - 58);
    });
  });

  group('GlassToolbar in the strip', () {
    testDuo('stacks its items at the bottom of the strip', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(GlassScaffold(
        appBar: const GlassAppBar.pinned(title: Text('Detail')),
        bottomBar: GlassToolbar(children: [
          GlassButton(
            icon: const Icon(CupertinoIcons.archivebox),
            width: 48,
            height: 48,
            onTap: () {},
          ),
          const Spacer(),
          GlassButton(
            icon: const Icon(CupertinoIcons.reply),
            width: 48,
            height: 48,
            onTap: () {},
          ),
        ]),
        body: const SizedBox(),
      )));
      await settle(tester);

      final archive = tester.getCenter(find.byIcon(CupertinoIcons.archivebox));
      final reply = tester.getCenter(find.byIcon(CupertinoIcons.reply));
      expect(archive.dx, closeTo(418, 0.01));
      expect(reply.dx, closeTo(418, 0.01));
      expect(reply.dy, 678 - 24 - 24);
      // The spacer collapses to the strip's gap.
      expect(archive.dy, reply.dy - 48 - 12);
    });
  });

  group('GlassModalSheet in the strip', () {
    const innerLandscape = Size(951, 669);
    const innerLandscapePadding = EdgeInsets.fromLTRB(0, 0, 84, 34);

    Future<void> present(
      WidgetTester tester, {
      GlassSheetPlacement placement = GlassSheetPlacement.automatic,
      bool medium = false,
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      await tester.pumpWidget(shellApp(
        const _Screen(title: 'Root'),
        textDirection: textDirection,
      ));
      await settle(tester);
      GlassModalSheet.show<void>(
        context: tester.element(find.text('Root body')),
        initialState: medium ? GlassSheetState.half : GlassSheetState.full,
        detents: medium
            ? const {GlassSheetDetent.medium, GlassSheetDetent.large}
            : const {GlassSheetDetent.large},
        halfSize: 398,
        placement: placement,
        builder: (_) => const _SheetBody(),
      );
      await settle(tester);
    }

    Rect sheet(WidgetTester tester) =>
        tester.getRect(find.byKey(const Key('glass_modal_sheet_fill')));

    testDuo('rises to 8pt from the top and keeps its margins', (tester) async {
      setScreen(tester);
      await present(tester);

      final frame = sheet(tester);
      expect(frame.top, closeTo(8, 0.01));
      expect(frame.left, closeTo(8, 0.05));
      expect(frame.right, closeTo(466 - 8, 0.05));
    });

    testDuo('rests at the width restingWidthOf reports', (tester) async {
      setScreen(tester);
      await present(tester, medium: true);

      expect(
        sheet(tester).width,
        closeTo(
          GlassModalSheet.restingWidthOf(
              tester.element(find.text('Root body'))),
          0.05,
        ),
      );
      expect(sheet(tester).width, closeTo(466 - 2 * 8, 0.05));
    });

    testDuo('reports a card the shorter side wide in a regular width',
        (tester) async {
      setScreen(tester, size: innerLandscape, padding: innerLandscapePadding);
      await present(tester, medium: true);

      expect(
        sheet(tester).width,
        closeTo(
          GlassModalSheet.restingWidthOf(
              tester.element(find.text('Root body'))),
          0.05,
        ),
      );
      expect(sheet(tester).width, closeTo(669 - 2 * 8, 0.05));
    });

    testDuo('moves its bar into its own strip on the outer display',
        (tester) async {
      setScreen(tester);
      await present(tester);

      // Where the screen's strip has its controls: clear of the status
      // cluster, 12pt in from the strip's inner edge at x 382.
      final close = tester.getCenter(find.byIcon(CupertinoIcons.xmark));
      final done = tester.getCenter(find.byIcon(CupertinoIcons.checkmark));
      expect(close.dx, closeTo(418, 0.05));
      expect(close.dy, closeTo(170 + 24, 0.05));
      expect(done.dx, closeTo(418, 0.05));
      expect(done.dy, closeTo(close.dy + 48 + 12, 0.05));
      // The sheet's bar draws it, not the shell's.
      expect(
        find.descendant(
          of: find.byType(GlassNavPinnedHost),
          matching: find.byIcon(CupertinoIcons.xmark),
        ),
        findsNothing,
      );

      // The title stays in a row 16pt in from the sheet's top-leading corner.
      final title = tester.getRect(find.text('New Note'));
      expect(title.left, closeTo(8 + 16, 0.05));
      expect(title.center.dy, closeTo(8 + 16 + 24, 0.5));
    });

    testDuo('starts the strip level with the title row at a medium detent',
        (tester) async {
      setScreen(tester);
      await present(tester, medium: true);

      final top = sheet(tester).top;
      expect(top, closeTo(678 - 398, 0.05));
      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.xmark)).dy,
        closeTo(top + 16 + 24, 0.05),
      );
    });

    testDuo('spans the outer display in landscape', (tester) async {
      setScreen(
        tester,
        size: const Size(678, 466),
        padding: const EdgeInsets.fromLTRB(0, 0, 84, 34),
      );
      await present(tester);

      final frame = sheet(tester);
      expect(frame.left, closeTo(8, 0.05));
      expect(frame.right, closeTo(678 - 8, 0.05));
      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.xmark)).dx,
        closeTo(594 + 12 + 24, 0.05),
      );
    });

    testDuo('is a centred card with a horizontal bar on the inner display',
        (tester) async {
      setScreen(tester, size: innerLandscape, padding: innerLandscapePadding);
      await present(tester);

      // The display's shorter side less 8pt each side.
      final frame = sheet(tester);
      expect(frame.width, closeTo(669 - 16, 0.05));
      expect(frame.center.dx, closeTo(951 / 2, 0.05));
      // The bar stays across the top of the card, its title centred.
      final close = tester.getCenter(find.byIcon(CupertinoIcons.xmark));
      final done = tester.getCenter(find.byIcon(CupertinoIcons.checkmark));
      expect(close.dy, closeTo(done.dy, 0.05));
      expect(close.dx, lessThan(frame.center.dx));
      expect(
        tester.getCenter(find.text('New Note')).dx,
        closeTo(frame.center.dx, 0.5),
      );
    });

    testDuo('docks against the leading edge', (tester) async {
      setScreen(tester, size: innerLandscape, padding: innerLandscapePadding);
      await present(tester, placement: GlassSheetPlacement.leading);

      final frame = sheet(tester);
      expect(frame.left, closeTo(8, 0.05));
      expect(frame.width, closeTo(669 - 16, 0.05));
    });

    testDuo('takes the strip docked against the trailing edge', (tester) async {
      setScreen(tester, size: innerLandscape, padding: innerLandscapePadding);
      await present(tester, placement: GlassSheetPlacement.trailing);

      final frame = sheet(tester);
      expect(frame.right, closeTo(951 - 8, 0.05));
      // Over the strip, where its controls start at y 120.
      final close = tester.getCenter(find.byIcon(CupertinoIcons.xmark));
      expect(close.dx, closeTo(951 - 84 + 12 + 24, 0.05));
      expect(close.dy, closeTo(120 + 24, 0.05));
      expect(tester.getRect(find.text('New Note')).left,
          closeTo(frame.left + 16, 0.05));
    });

    testDuo('keeps a regular iPhone sheet edge to edge', (tester) async {
      setScreen(
        tester,
        size: const Size(402, 874),
        padding: const EdgeInsets.fromLTRB(0, 62, 0, 34),
      );
      await present(tester);

      final frame = sheet(tester);
      expect(frame.left, closeTo(0, 0.05));
      expect(frame.right, closeTo(402, 0.05));
      expect(frame.top, closeTo(90, 0.01));
    });

    testDuo('is a card in one side of a half-folded display', (tester) async {
      setScreen(tester, size: innerLandscape, padding: innerLandscapePadding);
      tester.view.displayFeatures = [
        const DisplayFeature(
          bounds: Rect.fromLTRB(475, 0, 475, 669),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ];
      await present(tester);

      // Natively the card keeps its margins in the left side, 8pt from the
      // top, with its bar across it.
      final frame = sheet(tester);
      expect(frame.left, closeTo(8, 0.05));
      expect(frame.right, closeTo(475 - 8, 0.05));
      expect(frame.top, closeTo(8, 0.01));
      final close = tester.getCenter(find.byIcon(CupertinoIcons.xmark));
      final done = tester.getCenter(find.byIcon(CupertinoIcons.checkmark));
      expect(close.dy, closeTo(done.dy, 0.05));
      expect(
        GlassModalSheet.restingWidthOf(tester.element(find.text('Root body'))),
        closeTo(frame.width, 0.05),
      );

      // It keeps to its side as the keyboard rises.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3.0);
      await settle(tester);
      expect(sheet(tester).left, closeTo(8, 0.05));
      expect(sheet(tester).right, closeTo(475 - 8, 0.05));
    });

    testDuo('takes the side nearest the leading corner right to left',
        (tester) async {
      setScreen(tester, size: innerLandscape, padding: innerLandscapePadding);
      tester.view.displayFeatures = [
        const DisplayFeature(
          bounds: Rect.fromLTRB(475, 0, 475, 669),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ];
      await present(tester, textDirection: TextDirection.rtl);

      final frame = sheet(tester);
      expect(frame.left, closeTo(475 + 8, 0.05));
      expect(frame.right, closeTo(951 - 8, 0.05));
    });
  });

  group('popovers and menus from the strip', () {
    Future<void> openPopover(
      WidgetTester tester, {
      required Offset trigger,
    }) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(Stack(children: [
        Positioned(
          left: trigger.dx,
          top: trigger.dy,
          child: GlassPopover(
            popoverWidth: 282,
            popoverHeight: 68,
            trigger: const SizedBox.square(
              dimension: 48,
              child: ColoredBox(color: CupertinoColors.white),
            ),
            contentBuilder: (context, close) =>
                const SizedBox.expand(key: Key('popover')),
          ),
        ),
      ])));
      await settle(tester);
      await tester.tapAt(trigger + const Offset(24, 24));
      await settle(tester);
    }

    Rect popover(WidgetTester tester) =>
        tester.getRect(find.byKey(const Key('popover')));

    testDuo('opens towards the content, centred on its item', (tester) async {
      await openPopover(tester, trigger: const Offset(394, 230));

      final frame = popover(tester);
      expect(frame.right, closeTo(394 + 48, 0.5));
      expect(frame.center.dy, closeTo(230 + 24, 0.5));
      expect(frame.left, lessThan(382));
    });

    testDuo('hangs from an item anywhere else', (tester) async {
      await openPopover(tester, trigger: const Offset(300, 230));

      expect(popover(tester).top, closeTo(230, 0.5));
    });

    Future<void> openMenu(
      WidgetTester tester, {
      required Offset trigger,
      int items = 3,
    }) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(Stack(children: [
        Positioned(
          left: trigger.dx,
          top: trigger.dy,
          child: GlassMenu(
            autoAdjustToScreen: true,
            trigger: const SizedBox.square(
              dimension: 48,
              child: ColoredBox(color: CupertinoColors.white),
            ),
            items: [
              for (var i = 1; i <= items; i++)
                GlassMenuItem(title: 'Item $i', onTap: () {}),
            ],
          ),
        ),
      ])));
      await settle(tester);
      await tester.tapAt(trigger + const Offset(24, 24));
      await settle(tester);
    }

    Rect item(WidgetTester tester, int i) =>
        tester.getRect(find.byType(GlassMenuItem).at(i - 1));

    testDuo('opens a menu over its item, down from the upper half',
        (tester) async {
      await openMenu(tester, trigger: const Offset(394, 230));

      // Its top and outer edges lie on the item's, inside the menu's 12pt
      // padding, rather than centred on it as a popover is.
      expect(item(tester, 1).top, closeTo(230 + 12, 0.5));
      expect(item(tester, 1).right, closeTo(394 + 48 - 12, 0.5));
    });

    testDuo('opens a menu up from the lower half', (tester) async {
      await openMenu(tester, trigger: const Offset(394, 450));

      expect(item(tester, 3).bottom, closeTo(450 + 48 - 12, 0.5));
    });

    testDuo('keeps a menu clear of the status cluster', (tester) async {
      await openMenu(tester, trigger: const Offset(394, 450), items: 12);

      // Taller than the room above the item: it stops level with the strip's
      // first control, at y 170, and scrolls.
      expect(item(tester, 1).top, closeTo(170 + 12, 0.5));
    });
  });

  group('Reduce Transparency in the strip', () {
    testDuo('gives the strip and the title row an opaque background',
        (tester) async {
      setScreen(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);

      final strip = tester.getRect(find
          .descendant(
            of: find.byType(VerticalBarBackground),
            matching: find.byType(DecoratedBox),
          )
          .last);
      // 5pt into the strip, the full height.
      expect(strip, const Rect.fromLTRB(382 + 5, 0, 466, 678));
      final row = tester.getRect(find
          .descendant(
            of: find.byType(VerticalBarBackground),
            matching: find.byType(DecoratedBox),
          )
          .first);
      // Down to where the content starts, 10pt under the title row.
      expect(row, const Rect.fromLTRB(0, 0, 382 + 5, 24 + 48 + 10));
    });

    testDuo('leaves the strip clear otherwise', (tester) async {
      setScreen(tester);
      await tester.pumpWidget(shellApp(const _Screen(title: 'Root')));
      await settle(tester);

      expect(find.byType(VerticalBarBackground), findsNothing);
    });
  });
}

void _push(WidgetTester tester, Widget screen) {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.push(CupertinoPageRoute<void>(builder: (_) => screen));
}

class _Screen extends StatelessWidget {
  const _Screen({required this.title, this.actions = const []});

  final String title;
  final List<GlassBarItem> actions;

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar.pinned(title: Text(title), actions: actions),
        body: Center(child: Text('$title body')),
      );
}

class _TabsScreen extends StatefulWidget {
  const _TabsScreen({this.actions = const []});

  final List<GlassBarItem> actions;

  @override
  State<_TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<_TabsScreen> {
  static const _titles = ['Home', 'Library', 'Radio', 'Profile'];
  int _tab = 0;

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar.pinned(
          title: const Text('Tabs'),
          actions: widget.actions,
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _tab,
          onTabSelected: (i) => setState(() => _tab = i),
          tabs: const [
            GlassTab(icon: Icon(CupertinoIcons.house), label: 'Home'),
            GlassTab(icon: Icon(CupertinoIcons.book), label: 'Library'),
            GlassTab(
              icon: Icon(CupertinoIcons.dot_radiowaves_left_right),
              label: 'Radio',
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.person_crop_circle),
              label: 'Profile',
            ),
          ],
        ),
        body: Center(child: Text('${_titles[_tab]} body')),
      );
}

class _SearchableTabsScreen extends StatefulWidget {
  const _SearchableTabsScreen({this.showPill = true});

  final bool showPill;

  @override
  State<_SearchableTabsScreen> createState() => _SearchableTabsScreenState();
}

class _SearchableTabsScreenState extends State<_SearchableTabsScreen> {
  static const _titles = ['Home', 'Library', 'Radio', 'Profile'];
  int _tab = 0;
  bool _searching = false;

  @override
  Widget build(BuildContext context) => GlassScaffold(
        bottomBar: GlassTabBar.searchable(
          selectedIndex: _tab,
          onTabSelected: (i) => setState(() => _tab = i),
          isSearchActive: _searching,
          searchConfig: GlassSearchBarConfig(
            onSearchToggle: (active) => setState(() => _searching = active),
            showPill: widget.showPill,
          ),
          tabs: const [
            GlassTab(icon: Icon(CupertinoIcons.house), label: 'Home'),
            GlassTab(icon: Icon(CupertinoIcons.book), label: 'Library'),
            GlassTab(
              icon: Icon(CupertinoIcons.dot_radiowaves_left_right),
              label: 'Radio',
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.person_crop_circle),
              label: 'Profile',
            ),
          ],
        ),
        body: Center(
          child: Text(_searching ? 'Search body' : '${_titles[_tab]} body'),
        ),
      );
}

class _LargeTitleScreen extends StatefulWidget {
  const _LargeTitleScreen({this.searchable = false});

  final bool searchable;

  @override
  State<_LargeTitleScreen> createState() => _LargeTitleScreenState();
}

class _LargeTitleScreenState extends State<_LargeTitleScreen> {
  final title = GlassLargeTitleController();

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar.pinned(
          title: const Text('Mailboxes'),
          largeTitleController: title,
          leading: [
            GlassBarItem.custom(
              child: const Icon(CupertinoIcons.pencil),
              label: 'Edit',
              onTap: () {},
            ),
          ],
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              label: 'Add',
              onTap: () {},
            ),
          ],
        ),
        body: CustomScrollView(
          controller: title.scrollController,
          slivers: [
            GlassLargeTitle(
              text: 'Mailboxes',
              controller: title,
              searchBar:
                  widget.searchable ? const GlassSearchBar(height: 48) : null,
            ),
            SliverList.builder(
              itemCount: 40,
              itemBuilder: (context, i) =>
                  SizedBox(height: 60, child: Text('Row $i')),
            ),
          ],
        ),
      );
}

/// A sheet's own navigation bar: an inline title, cancel and done.
class _SheetBody extends StatelessWidget {
  const _SheetBody();

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar.pinned(
          title: const Text('New Note'),
          leading: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.xmark),
              background: GlassBarItemBackground.separate,
              onTap: () {},
            ),
          ],
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.checkmark),
              background: GlassBarItemBackground.separate,
              onTap: () {},
            ),
          ],
        ),
        body: const SizedBox(),
      );
}
