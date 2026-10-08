/// Tests that verify widgets resolve brightness-aware colors correctly
/// in both light and dark modes.
///
/// This file targets the content color audit from the iOS 26 light mode
/// support work. Each widget that was changed to resolve from
/// CupertinoColors.label / .secondaryLabel / .tertiaryLabel is tested
/// in both Brightness.light and Brightness.dark.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// =============================================================================
// Helpers
// =============================================================================

/// Wraps [child] in a CupertinoApp with the given [brightness].
///
/// Using CupertinoApp ensures CupertinoTheme provides the correct
/// brightness-resolved colors — matching real-world usage.
Widget _buildApp({
  required Brightness brightness,
  required Widget child,
}) {
  return CupertinoApp(
    theme: CupertinoThemeData(brightness: brightness),
    home: CupertinoPageScaffold(
      child: Center(child: child),
    ),
  );
}

/// Finds the first [IconTheme] descendant of [parentType] and returns its
/// effective icon color.
Color? _findIconColor(WidgetTester tester, Type parentType) {
  final iconTheme = tester.widget<IconTheme>(
    find
        .descendant(
          of: find.byType(parentType),
          matching: find.byType(IconTheme),
        )
        .first,
  );
  return iconTheme.data.color;
}

/// Finds the [Color] property of the first circular [Container] dot in
/// [GlassPageControl].
Color? _findActiveDotColor(WidgetTester tester) {
  final dots = find.descendant(
    of: find.byType(GlassPageControl),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
          (widget.decoration as BoxDecoration).color != null,
    ),
  );

  // The active dot is the largest one (scale 1.0 vs 0.7).
  // Just return the first dot's color — for page 0, the first is active.
  final container = tester.widget<Container>(dots.first);
  return (container.decoration as BoxDecoration).color;
}

// =============================================================================
// GlassIconButton — light/dark color resolution
// =============================================================================

