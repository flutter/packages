// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show PointerDeviceKind, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show RendererBinding;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('DrawerButton control test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DrawerButton(), drawer: Drawer()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);

    await tester.tap(find.byType(DrawerButton));

    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('DrawerButton onPressed overrides default end drawer open behaviour', (
    WidgetTester tester,
  ) async {
    var customCallbackWasCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: DrawerButton(onPressed: () => customCallbackWasCalled = true)),
          drawer: const Drawer(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing); // Start off with a closed drawer
    expect(customCallbackWasCalled, false); // customCallbackWasCalled should still be false.
    await tester.tap(find.byType(DrawerButton));

    await tester.pumpAndSettle();

    // Drawer is still closed
    expect(find.byType(Drawer), findsNothing);
    // The custom callback is called, setting customCallbackWasCalled to true.
    expect(customCallbackWasCalled, true);
  });

  testWidgets('DrawerButton icon', (WidgetTester tester) async {
    final Key androidKey = UniqueKey();
    final Key iOSKey = UniqueKey();
    final Key linuxKey = UniqueKey();
    final Key macOSKey = UniqueKey();
    final Key windowsKey = UniqueKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: <Widget>[
            Theme(
              data: ThemeData(platform: TargetPlatform.android),
              child: DrawerButtonIcon(key: androidKey),
            ),
            Theme(
              data: ThemeData(platform: TargetPlatform.iOS),
              child: DrawerButtonIcon(key: iOSKey),
            ),
            Theme(
              data: ThemeData(platform: TargetPlatform.linux),
              child: DrawerButtonIcon(key: linuxKey),
            ),
            Theme(
              data: ThemeData(platform: TargetPlatform.macOS),
              child: DrawerButtonIcon(key: macOSKey),
            ),
            Theme(
              data: ThemeData(platform: TargetPlatform.windows),
              child: DrawerButtonIcon(key: windowsKey),
            ),
          ],
        ),
      ),
    );

    final Icon androidIcon = tester.widget(
      find.descendant(of: find.byKey(androidKey), matching: find.byType(Icon)),
    );
    final Icon iOSIcon = tester.widget(
      find.descendant(of: find.byKey(iOSKey), matching: find.byType(Icon)),
    );
    final Icon linuxIcon = tester.widget(
      find.descendant(of: find.byKey(linuxKey), matching: find.byType(Icon)),
    );
    final Icon macOSIcon = tester.widget(
      find.descendant(of: find.byKey(macOSKey), matching: find.byType(Icon)),
    );
    final Icon windowsIcon = tester.widget(
      find.descendant(of: find.byKey(windowsKey), matching: find.byType(Icon)),
    );

    // All icons for drawer are the same
    expect(iOSIcon.icon == androidIcon.icon, isTrue);
    expect(linuxIcon.icon == androidIcon.icon, isTrue);
    expect(macOSIcon.icon == androidIcon.icon, isTrue);
    expect(windowsIcon.icon == androidIcon.icon, isTrue);
  });

  testWidgets('DrawerButton color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(child: DrawerButton(color: Colors.red)),
      ),
    );

    final RichText iconText = tester.firstWidget(
      find.descendant(of: find.byType(DrawerButton), matching: find.byType(RichText)),
    );
    expect(iconText.text.style!.color, Colors.red);
  });

  testWidgets('DrawerButton color with ButtonStyle', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: DrawerButton(
            style: ButtonStyle(iconColor: MaterialStatePropertyAll<Color>(Colors.red)),
          ),
        ),
      ),
    );

    final RichText iconText = tester.firstWidget(
      find.descendant(of: find.byType(DrawerButton), matching: find.byType(RichText)),
    );
    expect(iconText.text.style!.color, Colors.red);
  });

  testWidgets('DrawerButton semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(child: Center(child: DrawerButton())),
      ),
    );

    await tester.pumpAndSettle();

    final String? expectedLabel;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        expectedLabel = 'Open navigation menu';
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        expectedLabel = null;
    }
    expect(
      tester.getSemantics(find.byType(DrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        label: expectedLabel,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: defaultTargetPlatform != TargetPlatform.iOS,
        isFocusable: true,
      ),
    );
    handle.dispose();
  }, variant: TargetPlatformVariant.all());

  testWidgets('DrawerButton and EndDrawerButton semantics reflect Scaffold drawer open state', (
    WidgetTester tester,
  ) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(),
          drawer: const Drawer(),
          endDrawer: const Drawer(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially closed: both AppBar buttons report collapsed (hasExpandedState: true, isExpanded: false).
    expect(
      tester.getSemantics(find.byType(DrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(EndDrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    // Open start drawer: DrawerButton reports expanded; EndDrawerButton stays collapsed.
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(DrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(EndDrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    // Close start drawer: DrawerButton reports collapsed again.
    scaffoldKey.currentState!.closeDrawer();
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(DrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    // Open end drawer: EndDrawerButton reports expanded; DrawerButton stays collapsed.
    scaffoldKey.currentState!.openEndDrawer();
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(EndDrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(DrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    // Close end drawer: EndDrawerButton reports collapsed again.
    scaffoldKey.currentState!.closeEndDrawer();
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(EndDrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
  }, tags: 'reduced-web-test-set');

  testWidgets(
    'DrawerButton and EndDrawerButton update semantics when built while open or when drawer presence changes',
    (WidgetTester tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();

      Widget buildScaffold({
        required bool showAppBar,
        required bool hasDrawer,
        required bool hasEndDrawer,
      }) {
        return MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            appBar: showAppBar ? AppBar() : null,
            body: const Column(children: <Widget>[DrawerButton(), EndDrawerButton()]),
            drawer: hasDrawer ? const Drawer() : null,
            endDrawer: hasEndDrawer ? const Drawer() : null,
          ),
        );
      }

      // Start without drawers: neither body button exposes expanded state.
      await tester.pumpWidget(
        buildScaffold(showAppBar: false, hasDrawer: false, hasEndDrawer: false),
      );
      await tester.pumpAndSettle();
      expect(
        tester.semantics.find(find.byType(DrawerButton)).flagsCollection.isExpanded,
        Tristate.none,
      );
      expect(
        tester.semantics.find(find.byType(EndDrawerButton)).flagsCollection.isExpanded,
        Tristate.none,
      );

      // Dynamically add drawers: const body buttons rebuild to report collapsed (Tristate.isFalse).
      await tester.pumpWidget(
        buildScaffold(showAppBar: false, hasDrawer: true, hasEndDrawer: true),
      );
      await tester.pumpAndSettle();
      expect(
        tester.semantics.find(find.byType(DrawerButton)).flagsCollection.isExpanded,
        Tristate.isFalse,
      );
      expect(
        tester.semantics.find(find.byType(EndDrawerButton)).flagsCollection.isExpanded,
        Tristate.isFalse,
      );

      // Open drawer, mount AppBar while open (so AppBar's DrawerButton builds with isDrawerOpen == true),
      // then close drawer and verify AppBar's DrawerButton transitions to collapsed.
      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();
      await tester.pumpWidget(buildScaffold(showAppBar: true, hasDrawer: true, hasEndDrawer: true));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.closeDrawer();
      await tester.pumpAndSettle();

      final Finder appBarDrawerButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(DrawerButton),
      );
      expect(
        tester.semantics.find(appBarDrawerButton).flagsCollection.isExpanded,
        Tristate.isFalse,
      );
    },
    tags: 'reduced-web-test-set',
  );

  testWidgets('EndDrawerButton control test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EndDrawerButton(), endDrawer: Drawer()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);

    await tester.tap(find.byType(EndDrawerButton));

    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('EndDrawerButton semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(child: Center(child: EndDrawerButton())),
      ),
    );

    await tester.pumpAndSettle();
    final String? expectedLabel;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        expectedLabel = 'Open navigation menu';
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        expectedLabel = null;
    }
    expect(
      tester.getSemantics(find.byType(EndDrawerButton)),
      matchesSemantics(
        tooltip: 'Open navigation menu',
        label: expectedLabel,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: defaultTargetPlatform != TargetPlatform.iOS,
        isFocusable: true,
      ),
    );
    handle.dispose();
  }, variant: TargetPlatformVariant.all());

  testWidgets('EndDrawerButton color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(child: EndDrawerButton(color: Colors.red)),
      ),
    );

    final RichText iconText = tester.firstWidget(
      find.descendant(of: find.byType(EndDrawerButton), matching: find.byType(RichText)),
    );
    expect(iconText.text.style!.color, Colors.red);
  });

  testWidgets('EndDrawerButton color with ButtonStyle', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: EndDrawerButton(
            style: ButtonStyle(iconColor: MaterialStatePropertyAll<Color>(Colors.red)),
          ),
        ),
      ),
    );

    final RichText iconText = tester.firstWidget(
      find.descendant(of: find.byType(EndDrawerButton), matching: find.byType(RichText)),
    );
    expect(iconText.text.style!.color, Colors.red);
  });

  testWidgets('EndDrawerButton onPressed overrides default end drawer open behaviour', (
    WidgetTester tester,
  ) async {
    var customCallbackWasCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: EndDrawerButton(onPressed: () => customCallbackWasCalled = true)),
          endDrawer: const Drawer(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing); // Start off with a closed drawer
    expect(customCallbackWasCalled, false); // customCallbackWasCalled should still be false.
    await tester.tap(find.byType(EndDrawerButton));

    await tester.pumpAndSettle();

    // Drawer is still closed
    expect(find.byType(Drawer), findsNothing);
    // The custom callback is called, setting customCallbackWasCalled to true.
    expect(customCallbackWasCalled, true);
  });

  testWidgets('DrawerButton has expected default mouse cursor on hover', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Material(child: DrawerButton())));

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(1000, 1000));
    addTearDown(gesture.removePointer);

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.basic,
    );

    await gesture.moveTo(tester.getCenter(find.byType(DrawerButton)));
    await tester.pumpAndSettle();

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      kIsWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
    );
  }, tags: 'reduced-web-test-set');

  testWidgets('EndDrawerButton has expected default mouse cursor on hover', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Material(child: EndDrawerButton())));

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(1000, 1000));
    addTearDown(gesture.removePointer);

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.basic,
    );

    await gesture.moveTo(tester.getCenter(find.byType(EndDrawerButton)));
    await tester.pumpAndSettle();

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      kIsWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
    );
  }, tags: 'reduced-web-test-set');

  testWidgets('DrawerButton has expected mouse cursor when explicitly configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DrawerButton(
            style: ButtonStyle(
              mouseCursor: WidgetStateProperty.all<MouseCursor>(SystemMouseCursors.cell),
            ),
          ),
        ),
      ),
    );

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.byType(DrawerButton)));
    addTearDown(gesture.removePointer);

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.cell,
    );
  });

  testWidgets('EndDrawerButton has expected mouse cursor when explicitly configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: EndDrawerButton(
            style: ButtonStyle(
              mouseCursor: WidgetStateProperty.all<MouseCursor>(SystemMouseCursors.cell),
            ),
          ),
        ),
      ),
    );

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.byType(EndDrawerButton)));
    addTearDown(gesture.removePointer);

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.cell,
    );
  });

  testWidgets('DrawerButton does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.shrink(child: Scaffold(body: DrawerButton())),
        ),
      ),
    );
    expect(tester.getSize(find.byType(DrawerButton)), Size.zero);
  });
}
