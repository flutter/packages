// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('FocusRingThemeData copyWith, ==, hashCode basics', () {
    expect(const FocusRingThemeData(), const FocusRingThemeData().copyWith());
    expect(const FocusRingThemeData().hashCode, const FocusRingThemeData().copyWith().hashCode);
    const data = FocusRingThemeData(visible: true, color: Color(0xFF00FF00), width: 2);
    expect(
      data.copyWith(width: 4),
      const FocusRingThemeData(visible: true, color: Color(0xFF00FF00), width: 4),
    );
  });

  test('FocusRingThemeData lerp special cases', () {
    expect(FocusRingThemeData.lerp(null, null, 0), const FocusRingThemeData());
    const data = FocusRingThemeData();
    expect(identical(FocusRingThemeData.lerp(data, data, 0.5), data), true);
  });

  test('FocusRingThemeData lerp', () {
    const a = FocusRingThemeData(visible: false, color: Color(0xFF000000), width: 2);
    const b = FocusRingThemeData(visible: true, color: Color(0xFFFFFFFF), width: 4);
    final FocusRingThemeData middle = FocusRingThemeData.lerp(a, b, 0.5);
    expect(middle.visible, true);
    expect(middle.width, 3);
    expect(middle.color, Color.lerp(a.color, b.color, 0.5));
    expect(FocusRingThemeData.lerp(a, b, 0.25).visible, false);
  });

  test('FocusRingThemeData defaults', () {
    const themeData = FocusRingThemeData();
    expect(themeData.visible, null);
    expect(themeData.color, null);
    expect(themeData.width, null);
    expect(ThemeData().focusRingTheme, const FocusRingThemeData());
  });

  testWidgets('FocusRingThemeData implements debugFillProperties', (WidgetTester tester) async {
    final builder = DiagnosticPropertiesBuilder();
    const FocusRingThemeData(
      visible: true,
      color: Color(0xFF00FF00),
      innerColor: Color(0xFFFFFFFF),
      width: 2,
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[
      'visible: true',
      'color: ${const Color(0xFF00FF00)}',
      'innerColor: ${const Color(0xFFFFFFFF)}',
      'width: 2.0',
    ]);
  });

  group('focus ring painting', () {
    setUp(() {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    });

    tearDown(() {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
    });

    const visibleRing = FocusRingThemeData(visible: true);

    Widget buildApp({required Widget child, FocusRingThemeData? focusRingTheme}) {
      return MaterialApp(
        theme: ThemeData(focusRingTheme: focusRingTheme),
        home: Scaffold(body: Center(child: child)),
      );
    }

    // The InkResponse's render object is the topmost box of its subtree, which
    // is where the ring is painted. Subclasses such as InkWell count too.
    RenderBox inkWellBox(WidgetTester tester, Finder ancestor) {
      return tester.renderObject<RenderBox>(
        find
            .descendant(
              of: ancestor,
              matching: find.byWidgetPredicate((Widget widget) => widget is InkResponse),
            )
            .first,
      );
    }

    testWidgets('No ring is drawn unless the theme makes it visible', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          child: TextButton(focusNode: focusNode, onPressed: () {}, child: const Text('Submit')),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(focusNode.hasPrimaryFocus, isTrue);
      expect(
        inkWellBox(tester, find.byType(TextButton)),
        isNot(paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0)),
      );
    });

    testWidgets('Button draws the ring 2 pixels outside its shape', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: TextButton(
            style: TextButton.styleFrom(shape: const StadiumBorder()),
            focusNode: focusNode,
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(TextButton));
      final Rect rect = Offset.zero & box.size;
      final ColorScheme scheme = Theme.of(tester.element(find.byType(TextButton))).colorScheme;
      final shape = RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2));
      // The ring covers 2 to 5 pixels outside the edge, so its 3 pixel stroke
      // is centered 3.5 pixels out. The default inner band covers the 3
      // pixels just inside it, centered 0.5 pixels out.
      expect(
        box,
        paints
          ..rrect(
            rrect: shape.inflate(0.5),
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
            color: scheme.onSecondary,
          )
          ..rrect(
            rrect: shape.inflate(3.5),
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
            color: scheme.secondary,
          ),
      );
    });

    testWidgets('Ring is drawn the same way on every platform', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: TextButton(
            style: TextButton.styleFrom(shape: const StadiumBorder()),
            focusNode: focusNode,
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(TextButton));
      final Rect rect = Offset.zero & box.size;
      final shape = RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2));
      expect(
        box,
        paints
          ..rrect(rrect: shape.inflate(0.5), style: PaintingStyle.stroke, strokeWidth: 3.0)
          ..rrect(rrect: shape.inflate(3.5), style: PaintingStyle.stroke, strokeWidth: 3.0),
      );

      // A pointer interaction hides the ring on every platform too.
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
      await tester.pumpAndSettle();
      expect(box, isNot(paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0)));
    }, variant: TargetPlatformVariant.all());

    testWidgets('List tile draws the ring inside its edge', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: SizedBox(
            width: 300,
            child: ListTile(focusNode: focusNode, onTap: () {}, title: const Text('Item')),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(ListTile));
      final Rect rect = Offset.zero & box.size;
      // The ring covers the 3 pixels just inside the edge, and the inner band
      // the next 3 pixels.
      expect(
        box,
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(rect.deflate(4.5), Radius.zero),
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
          )
          ..rrect(
            rrect: RRect.fromRectAndRadius(rect.deflate(1.5), Radius.zero),
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
          ),
      );
    });

    testWidgets('InkWell without an offset draws the ring inside its shape', (
      WidgetTester tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      const borderRadius = BorderRadius.all(Radius.circular(8));
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: Material(
            child: InkWell(
              focusNode: focusNode,
              borderRadius: borderRadius,
              onTap: () {},
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = tester.renderObject<RenderBox>(find.byType(InkWell));
      final RRect shape = borderRadius.toRRect(Offset.zero & box.size);
      expect(
        box,
        paints
          ..rrect(rrect: shape.deflate(4.5), style: PaintingStyle.stroke, strokeWidth: 3.0)
          ..rrect(rrect: shape.deflate(1.5), style: PaintingStyle.stroke, strokeWidth: 3.0),
      );
    });

    testWidgets('Circular InkResponse draws circular rings', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: Material(
            child: InkResponse(
              focusNode: focusNode,
              radius: 20,
              onTap: () {},
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = tester.renderObject<RenderBox>(find.byType(InkResponse));
      final Offset center = (Offset.zero & box.size).center;
      // With no offset, the ring covers the 3 pixels inside the 20 pixel
      // radius and the inner band the 3 pixels inside that.
      expect(
        box,
        paints
          ..circle(x: center.dx, y: center.dy, radius: 15.5, style: PaintingStyle.stroke)
          ..circle(x: center.dx, y: center.dy, radius: 18.5, style: PaintingStyle.stroke),
      );
    });

    testWidgets('Other shapes are stroked along their outer path', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: Material(
            child: InkWell(
              focusNode: focusNode,
              customBorder: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              onTap: () {},
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(
        tester.renderObject<RenderBox>(find.byType(InkWell)),
        paints
          ..path(style: PaintingStyle.stroke, strokeWidth: 3.0)
          ..path(style: PaintingStyle.stroke, strokeWidth: 3.0),
      );
    });

    testWidgets('Skips bands that would invert on a tiny widget', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: Material(
            child: InkWell(
              focusNode: focusNode,
              onTap: () {},
              child: const SizedBox(width: 4, height: 4),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = tester.renderObject<RenderBox>(find.byType(InkWell));
      // The ring, centered 1.5 pixels in, still fits in 4 pixels. The inner
      // band, centered 4.5 pixels in, would be inverted, so it is skipped.
      expect(
        box,
        paints..rrect(
          rrect: RRect.fromRectAndRadius((Offset.zero & box.size).deflate(1.5), Radius.zero),
          style: PaintingStyle.stroke,
        ),
      );
      expect(box, paintsExactlyCountTimes(#drawRRect, 1));
    });

    testWidgets('Ring uses the theme color and width', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      const ringColor = Color(0xFF00897B);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: const FocusRingThemeData(visible: true, color: ringColor, width: 2),
          child: SizedBox(
            width: 300,
            child: ListTile(focusNode: focusNode, onTap: () {}, title: const Text('Item')),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(ListTile));
      final Rect rect = Offset.zero & box.size;
      // The list item offset is -3, so a 2 pixel ring spans 3 to 1 pixels
      // inside the edge, centered 2 pixels in. The inner band spans 5 to 3
      // pixels inside, centered 4 pixels in.
      expect(
        box,
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(rect.deflate(4), Radius.zero),
            style: PaintingStyle.stroke,
            strokeWidth: 2.0,
          )
          ..rrect(
            rrect: RRect.fromRectAndRadius(rect.deflate(2), Radius.zero),
            style: PaintingStyle.stroke,
            strokeWidth: 2.0,
            color: ringColor,
          ),
      );
    });

    testWidgets('Transparent inner color draws the ring alone', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      const ringColor = Color(0xFF00897B);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: const FocusRingThemeData(
            visible: true,
            color: ringColor,
            innerColor: Colors.transparent,
          ),
          child: SizedBox(
            width: 300,
            child: ListTile(focusNode: focusNode, onTap: () {}, title: const Text('Item')),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(ListTile));
      final Rect rect = Offset.zero & box.size;
      expect(
        box,
        paints..rrect(
          rrect: RRect.fromRectAndRadius(rect.deflate(1.5), Radius.zero),
          style: PaintingStyle.stroke,
          strokeWidth: 3.0,
          color: ringColor,
        ),
      );
      expect(box, paintsExactlyCountTimes(#drawRRect, 1));
    });

    testWidgets('Inner color draws a second band inside the ring', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      const ringColor = Color(0xFF000000);
      const bandColor = Color(0xFFFFFFFF);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: const FocusRingThemeData(
            visible: true,
            color: ringColor,
            innerColor: bandColor,
          ),
          child: SizedBox(
            width: 300,
            child: ListTile(focusNode: focusNode, onTap: () {}, title: const Text('Item')),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(ListTile));
      final Rect rect = Offset.zero & box.size;
      // The ring covers 0 to 3 pixels inside the edge and the band covers the
      // next 3 pixels, 3 to 6 pixels inside.
      expect(
        box,
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(rect.deflate(4.5), Radius.zero),
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
            color: bandColor,
          )
          ..rrect(
            rrect: RRect.fromRectAndRadius(rect.deflate(1.5), Radius.zero),
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
            color: ringColor,
          ),
      );
    });

    testWidgets('FocusRingTheme overrides ThemeData.focusRingTheme', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          child: FocusRingTheme(
            data: visibleRing,
            child: TextButton(focusNode: focusNode, onPressed: () {}, child: const Text('Submit')),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(
        inkWellBox(tester, find.byType(TextButton)),
        paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0),
      );
    });

    testWidgets('No ring in touch highlight mode', (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: TextButton(focusNode: focusNode, onPressed: () {}, child: const Text('Submit')),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(focusNode.hasPrimaryFocus, isTrue);
      expect(
        inkWellBox(tester, find.byType(TextButton)),
        isNot(paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0)),
      );
    });

    testWidgets('Ring goes away when focus leaves', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: TextButton(focusNode: focusNode, onPressed: () {}, child: const Text('Submit')),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();
      final RenderBox box = inkWellBox(tester, find.byType(TextButton));
      expect(box, paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0));

      focusNode.unfocus();
      await tester.pumpAndSettle();
      expect(box, isNot(paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0)));
    });

    testWidgets('Navigation bar draws the ring on the focused destination', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(focusRingTheme: visibleRing),
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.business), label: 'Business'),
              ],
            ),
          ),
        ),
      );
      final Finder business = find.widgetWithText(NavigationDestination, 'Business');
      Focus.of(tester.element(find.text('Business'))).requestFocus();
      await tester.pumpAndSettle();

      expect(
        inkWellBox(tester, business),
        paints..rrect(style: PaintingStyle.stroke, strokeWidth: 3.0),
      );
    });

    // Whether a call is a 3 pixel ring stroke that reaches outside `bounds`.
    bool ringReachesOutside(Symbol method, List<dynamic> arguments, Rect bounds) {
      final Object? last = arguments.isEmpty ? null : arguments.last;
      if (last is! Paint || last.style != PaintingStyle.stroke || last.strokeWidth != 3.0) {
        return false;
      }
      final Rect? centerline = switch (method) {
        #drawRRect => (arguments[0] as RRect).outerRect,
        #drawPath => (arguments[0] as Path).getBounds(),
        #drawCircle => Rect.fromCircle(
          center: arguments[0] as Offset,
          radius: arguments[1] as double,
        ),
        _ => null,
      };
      if (centerline == null) {
        return false;
      }
      final Rect stroke = centerline.inflate(1.5);
      const tolerance = 0.01;
      return stroke.left < bounds.left - tolerance ||
          stroke.top < bounds.top - tolerance ||
          stroke.right > bounds.right + tolerance ||
          stroke.bottom > bounds.bottom + tolerance;
    }

    // Expects `box` to paint a ring that stays inside its own bounds.
    void expectRingInside(RenderBox box) {
      expect(
        box,
        paints..something((Symbol method, List<dynamic> arguments) {
          final Object? last = arguments.isEmpty ? null : arguments.last;
          return last is Paint && last.style == PaintingStyle.stroke && last.strokeWidth == 3.0;
        }),
      );
      final Rect bounds = Offset.zero & box.size;
      expect(
        box,
        isNot(
          paints..something(
            (Symbol method, List<dynamic> arguments) =>
                ringReachesOutside(method, arguments, bounds),
          ),
        ),
      );
    }

    testWidgets('Button that clips draws the ring inside its shape', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: TextButton(
            // A background builder makes the button clip to its shape.
            style: ButtonStyle(
              backgroundBuilder: (BuildContext context, Set<WidgetState> states, Widget? child) =>
                  child!,
            ),
            focusNode: focusNode,
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expectRingInside(inkWellBox(tester, find.byType(TextButton)));
    });

    testWidgets('Chip that clips draws the ring inside its shape', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: ActionChip(
            clipBehavior: Clip.antiAlias,
            focusNode: focusNode,
            onPressed: () {},
            label: const Text('Chip'),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expectRingInside(inkWellBox(tester, find.byType(ActionChip)));
    });

    testWidgets('ToggleButtons draw the ring inside each button', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final otherFocusNode = FocusNode();
      addTearDown(otherFocusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: ToggleButtons(
            isSelected: const <bool>[false, false],
            focusNodes: <FocusNode>[focusNode, otherFocusNode],
            onPressed: (int index) {},
            children: const <Widget>[Icon(Icons.home), Icon(Icons.business)],
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expectRingInside(inkWellBox(tester, find.widgetWithIcon(TextButton, Icons.home)));
    });

    testWidgets('SegmentedButton draws the ring inside each segment', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 1, label: Text('One')),
              ButtonSegment<int>(value: 2, label: Text('Two')),
            ],
            selected: const <int>{1},
            onSelectionChanged: (Set<int> selection) {},
          ),
        ),
      );
      Focus.of(tester.element(find.text('Two'))).requestFocus();
      await tester.pumpAndSettle();

      expectRingInside(inkWellBox(tester, find.widgetWithText(TextButton, 'Two')));
    });

    testWidgets('MenuItemButton draws the ring inside its shape', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: MenuItemButton(focusNode: focusNode, onPressed: () {}, child: const Text('Item')),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expectRingInside(inkWellBox(tester, find.byType(MenuItemButton)));
    });

    testWidgets('FloatingActionButton draws the ring outside its shape', (
      WidgetTester tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: FloatingActionButton(
            focusNode: focusNode,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(FloatingActionButton));
      final Rect bounds = Offset.zero & box.size;
      expect(
        box,
        paints..something(
          (Symbol method, List<dynamic> arguments) => ringReachesOutside(method, arguments, bounds),
        ),
      );
    });

    testWidgets('An oval border gets an oval ring', (WidgetTester tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: SizedBox(
            width: 200,
            height: 40,
            child: InkWell(
              focusNode: focusNode,
              onTap: () {},
              customBorder: const OvalBorder(),
              focusRingOffset: 2.0,
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final RenderBox box = inkWellBox(tester, find.byType(SizedBox).last);
      expect(box, isNot(paints..circle(style: PaintingStyle.stroke)));
      // The ring follows the oval, so it passes near the ends of the long axis,
      // which a circle of the short side's diameter would not reach.
      expect(
        box,
        paints
          ..path(style: PaintingStyle.stroke, strokeWidth: 3.0)
          ..path(
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
            includes: const <Offset>[Offset(100, 20), Offset(5, 20)],
          ),
      );
    });

    testWidgets('A beveled border keeps both bands parallel at the corners', (
      WidgetTester tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildApp(
          focusRingTheme: visibleRing,
          child: SizedBox(
            width: 200,
            height: 40,
            child: InkWell(
              focusNode: focusNode,
              onTap: () {},
              customBorder: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusRingOffset: 2.0,
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // The ring's centerline is 3.5 pixels outside the shape, so its corner
      // cut is the line x + y = 10 - 3.5 * sqrt(2), about 5.05, in the box's
      // coordinates. Keeping the bevel's radius at 10 would put the cut at
      // x + y = 3, and fill the point below.
      const corner = Offset(1.9, 1.9);
      expect(
        inkWellBox(tester, find.byType(SizedBox).last),
        paints
          ..path(style: PaintingStyle.stroke, strokeWidth: 3.0)
          ..path(
            style: PaintingStyle.stroke,
            strokeWidth: 3.0,
            includes: const <Offset>[Offset(100, 20)],
            excludes: const <Offset>[corner],
          ),
      );
    });
  });
}