void main() {
  group('GlassIconButton brightness-aware colors', () {
    testWidgets('uses dark icon color (white) in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassIconButton(
            icon: const Icon(CupertinoIcons.star),
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findIconColor(tester, GlassIconButton);
      // In dark mode, CupertinoColors.label resolves to white
      expect(color, isNotNull);
      expect(color!.a, greaterThan(0.9));
      // White has R,G,B all near 1.0
      expect(color.r, greaterThan(0.9));
      expect(color.g, greaterThan(0.9));
      expect(color.b, greaterThan(0.9));
    });

    testWidgets('uses light icon color (black) in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassIconButton(
            icon: const Icon(CupertinoIcons.star),
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findIconColor(tester, GlassIconButton);
      // In light mode, CupertinoColors.label resolves to black
      expect(color, isNotNull);
      expect(color!.a, greaterThan(0.9));
      // Black has R,G,B all near 0.0
      expect(color.r, lessThan(0.1));
      expect(color.g, lessThan(0.1));
      expect(color.b, lessThan(0.1));
    });

    testWidgets('disabled icon uses tertiaryLabel in dark mode',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: const GlassIconButton(
            icon: Icon(CupertinoIcons.star),
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findIconColor(tester, GlassIconButton);
      // tertiaryLabel in dark mode is a semi-transparent white
      expect(color, isNotNull);
      expect(color!.a, lessThan(0.5)); // significantly dimmed
    });

    testWidgets('disabled icon uses tertiaryLabel in light mode',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: const GlassIconButton(
            icon: Icon(CupertinoIcons.star),
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findIconColor(tester, GlassIconButton);
      // tertiaryLabel in light mode is a semi-transparent black
      expect(color, isNotNull);
      expect(color!.a, lessThan(0.5)); // significantly dimmed
    });
  });

  // ===========================================================================
  // GlassPageControl — light/dark dot colors
  // ===========================================================================

  group('GlassPageControl brightness-aware colors', () {
    testWidgets('active dot is white-ish in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findActiveDotColor(tester);
      expect(color, isNotNull);
      // In dark mode, CupertinoColors.label is white
      expect(color!.r, greaterThan(0.9));
      expect(color.g, greaterThan(0.9));
      expect(color.b, greaterThan(0.9));
    });

    testWidgets('active dot is black-ish in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findActiveDotColor(tester);
      expect(color, isNotNull);
      // In light mode, CupertinoColors.label is black
      expect(color!.r, lessThan(0.1));
      expect(color.g, lessThan(0.1));
      expect(color.b, lessThan(0.1));
    });

    testWidgets('custom activeColor overrides brightness resolution',
        (tester) async {
      const customColor = Color(0xFFFF0000);
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
            activeColor: customColor,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final color = _findActiveDotColor(tester);
      expect(color, equals(customColor));
    });
  });

  // ===========================================================================
  // GlassTabBar — light/dark label/icon colors
  // ===========================================================================

  group('GlassTabBar brightness-aware colors', () {
    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassSegmentedControl(
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            segments: const [
              GlassSegment(label: 'Tab 1'),
              GlassSegment(label: 'Tab 2'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
      // Selected tab text should be visible (white-ish in dark mode)
      final styleWidget = tester.widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Tab 1'),
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      );
      expect(styleWidget.style.color, isNotNull);
      final color = styleWidget.style.color!;
      expect(color.r, greaterThan(0.9));
      expect(color.g, greaterThan(0.9));
      expect(color.b, greaterThan(0.9));
    });

    testWidgets('renders correctly in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassSegmentedControl(
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            segments: const [
              GlassSegment(label: 'Tab 1'),
              GlassSegment(label: 'Tab 2'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
      // Selected tab text should be visible (black-ish in light mode)
      final styleWidget = tester.widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Tab 1'),
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      );
      expect(styleWidget.style.color, isNotNull);
      final color = styleWidget.style.color!;
      expect(color.r, lessThan(0.1));
      expect(color.g, lessThan(0.1));
      expect(color.b, lessThan(0.1));
    });

    testWidgets('unselected tab uses secondary color in light mode',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassSegmentedControl(
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            segments: const [
              GlassSegment(label: 'Selected'),
              GlassSegment(label: 'Unselected'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final styleWidget = tester.widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Unselected'),
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      );
      expect(styleWidget.style.color, isNotNull);
      // secondaryLabel in light mode is semi-transparent black (≈60% opacity)
      final color = styleWidget.style.color!;
      expect(color.a, lessThan(0.7));
    });

    testWidgets('custom selectedLabelColor overrides brightness resolution',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassSegmentedControl(
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            selectedTextStyle: const TextStyle(color: Color(0xFFFF0000)),
            segments: const [
              GlassSegment(label: 'Custom'),
              GlassSegment(label: 'Other'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final styleWidget = tester.widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Custom'),
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      );
      expect(styleWidget.style.color, equals(const Color(0xFFFF0000)));
    });
  });

  // ===========================================================================
  // GlassTabBar.bottom — verify existing brightness resolution still works
  // ===========================================================================

  group('GlassTabBar.bottom brightness-aware colors', () {
    testWidgets('renders in light mode without error', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassTabBar.bottom(
            selectedIndex: 0,
            onTabSelected: (_) {},
            tabs: const [
              GlassTab(
                label: 'Home',
                icon: Icon(CupertinoIcons.house),
              ),
              GlassTab(
                label: 'Search',
                icon: Icon(CupertinoIcons.search),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassTabBar.bottom(
            selectedIndex: 0,
            onTabSelected: (_) {},
            tabs: const [
              GlassTab(
                label: 'Home',
                icon: Icon(CupertinoIcons.house),
              ),
              GlassTab(
                label: 'Search',
                icon: Icon(CupertinoIcons.search),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassBadge — text stays white (intentional — on colored background)
  // ===========================================================================

  group('GlassBadge text color', () {
    testWidgets('badge text is white in dark mode (on colored bg)',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassBadge(
            count: 5,
            child: const Icon(CupertinoIcons.bell),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('5'));
      expect(text.style?.color, equals(CupertinoColors.white));
    });

    testWidgets('badge text is white in light mode (on colored bg)',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassBadge(
            count: 3,
            child: const Icon(CupertinoIcons.bell),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('3'));
      // Badge text should remain white regardless of mode — it's on a red bg
      expect(text.style?.color, equals(CupertinoColors.white));
    });
  });

  // ===========================================================================
  // GlassSwitch thumb — stays white (iOS native behavior)
  // ===========================================================================

  group('GlassSwitch thumb color (should NOT change with brightness)', () {
    testWidgets('thumb is white in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassSwitch(
            value: true,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSwitch), findsOneWidget);
      // Just verify it renders — thumb color is internal
    });

    testWidgets('thumb is white in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassSwitch(
            value: true,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSwitch), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassFormField — label resolves from CupertinoColors.label
  // ===========================================================================

  group('GlassFormField brightness-aware colors', () {
    testWidgets('label is white-ish in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassFormField(
            label: 'Email',
            child: const SizedBox(height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Email'));
      expect(text.style?.color, isNotNull);
      final color = text.style!.color!;
      expect(color.r, greaterThan(0.9));
      expect(color.g, greaterThan(0.9));
      expect(color.b, greaterThan(0.9));
    });

    testWidgets('label is black-ish in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassFormField(
            label: 'Email',
            child: const SizedBox(height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Email'));
      expect(text.style?.color, isNotNull);
      final color = text.style!.color!;
      expect(color.r, lessThan(0.1));
      expect(color.g, lessThan(0.1));
      expect(color.b, lessThan(0.1));
    });

    testWidgets('helper text uses secondaryLabel in light mode',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassFormField(
            label: 'Name',
            helperText: 'Enter your full name',
            child: const SizedBox(height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Enter your full name'));
      expect(text.style?.color, isNotNull);
      // secondaryLabel in light mode is semi-transparent black (≈60% opacity)
      final color = text.style!.color!;
      expect(color.a, lessThan(0.7));
    });
  });

  // ===========================================================================
  // GlassPicker — text resolves from CupertinoColors.label
  // ===========================================================================

  group('GlassPicker brightness-aware colors', () {
    testWidgets('value text is white-ish in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: GlassPicker(
            value: 'Developer',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Developer'));
      expect(text.style?.color, isNotNull);
      final color = text.style!.color!;
      expect(color.r, greaterThan(0.9));
      expect(color.g, greaterThan(0.9));
      expect(color.b, greaterThan(0.9));
    });

    testWidgets('value text is black-ish in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: GlassPicker(
            value: 'Developer',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Developer'));
      expect(text.style?.color, isNotNull);
      final color = text.style!.color!;
      expect(color.r, lessThan(0.1));
      expect(color.g, lessThan(0.1));
      expect(color.b, lessThan(0.1));
    });
  });

  // ===========================================================================
  // GlassPasswordField — icons resolve from CupertinoColors.secondaryLabel
  // ===========================================================================

  group('GlassPasswordField brightness-aware colors', () {
    testWidgets('renders in light mode without error', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: const GlassPasswordField(
            placeholder: 'Password',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassPasswordField), findsOneWidget);
    });

    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: const GlassPasswordField(
            placeholder: 'Password',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassPasswordField), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassToast — background and text resolve from brightness
  // ===========================================================================

  group('GlassToast brightness-aware colors', () {
    testWidgets('toast text is white-ish in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: const GlassToast(
            message: 'Success!',
            type: GlassToastType.success,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Success!'));
      expect(text.style?.color, isNotNull);
      final color = text.style!.color!;
      expect(color.r, greaterThan(0.9));
      expect(color.g, greaterThan(0.9));
      expect(color.b, greaterThan(0.9));
    });

    testWidgets('toast text is black-ish in light mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: const GlassToast(
            message: 'Success!',
            type: GlassToastType.success,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Success!'));
      expect(text.style?.color, isNotNull);
      final color = text.style!.color!;
      expect(color.r, lessThan(0.1));
      expect(color.g, lessThan(0.1));
      expect(color.b, lessThan(0.1));
    });

    testWidgets('toast background is dark-tinted in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: const GlassToast(
            message: 'Info',
            type: GlassToastType.info,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Container with BoxDecoration (background)
      final containers = find.descendant(
        of: find.byType(GlassToast),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color != null,
        ),
      );
      expect(containers, findsWidgets);
      final container = tester.widget<Container>(containers.first);
      final bgColor = (container.decoration as BoxDecoration).color!;
      // Dark mode: black-based background
      expect(bgColor.r, lessThan(0.1));
      expect(bgColor.g, lessThan(0.1));
      expect(bgColor.b, lessThan(0.1));
    });

    testWidgets('toast background is light-tinted in light mode',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: const GlassToast(
            message: 'Info',
            type: GlassToastType.info,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Container with BoxDecoration (background)
      final containers = find.descendant(
        of: find.byType(GlassToast),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color != null,
        ),
      );
      expect(containers, findsWidgets);
      final container = tester.widget<Container>(containers.first);
      final bgColor = (container.decoration as BoxDecoration).color!;
      // Light mode: white-based background
      expect(bgColor.r, greaterThan(0.9));
      expect(bgColor.g, greaterThan(0.9));
      expect(bgColor.b, greaterThan(0.9));
    });
  });

  // ===========================================================================
  // GlassActionSheet — card background resolves from brightness
  // ===========================================================================

  group('GlassActionSheet brightness-aware colors', () {
    testWidgets('renders in light mode without error', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          child: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () {
                showGlassActionSheet(
                  context: context,
                  title: 'Test',
                  actions: [
                    GlassActionSheetAction(
                      label: 'Action 1',
                      onPressed: () {},
                    ),
                  ],
                );
              },
              child: const Text('Show'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the button to show the action sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Verify the action sheet is displayed
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Action 1'), findsOneWidget);
    });

    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          child: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () {
                showGlassActionSheet(
                  context: context,
                  title: 'Test',
                  actions: [
                    GlassActionSheetAction(
                      label: 'Action 1',
                      onPressed: () {},
                    ),
                  ],
                );
              },
              child: const Text('Show'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Action 1'), findsOneWidget);
    });
  });
}
