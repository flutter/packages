// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_materialize_scope.dart';

// Public widget geometry, normalized to a 200pt root menu. Native reference:
// Forage #447: 416px root/card width, 404px receded parent, same centre,
// source row aligned to the bold card header, parent rows at 50% opacity.
Finder surfaceFor(Finder row) =>
    find.ancestor(of: row, matching: find.byType(GlassContainer)).first;
Rect paintedRect(WidgetTester tester, Finder finder) =>
    Rect.fromPoints(tester.getTopLeft(finder), tester.getBottomRight(finder));
Finder header(int depth) => find.byKey(ValueKey('glass-menu-header-$depth'));

Widget host(
  GlassMenuController controller, {
  GlassMenuAlignment alignment = GlassMenuAlignment.topLeft,
  void Function(int, double)? onLevelChanged,
  List<Widget>? items,
  bool reduceMotion = false,
  double? maxStackHeight,
}) =>
    MaterialApp(
        home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
          body: Stack(children: [
        Positioned(
          left: 300,
          top: alignment == GlassMenuAlignment.topLeft ? 60 : 480,
          child: GlassMenu(
            controller: controller,
            menuAlignment: alignment,
            quality: GlassQuality.minimal,
            stretch: 0,
            interactionScale: 1,
            onLevelChanged: onLevelChanged,
            maxStackHeight: maxStackHeight,
            trigger: const SizedBox(width: 8, height: 8),
            items: items ??
                [
                  GlassMenuItem(title: 'Open', onTap: () {}),
                  GlassMenuItem(title: 'Favorite', onTap: () {}),
                  const GlassMenuDivider(),
                  GlassMenuItem(
                      title: 'Share',
                      icon: const Icon(CupertinoIcons.share),
                      onTap: () {},
                      submenu: [
                        GlassMenuItem(title: 'Messages', onTap: () {}),
                        GlassMenuItem(title: 'Mail', onTap: () {}),
                        GlassMenuItem(title: 'Copy Link', onTap: () {}),
                      ]),
                  GlassMenuItem(title: 'Move To', onTap: () {}, submenu: [
                    GlassMenuItem(title: 'Inbox', onTap: () {}),
                    GlassMenuItem(title: 'Archive', onTap: () {}),
                    GlassMenuItem(title: 'Projects', onTap: () {}, submenu: [
                      GlassMenuItem(title: 'Work', onTap: () {}),
                    ]),
                  ]),
                  GlassMenuItem(title: 'Tag', onTap: () {}),
                  const GlassMenuDivider(),
                  GlassMenuItem(title: 'Delete', onTap: () {}),
                ],
          ),
        )
      ])),
    ));

Future<void> open(WidgetTester tester, GlassMenuController c,
    {GlassMenuAlignment alignment = GlassMenuAlignment.topLeft,
    void Function(int, double)? onLevelChanged}) async {
  await tester.pumpWidget(
      host(c, alignment: alignment, onLevelChanged: onLevelChanged));
  c.open();
  await tester.pumpAndSettle();
}

// Layer opacity cannot fade glass: its backdrop pass stops blurring and the
// parent's rows show crisply through the card. Cards must use the glass
// materialize channel instead.
double layerOpacity(WidgetTester tester, int depth) => tester
    .widgetList<Opacity>(find.ancestor(
        of: surfaceFor(header(depth)), matching: find.byType(Opacity)))
    .fold(1.0, (value, widget) => value * widget.opacity);

GlassMaterializeScope? cardScope(WidgetTester tester, int depth) {
  final scopes = find.ancestor(
      of: surfaceFor(header(depth)),
      matching: find.byType(GlassMaterializeScope));
  return scopes.evaluate().isEmpty
      ? null
      : tester.widget<GlassMaterializeScope>(scopes.first);
}

double cardGlass(WidgetTester tester, int depth) =>
    cardScope(tester, depth)?.glassProgress ?? 1.0;
double cardText(WidgetTester tester, int depth) =>
    cardScope(tester, depth)?.contentOpacity ?? 1.0;

/// Effective opacity of a visible label (all Opacity ancestors).
double labelOpacity(WidgetTester tester, Finder label) => tester
    .widgetList<Opacity>(
        find.ancestor(of: label, matching: find.byType(Opacity)))
    .fold(1.0, (value, widget) => value * widget.opacity);

