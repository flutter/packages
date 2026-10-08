import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Every interactive control must surface as exactly ONE semantics node
/// (#381).
///
/// The controls share `GlassFocusRegion`, which used to declare the
/// focusable flag on its labelled node while its FocusableActionDetector
/// declared it again. Conflicting flags stop Flutter merging the two, so the
/// focus semantics split into a second node: unlabelled for an icon or a
/// switch (a stop TalkBack announces as "unlabelled"), or a repeat of the
/// visible text for a segment, chip or menu row (a second stop VoiceOver
/// reads the label on again). Control-wide drag detectors that were not
/// excluded from semantics added unlabelled scroll/tap nodes on top.
void main() {
  Widget host(Widget child) => CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(child: SizedBox(width: 340, child: child)),
        ),
      );

  Iterable<SemanticsNode> allNodes() =>
      find.semantics.byPredicate((_) => true).evaluate();

  /// The reporter's check from #381: no node without a name may carry an
  /// action.
  List<String> unlabelledWithActions() => [
        for (final node in allNodes())
          if (node.getSemanticsData() case final d
              when d.label.isEmpty && SemanticsAction.values.any(d.hasAction))
            '${SemanticsAction.values.where(d.hasAction).map((a) => a.name)} '
                '${node.rect.size}',
      ];

  /// A label carried by more than one node is a control read twice.
  List<String> duplicatedLabels() {
    final seen = <String>{};
    return [
      for (final node in allNodes())
        if (node.label.isNotEmpty && !seen.add(node.label)) node.label,
    ];
  }

  /// Inside an actionable node, a labelled descendant with no action of its
  /// own is a second stop that only re-reads the control (e.g. a chip named
  /// "Design filter" followed by a stop reading "Design"). A nested control
  /// with its own action, like a chip's delete button, is legitimate.
  List<String> redundantNestedStops() {
    final found = <String>[];
    bool actionable(SemanticsNode n) {
      final d = n.getSemanticsData();
      return d.hasAction(SemanticsAction.tap) ||
          d.hasAction(SemanticsAction.longPress) ||
          d.hasAction(SemanticsAction.increase);
    }

    void descend(SemanticsNode n, String owner) {
      n.visitChildren((c) {
        if (c.label.isNotEmpty && !actionable(c)) {
          found.add('"${c.label}" inside "$owner"');
        }
        if (!actionable(c)) descend(c, owner);
        return true;
      });
    }

    for (final node in allNodes()) {
      if (actionable(node)) descend(node, node.label);
    }
    return found;
  }

  final controls = <String, Widget Function()>{
    'GlassSwitch': () => GlassSwitch(value: true, onChanged: (_) {}),
    'GlassSegmentedControl': () => GlassSegmentedControl(
          segments: const [
            GlassSegment(label: 'System'),
            GlassSegment(label: 'Light'),
            GlassSegment(label: 'Dark'),
          ],
          selectedIndex: 0,
          onSegmentSelected: (_) {},
        ),
    'GlassSegmentedControl (icons)': () => GlassSegmentedControl(
          segments: const [
            GlassSegment(
              icon: Icon(CupertinoIcons.list_bullet),
              semanticLabel: 'List',
            ),
            GlassSegment(
              icon: Icon(CupertinoIcons.square_grid_2x2),
              semanticLabel: 'Grid',
            ),
          ],
          selectedIndex: 0,
          onSegmentSelected: (_) {},
        ),
    'GlassButton': () => GlassButton(
          icon: const Icon(CupertinoIcons.heart),
          label: 'Like',
          onTap: () {},
        ),
    'GlassButton.custom': () => GlassButton.custom(
          onTap: () {},
          width: 160,
          height: 44,
          label: 'Continue to checkout',
          child: const Text('Continue'),
        ),
    'GlassIconButton': () => GlassIconButton(
          icon: const Icon(CupertinoIcons.gear),
          onPressed: () {},
          semanticLabel: 'Settings',
        ),
    'GlassChip': () => GlassChip(
          label: 'Design',
          semanticLabel: 'Design filter',
          onTap: () {},
        ),
    'GlassChip (deletable)': () => GlassChip(
          label: 'Design',
          onTap: () {},
          onDeleted: () {},
        ),
    'GlassMenuItem': () => GlassMenuItem(
          title: 'Copy',
          subtitle: 'To clipboard',
          trailing: const Text('⌘C'),
          onTap: () {},
        ),
    'GlassListTile': () => GlassListTile(
          title: const Text('Account'),
          subtitle: const Text('Signed in'),
          onTap: () {},
          onLongPress: () {},
        ),
    'GlassStepper': () => GlassStepper(value: 3, onChanged: (_) {}),
    'GlassSlider': () =>
        GlassSlider(value: 0.5, onChanged: (_) {}, label: 'Volume'),
    'GlassButtonGroup.icons': () => GlassButtonGroup.icons(items: [
          GlassButtonGroupItem(
            icon: const Icon(CupertinoIcons.bold),
            label: 'Bold',
            onTap: () {},
          ),
          GlassButtonGroupItem(
            icon: const Icon(CupertinoIcons.italic),
            label: 'Italic',
            onTap: () {},
          ),
        ]),
    'GlassTabBar.bottom': () => GlassTabBar.bottom(
          tabs: const [
            GlassTab(icon: Icon(CupertinoIcons.home), label: 'Home'),
            GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
          maskingQuality: MaskingQuality.off,
        ),
  };

  group('one semantics node per control (#381)', () {
    for (final MapEntry(key: name, value: build) in controls.entries) {
      testWidgets(name, (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(build()));
        await tester.pumpAndSettle();

        expect(unlabelledWithActions(), isEmpty,
            reason: 'an unnamed node with actions is an extra stop');
        expect(duplicatedLabels(), isEmpty,
            reason: 'a repeated label is the same control read twice');
        expect(redundantNestedStops(), isEmpty,
            reason: 'the control must be announced once, on one node');
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        handle.dispose();
      });
    }
  });

  group('the merged node keeps everything it announced before', () {
    testWidgets('GlassSwitch: label, toggle, tap and focus on one node',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(
        GlassSwitch(value: true, onChanged: (_) {}, semanticLabel: 'Wi-Fi'),
      ));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Wi-Fi')),
        matchesSemantics(
          label: 'Wi-Fi',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('an explicit GlassButton label replaces its visible text',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(GlassButton.custom(
        onTap: () {},
        width: 160,
        height: 44,
        label: 'Continue to checkout',
        child: const Text('Continue'),
      )));

      expect(find.bySemanticsLabel('Continue to checkout'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Continue\$')), findsNothing);
      handle.dispose();
    });

    testWidgets('GlassChip delete button is its own, named node',
        (tester) async {
      final handle = tester.ensureSemantics();
      var tapped = 0;
      var deleted = 0;
      await tester.pumpWidget(host(GlassChip(
        label: 'Design',
        onTap: () => tapped++,
        onDeleted: () => deleted++,
      )));

      tester.semantics.performAction(
        find.semantics.byLabel('Remove Design'),
        SemanticsAction.tap,
      );
      expect(deleted, 1);
      expect(tapped, 0, reason: 'removing must not also activate the chip');
      handle.dispose();
    });

    testWidgets('GlassMenuItem subtitle is announced as the value',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(GlassMenuItem(
        title: 'Copy',
        subtitle: 'To clipboard',
        onTap: () {},
      )));

      final data = tester.getSemantics(find.bySemanticsLabel('Copy'));
      expect(data.value, 'To clipboard');
      handle.dispose();
    });

    testWidgets('GlassListTile long press is reachable by a screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      var longPressed = 0;
      await tester.pumpWidget(host(GlassListTile(
        title: const Text('Account'),
        onTap: () {},
        onLongPress: () => longPressed++,
      )));

      tester.semantics.performAction(
        find.semantics.byLabel('Account'),
        SemanticsAction.longPress,
      );
      expect(longPressed, 1);
      handle.dispose();
    });
  });

  testWidgets('canRequestFocus: false keeps a control out of keyboard focus',
      (tester) async {
    // FocusableActionDetector writes its own `enabled` into the node's
    // canRequestFocus, which used to override this flag entirely.
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(host(GlassButton(
      icon: const Icon(CupertinoIcons.heart),
      label: 'Like',
      onTap: () {},
      focusNode: node,
      canRequestFocus: false,
    )));

    node.requestFocus();
    await tester.pump();

    expect(node.canRequestFocus, isFalse);
    expect(node.hasFocus, isFalse);
  });
}
