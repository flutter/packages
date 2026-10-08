import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassPage', () {
    testWidgets('renders child directly when no background provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            child: const Scaffold(
              body: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(GlassBackgroundSource), findsNothing);

      // Without background, Scaffold is not wrapped in Theme override
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNull);
    });

    testWidgets(
        'passes child through without Theme wrapper when background provided in MaterialApp',
        (tester) async {
      // GlassPage no longer injects a Theme to force Scaffold transparency.
      // GlassScaffold handles its own background color on CupertinoPageScaffold.
      // Users who use GlassPage with a raw Scaffold must set backgroundColor
      // explicitly if they want transparency.
      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            background: const SizedBox(key: Key('bg')),
            child: Scaffold(
              body: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bg')), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      // No Theme injection around child — GlassPage is now a pure host-agnostic wrapper.
      final glassPageFinder = find.byType(GlassPage);
      final themesInsidePage = find.descendant(
        of: glassPageFinder,
        matching: find.byType(Theme),
      );
      // Any Theme found inside GlassPage should not be from GlassPage itself
      // (i.e., no scoped GlassTheme themeOverride wrapper — we didn't set one).
      expect(
          tester.widgetList<Theme>(themesInsidePage).where(
              (t) => t.data.scaffoldBackgroundColor == const Color(0x00000000)),
          isEmpty);
    });

    testWidgets('works in pure CupertinoApp host with no Material ancestor',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassPage(
            background: const SizedBox(key: Key('bg')),
            child: const CupertinoPageScaffold(
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bg')), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('respects themeOverride parameter', (tester) async {
      final overrideTheme = GlassThemeData(
        light: const GlassThemeVariant(settings: GlassThemeSettings(blur: 100)),
        dark: const GlassThemeVariant(settings: GlassThemeSettings(blur: 100)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            themeOverride: overrideTheme,
            child: const Scaffold(
              body: Text('Content'),
            ),
          ),
        ),
      );

      final themeData = GlassTheme.of(tester.element(find.byType(Scaffold)));
      expect(themeData.data.light.settings?.blur, 100);
    });

    testWidgets('handles GlassStatusBarStyle.dark and light appropriately',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            statusBarStyle: GlassStatusBarStyle.dark,
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      final annotatedDark =
          tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      expect(annotatedDark.value, SystemUiOverlayStyle.dark);

      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            statusBarStyle: GlassStatusBarStyle.light,
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      final annotatedLight =
          tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      expect(annotatedLight.value, SystemUiOverlayStyle.light);
    });

    testWidgets('handles GlassStatusBarStyle.auto based on platform brightness',
        (tester) async {
      // Simulate dark mode OS
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            statusBarStyle: GlassStatusBarStyle.auto,
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      final annotatedLight =
          tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      // In dark mode, auto uses light icons
      expect(annotatedLight.value, SystemUiOverlayStyle.light);

      // Simulate light mode OS
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassPage(
            statusBarStyle: GlassStatusBarStyle.auto,
            child: const Scaffold(body: Text('Content')),
          ),
        ),
      );

      final annotatedDark =
          tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      // In light mode, auto uses dark icons
      expect(annotatedDark.value, SystemUiOverlayStyle.dark);

      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    testWidgets('edgeToEdge property updates properly on rebuild',
        (tester) async {
      bool edgeToEdge = false;

      await tester.pumpWidget(
        StatefulBuilder(builder: (context, setState) {
          return MaterialApp(
            home: GestureDetector(
              onTap: () => setState(() => edgeToEdge = !edgeToEdge),
              child: GlassPage(
                edgeToEdge: edgeToEdge,
                child: const Scaffold(body: Text('Content')),
              ),
            ),
          );
        }),
      );

      expect(find.byType(GlassPage), findsOneWidget);

      // Tap to toggle edgeToEdge
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Tap to toggle back
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Tests pass without exceptions during didUpdateWidget lifecycle
      expect(find.byType(GlassPage), findsOneWidget);
    });
  });
}