/// Native choreography: the card's rows arrive with its material (never an
/// empty frosted card), and the parent rows it covers cross-fade away, so
/// the two sets of labels never compete at full strength.
void expectNativeCrossFade(WidgetTester tester, {required bool opening}) {
  expect(layerOpacity(tester, 1), 1,
      reason: 'layer opacity disables the card backdrop blur');
  final glass = cardGlass(tester, 1), text = cardText(tester, 1);
  if (opening) {
    expect(text, greaterThanOrEqualTo(glass - 1e-9),
        reason: 'the card must not appear as an empty frosted panel');
  } else {
    expect(text, lessThanOrEqualTo(glass + 1e-9),
        reason: 'closing clears the card rows before its material');
  }
  expect(labelOpacity(tester, find.text('Move To')) + text,
      lessThanOrEqualTo(1 + 1e-6),
      reason: 'covered parent rows and card rows must cross-fade');
}

void main() {
  testWidgets('nested transitions fade only the top card and add no tint veil',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c);
    await tester.tap(find.text('Move To'));
    await tester.pumpAndSettle();
    final root = tester.widget<GlassContainer>(surfaceFor(find.text('Open')));
    final card = tester.widget<GlassContainer>(surfaceFor(header(1)));
    expect(card.quality, root.quality);
    expect(card.settings, root.settings);
    expect(
        find.descendant(
            of: surfaceFor(header(1)),
            matching: find.byWidgetPredicate((widget) =>
                widget is ColoredBox &&
                (widget.color == const Color(0x99FFFFFF) ||
                    widget.color == const Color(0x33000000)))),
        findsNothing,
        reason: 'submenu must not have an extra light/dark color wash');

    await tester.tap(find.text('Projects'));
    await tester.pump();
    expect(cardGlass(tester, 1), 1);
    expect(cardGlass(tester, 2), 0);
    await tester.pump(const Duration(milliseconds: 100));
    expect(cardGlass(tester, 1), 1);
    expect(cardGlass(tester, 2), allOf(greaterThan(0), lessThan(1)));
    await tester.pumpAndSettle();
    await tester.tap(header(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(cardGlass(tester, 1), 1);
    expect(cardGlass(tester, 2), allOf(greaterThan(0), lessThan(1)));
    await tester.pumpAndSettle();
    expect(header(2), findsNothing);
    expect(cardGlass(tester, 1), 1);
  });

  testWidgets('card rows cross-fade with the parent rows they cover',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c);
    await tester.tap(find.text('Share'));
    await tester.pump();
    var sawCardRows = false;
    for (var i = 0; i < 24; i++) {
      expectNativeCrossFade(tester, opening: true);
      if (cardGlass(tester, 1) < .5 && cardText(tester, 1) > .3) {
        sawCardRows = true;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(sawCardRows, isTrue,
        reason: 'rows should be legible while the material is still forming');
    await tester.pumpAndSettle();
    expect(cardText(tester, 1), 1);
    expect(labelOpacity(tester, find.text('Move To')), 0,
        reason: 'a covered row is hidden under the settled card');
    expect(labelOpacity(tester, find.text('Open')), closeTo(.5, 1e-9),
        reason: 'uncovered parent rows keep the native 50% dimming');
    await tester.tap(header(1));
    await tester.pump();
    while (header(1).evaluate().isNotEmpty) {
      expectNativeCrossFade(tester, opening: false);
      if (cardText(tester, 1) == 0) {
        expect(cardGlass(tester, 1), lessThan(.05),
            reason: 'no empty frosted card once its rows have cleared');
        expect(labelOpacity(tester, find.text('Move To')), greaterThan(.3),
            reason: 'covered parent rows return as the card rows clear');
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(labelOpacity(tester, find.text('Move To')), 1);
  });

  testWidgets('the whole submenu card fades in and out without popping',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c);
    await tester.tap(find.text('Share'));
    await tester.pump();
    expect(cardGlass(tester, 1), 0,
        reason: 'the first card frame must not appear at full opacity');
    await tester.pump(const Duration(milliseconds: 80));
    final opening = cardGlass(tester, 1);
    expect(opening, allOf(greaterThan(0), lessThan(1)));
    await tester.pump(const Duration(milliseconds: 80));
    expect(cardGlass(tester, 1), greaterThan(opening));
    await tester.pumpAndSettle();
    expect(cardGlass(tester, 1), 1);

    await tester.tap(header(1));
    await tester.pump();
    expect(cardGlass(tester, 1), 1);
    await tester.pump(const Duration(milliseconds: 40));
    final closing = cardGlass(tester, 1);
    expect(closing, allOf(greaterThan(0), lessThan(1)));
    await tester.pump(const Duration(milliseconds: 30));
    expect(cardGlass(tester, 1), lessThan(closing));
    await tester.pumpAndSettle();
    expect(header(1), findsNothing);
    expect(c.submenuDepth, 0);
  });

  for (final alignment in [
    GlassMenuAlignment.topLeft,
    GlassMenuAlignment.bottomLeft
  ]) {
    testWidgets(
        '${alignment.name}: constrained stack scrolls all children into reach',
        (tester) async {
      final c = GlassMenuController();
      final heights = <double>[];
      var chosen = false;
      await tester.pumpWidget(host(c,
          alignment: alignment,
          maxStackHeight: 350,
          onLevelChanged: (_, h) => heights.add(h),
          items: [
            for (var i = 0; i < 4; i++)
              GlassMenuItem(title: 'Row $i', onTap: () {}),
            GlassMenuItem(title: 'AI', onTap: () {}, submenu: [
              for (var i = 0; i < 12; i++)
                GlassMenuItem(title: 'Action $i', onTap: () => chosen = true),
            ]),
          ]));
      c.open();
      await tester.pumpAndSettle();
      final root = paintedRect(tester, surfaceFor(find.text('Row 0')));
      await tester.tap(find.text('AI'));
      await tester.pumpAndSettle();
      final card = paintedRect(tester, surfaceFor(header(1)));
      expect(heights.last, closeTo(350, .05));
      final extent = alignment == GlassMenuAlignment.topLeft
          ? card.bottom - root.top
          : root.bottom - card.top;
      expect(extent, lessThanOrEqualTo(350.05));
      await tester.drag(find.text('Action 0'), const Offset(0, -650));
      await tester.pumpAndSettle();
      expect(card.contains(tester.getCenter(find.text('Action 11'))), isTrue);
      await tester.tap(find.text('Action 11'));
      await tester.pumpAndSettle();
      expect(chosen, isTrue);
      expect(c.isOpen, isFalse);
    });
  }

  testWidgets(
      'a contained card reports the receded parent extent, not its old height',
      (tester) async {
    final c = GlassMenuController();
    final heights = <double>[];
    await tester
        .pumpWidget(host(c, onLevelChanged: (_, h) => heights.add(h), items: [
      GlassMenuItem(
          title: 'More',
          onTap: () {},
          submenu: [GlassMenuItem(title: 'Child', onTap: () {})]),
      for (var i = 0; i < 5; i++) GlassMenuItem(title: 'Row $i', onTap: () {}),
    ]));
    c.open();
    await tester.pumpAndSettle();
    final rootHeight = heights.single;
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(heights.last, closeTo(rootHeight * .971, .05));
    await tester.tap(header(1));
    await tester.pumpAndSettle();
    expect(heights.last, rootHeight);
  });

  testWidgets('glide reaches the overhang and can collapse via exposed parent',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c);
    c.glideTo(tester.getCenter(find.text('Move To')));
    expect(c.endGlide(), isTrue);
    await tester.pumpAndSettle();
    c.glideTo(tester.getCenter(find.text('Open')));
    expect(c.endGlide(), isTrue);
    await tester.pumpAndSettle();
    expect(c.submenuDepth, 0);
    await tester.tap(find.text('Move To'));
    await tester.pumpAndSettle();
    c.glideTo(tester.getCenter(find.text('Archive')));
    expect(c.endGlide(), isTrue);
    await tester.pumpAndSettle();
    expect(c.isOpen, isFalse);
  });

  testWidgets('Reduce Motion opens and collapses without intermediate geometry',
      (tester) async {
    final c = GlassMenuController();
    await tester.pumpWidget(host(c, reduceMotion: true));
    c.open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share'));
    await tester.pump();
    expect(c.submenuDepth, 1);
    expect(cardGlass(tester, 1), 1,
        reason:
            'Reduce Motion shows the card fully without waiting for a fade');
    expect(
        paintedRect(tester, surfaceFor(header(1))).height, closeTo(220, .05));
    await tester.tap(header(1));
    await tester.pump();
    expect(c.submenuDepth, 0);
  });

  testWidgets('native Share gate: full-width card overlays a receded parent',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c);
    final root = paintedRect(tester, surfaceFor(find.text('Open')));
    expect(root.width, closeTo(200, .01));
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    final parent = paintedRect(tester, surfaceFor(find.text('Open')));
    final card = paintedRect(tester, surfaceFor(header(1)));
    expect(parent.width, closeTo(194.2, .05));
    expect(parent.top, closeTo(root.top, .05));
    expect(parent.center.dx, closeTo(root.center.dx, .05));
    expect(card.width, closeTo(200, .05));
    expect(card.center.dx, closeTo(root.center.dx, .05));
    final source = find.text('Share').first;
    expect(tester.getCenter(header(1)).dy,
        closeTo(tester.getCenter(source).dy, 2));
    expect(find.text('Back'), findsNothing);
    expect(tester.widget<GlassMenuItem>(header(1)).titleStyle?.fontWeight,
        FontWeight.w600);
    expect(
        find.descendant(
            of: header(1), matching: find.byIcon(CupertinoIcons.chevron_down)),
        findsOneWidget);
    expect(
        tester
            .widgetList<Opacity>(find.ancestor(
                of: find.text('Open'), matching: find.byType(Opacity)))
            .any((o) => o.opacity == .5),
        isTrue);
    await tester.tap(header(1));
    await tester.pumpAndSettle();
    expect(c.submenuDepth, 0);
    expect(paintedRect(tester, surfaceFor(find.text('Open'))), root);
  });

  testWidgets('extent includes overhanging card and returns to root on pop',
      (tester) async {
    final c = GlassMenuController();
    final heights = <double>[];
    await open(tester, c, onLevelChanged: (_, h) => heights.add(h));
    final root = paintedRect(tester, surfaceFor(find.text('Open')));
    await tester.tap(find.text('Move To'));
    await tester.pumpAndSettle();
    final card = paintedRect(tester, surfaceFor(header(1)));
    expect(card.bottom, greaterThan(root.bottom));
    expect(heights.last, closeTo(card.bottom - root.top, .05));
    // Touching the exposed parent collapses; it never runs the parent action.
    await tester.tapAt(tester.getCenter(find.text('Open')));
    await tester.pumpAndSettle();
    expect(c.isOpen, isTrue);
    expect(c.submenuDepth, 0);
    expect(heights.last, heights.first);
  });

  testWidgets('upward menu keeps card on the menu side of its anchor',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c, alignment: GlassMenuAlignment.bottomRight);
    final root = paintedRect(tester, surfaceFor(find.text('Open')));
    await tester.tap(find.text('Move To'));
    await tester.pumpAndSettle();
    final card = paintedRect(tester, surfaceFor(header(1)));
    expect(card.bottom, lessThanOrEqualTo(root.bottom + .05));
    await tester.tap(header(1));
    await tester.pumpAndSettle();
    expect(c.isOpen, isTrue);
  });

  testWidgets(
      'nested card pops one level; covered rows have no semantics actions',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final c = GlassMenuController();
    await open(tester, c);
    await tester.tap(find.text('Move To'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(c.submenuDepth, 2);
    expect(find.bySemanticsLabel('Open'), findsNothing);
    final node = tester.getSemantics(find.bySemanticsLabel('Projects').first);
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(c.submenuDepth, 1);
    expect(find.text('Inbox'), findsOneWidget);
    await tester.tap(header(1));
    await tester.pumpAndSettle();
    expect(c.submenuDepth, 0);
    semantics.dispose();
  });

  testWidgets('submenu card GlassGlow uses specular alpha and not opaque white',
      (tester) async {
    final c = GlassMenuController();
    await open(tester, c);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    final glows = tester.widgetList<GlassGlow>(find.byType(GlassGlow));
    expect(glows.length, greaterThanOrEqualTo(2));
    final topCardGlow = glows.last;
    expect(topCardGlow.glowColor.a, lessThanOrEqualTo(0.20));
  });
}
