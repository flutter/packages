import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show ElevatedButton, MaterialApp, Scaffold;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_internal.dart'
    show SearchPill;

import '../shared/test_helpers.dart';

/// Screen reader roles, names and actions for controls that used to be bare
/// gesture detectors, and the Reduce Motion paths added alongside them.
void main() {
  // ignore: deprecated_member_use
  bool hasFlag(SemanticsNode node, SemanticsFlag flag) => node.hasFlag(flag);

  SemanticsNode nodeLabelled(String label) =>
      find.semantics.byLabel(label).evaluate().first;

  // Nodes inside an OverlayPortal (menus, popovers, toasts) are reached the
  // way the existing menu tests reach them: through their render object.
  void performOnOverlay(
    WidgetTester tester,
    Finder finder,
    SemanticsAction action,
  ) {
    final node = tester.getSemantics(finder.first);
    node.owner!.performAction(node.id, action);
  }

  group('GlassPicker', () {
    testWidgets('is a button named by semanticLabel with the value',
        (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(createTestApp(
        child: GlassPicker(
          value: 'Medium',
          semanticLabel: 'Size',
          onTap: () => taps++,
        ),
      ));

      final node = nodeLabelled('Size');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);
      expect(hasFlag(node, SemanticsFlag.isEnabled), isTrue);
      expect(node.value, 'Medium');

      tester.semantics.performAction(
        find.semantics.byLabel('Size'),
        SemanticsAction.tap,
      );
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('without a label the visible text names it', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createTestApp(
        child: const GlassPicker(value: null, placeholder: 'Choose'),
      ));

      final node = nodeLabelled('Choose');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);
      // No onTap: announced as a disabled button.
      expect(hasFlag(node, SemanticsFlag.isEnabled), isFalse);
      handle.dispose();
    });

    testWidgets('grows with the text instead of clipping it', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
          child: Center(
            child: GlassPicker(value: 'Medium', onTap: () {}),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(
          tester.getSize(find.byType(GlassPicker)).height, greaterThan(48.0));
    });
  });

  group('GlassTextField suffix', () {
    testWidgets('a tappable suffix is its own named button', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(createTestApp(
        child: GlassTextField(
          placeholder: 'Name',
          suffixIcon: const Icon(CupertinoIcons.clear),
          onSuffixTap: () => taps++,
          suffixSemanticLabel: 'Clear name',
        ),
      ));

      final node = nodeLabelled('Clear name');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);
      expect(hasFlag(node, SemanticsFlag.isTextField), isFalse);

      tester.semantics.performAction(
        find.semantics.byLabel('Clear name'),
        SemanticsAction.tap,
      );
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('a suffix without a tap is not announced as a button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createTestApp(
        child: const GlassTextField(
          placeholder: 'Name',
          suffixIcon: Icon(CupertinoIcons.info),
          suffixSemanticLabel: 'Info',
        ),
      ));

      expect(find.semantics.byLabel('Info'), findsNothing);
      handle.dispose();
    });

    testWidgets(
        'GlassPasswordField names the eye button and lets apps '
        'localize it', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createTestApp(
        child: const GlassPasswordField(
          showPasswordSemanticLabel: 'Passwort anzeigen',
          hidePasswordSemanticLabel: 'Passwort verbergen',
        ),
      ));

      final node = nodeLabelled('Passwort anzeigen');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel('Passwort anzeigen'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(find.semantics.byLabel('Passwort verbergen'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('GlassSearchBar clear button uses the Cupertino label',
        (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(createTestApp(
        child: GlassSearchBar(controller: controller),
      ));
      await tester.enterText(find.byType(EditableText), 'glass');
      await tester.pumpAndSettle();

      final label = const DefaultCupertinoLocalizations().clearButtonLabel;
      final node = nodeLabelled(label);
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel(label),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(controller.text, isEmpty);
      handle.dispose();
    });
  });

  group('GlassChip', () {
    testWidgets('delete is a separate button that only deletes',
        (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      var deletes = 0;
      await tester.pumpWidget(createTestApp(
        child: Center(
          child: GlassChip(
            label: 'Flutter',
            onTap: () => taps++,
            onDeleted: () => deletes++,
            deleteSemanticLabel: 'Remove Flutter',
          ),
        ),
      ));

      final node = nodeLabelled('Remove Flutter');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel('Remove Flutter'),
        SemanticsAction.tap,
      );
      expect(deletes, 1);
      expect(taps, 0);
      handle.dispose();
    });
  });

  group('GlassMenuItem', () {
    testWidgets('the semantic tap fires onTap once', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(createTestApp(
        child: GlassMenuItem(title: 'Copy', onTap: () => taps++),
      ));

      tester.semantics.performAction(
        find.semantics.byPredicate(
          (node) =>
              node.label == 'Copy' && hasFlag(node, SemanticsFlag.isButton),
        ),
        SemanticsAction.tap,
      );
      expect(taps, 1);
      // Only the labelled button carries a tap; the inner detector no longer
      // adds a second one on another node.
      expect(
        find.semantics.byPredicate(
          (node) =>
              !hasFlag(node, SemanticsFlag.isButton) &&
              node.getSemanticsData().hasAction(SemanticsAction.tap),
        ),
        findsNothing,
      );
      handle.dispose();
    });
  });

  group('GlassMenu and GlassPopover triggers', () {
    testWidgets('an icon trigger is a named button that opens the menu',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createTestApp(
        child: Center(
          child: GlassMenu(
            semanticLabel: 'More actions',
            trigger: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(CupertinoIcons.ellipsis),
            ),
            items: [GlassMenuItem(title: 'Share', onTap: () {})],
          ),
        ),
      ));

      final node = nodeLabelled('More actions');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel('More actions'),
        SemanticsAction.tap,
      );
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsOneWidget);

      // The barrier closes the menu for a screen reader too.
      final dismissLabel =
          const DefaultCupertinoLocalizations().menuDismissLabel;
      performOnOverlay(
        tester,
        find.bySemanticsLabel(dismissLabel),
        SemanticsAction.dismiss,
      );
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsNothing);
      handle.dispose();
    });

    testWidgets('a text trigger is named by its text', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createTestApp(
        child: Center(
          child: GlassPopover(
            trigger: const SizedBox(width: 80, height: 44, child: Text('Info')),
            contentBuilder: (context, close) => const Text('Details'),
          ),
        ),
      ));

      final node = nodeLabelled('Info');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel('Info'),
        SemanticsAction.tap,
      );
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);

      // The barrier closes the popover for a screen reader too.
      final dismissLabel =
          const DefaultCupertinoLocalizations().modalBarrierDismissLabel;
      performOnOverlay(
        tester,
        find.bySemanticsLabel(dismissLabel),
        SemanticsAction.dismiss,
      );
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsNothing);
      handle.dispose();
    });
  });

  group('GlassTabBar.searchable', () {
    const tabs = [
      GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
      GlassTab(label: 'Library', icon: Icon(CupertinoIcons.book)),
    ];

    testWidgets('the search circle is a button named by the hint text',
        (tester) async {
      final handle = tester.ensureSemantics();
      bool? toggled;
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.searchable(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          maskingQuality: MaskingQuality.off,
          searchConfig: GlassSearchBarConfig(
            hintText: 'Find',
            onSearchToggle: (active) => toggled = active,
          ),
        ),
      ));
      await tester.pump();

      final node = nodeLabelled('Find');
      expect(hasFlag(node, SemanticsFlag.isButton), isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel('Find'),
        SemanticsAction.tap,
      );
      expect(toggled, isTrue);
      handle.dispose();
    });
  });

  group('Reduce Motion', () {
    testWidgets('GlassPageControl moves the active dot without animating',
        (tester) async {
      Widget control(int page) => createTestApp(
            child: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Center(
                child: GlassPageControl(count: 4, currentPage: page),
              ),
            ),
          );
      await tester.pumpWidget(control(0));
      await tester.pumpWidget(control(2));

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('GlassToast fades in place and offers a dismiss action',
        (tester) async {
      final handle = tester.ensureSemantics();
      // The toast lives in the Navigator's overlay, so Reduce Motion is set
      // above it rather than around the button.
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => GlassAccessibilityScope(
          reduceMotion: true,
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => GlassToast.show(
                context,
                message: 'Saved',
                duration: Duration.zero,
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Show'));
      await tester.pump();

      // On its first frame a sliding toast would still sit a full height
      // away; under Reduce Motion nothing above it is offset.
      final slides = tester.widgetList<SlideTransition>(
        find.ancestor(
          of: find.byType(GlassToast),
          matching: find.byType(SlideTransition),
        ),
      );
      expect(slides, isNotEmpty);
      for (final slide in slides) {
        expect(slide.position.value, Offset.zero);
      }

      await tester.pumpAndSettle();
      // Read once: the live region's label, not the label plus the text.
      expect(find.bySemanticsLabel('Saved'), findsOneWidget);
      performOnOverlay(
        tester,
        find.bySemanticsLabel('Saved'),
        SemanticsAction.dismiss,
      );
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
      handle.dispose();
    });

    testWidgets('GlassTabBar.searchable pills jump instead of springing',
        (tester) async {
      var searching = false;
      var showPill = true;
      late StateSetter setBar;
      await tester.pumpWidget(createTestApp(
        child: GlassAccessibilityScope(
          reduceMotion: true,
          child: StatefulBuilder(
            builder: (context, setState) {
              setBar = setState;
              return GlassTabBar.searchable(
                tabs: const [
                  GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
                  GlassTab(label: 'Library', icon: Icon(CupertinoIcons.book)),
                ],
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searching,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (_) {},
                  showPill: showPill,
                ),
              );
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Opening search retargets the tab and search pills. Their new widths
      // and positions land in the frame after the retarget, with no spring
      // left to run. (The bar's height has its own animation, which this
      // does not cover, so only the horizontal geometry is compared.)
      setBar(() => searching = true);
      await tester.pump();
      await tester.pump();
      final jumped = tester.getRect(find.byType(SearchPill));
      await tester.pumpAndSettle();
      final settled = tester.getRect(find.byType(SearchPill));
      expect(jumped.left, settled.left);
      expect(jumped.width, settled.width);

      // Hiding the pill drops it at once rather than shrinking it away.
      setBar(() {
        searching = false;
        showPill = false;
      });
      await tester.pump();
      expect(find.byType(SearchPill), findsNothing);
    });
  });
}
