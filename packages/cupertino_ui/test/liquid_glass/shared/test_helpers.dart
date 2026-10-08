import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Standard constraints for golden test scenarios
final testScenarioConstraints = BoxConstraints.tight(const Size(500, 500));

/// Glass settings without lighting effects for predictable golden tests
const settingsWithoutLighting = LiquidGlassSettings(
  chromaticAberration: 0,
  lightIntensity: 0,
  blur: 0,
);

/// Default glass settings for widget tests
/// Note: Tests should use fake: true on LiquidGlassLayer to avoid shader loading
const defaultTestGlassSettings = LiquidGlassSettings(
  thickness: 30,
  blur: 3,
  refractiveIndex: 1.59,
);

/// Helper to pump a frame before running a golden assertion.
Future<void> pumpOnce(WidgetTester tester) async {
  await tester.pump();
}

/// A scenario within a [GoldenTestGroup].
class GoldenTestScenario extends StatelessWidget {
  /// Creates a [GoldenTestScenario].
  const GoldenTestScenario({
    required this.name,
    required this.child,
    this.constraints,
    super.key,
  });

  /// The name / label of the scenario.
  final String name;

  /// The widget under test.
  final Widget child;

  /// Optional constraints for the scenario.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (constraints != null) {
      content = ConstrainedBox(
        constraints: constraints!,
        child: content,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
          ),
        ),
        content,
      ],
    );
  }
}

/// Groups multiple [GoldenTestScenario] widgets in a structured layout.
class GoldenTestGroup extends StatelessWidget {
  /// Creates a [GoldenTestGroup].
  const GoldenTestGroup({
    required this.children,
    this.scenarioConstraints,
    this.columns = 2,
    super.key,
  });

  /// List of test scenarios to display.
  final List<GoldenTestScenario> children;

  /// Default constraints applied to each scenario child.
  final BoxConstraints? scenarioConstraints;

  /// Number of columns (when applicable).
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E2E),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final scenario in children)
            if (scenarioConstraints != null && scenario.constraints == null)
              GoldenTestScenario(
                name: scenario.name,
                constraints: scenarioConstraints,
                child: scenario.child,
              )
            else
              scenario,
        ],
      ),
    );
  }
}

/// Executes a golden test using Flutter SDK's native [matchesGoldenFile].
void goldenTest(
  String description, {
  required String fileName,
  required Widget Function() builder,
  Future<void> Function(WidgetTester)? pumpBeforeTest,
  BoxConstraints? scenarioConstraints,
  BoxConstraints? constraints,
  List<String>? tags,
}) {
  testWidgets(
    description,
    tags: tags,
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF1E1E2E),
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: const ValueKey('golden_scenario_root'),
                child: builder(),
              ),
            ),
          ),
        ),
      );

      if (pumpBeforeTest != null) {
        await pumpBeforeTest(tester);
      } else {
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byKey(const ValueKey('golden_scenario_root')),
        matchesGoldenFile('goldens/$fileName.png'),
      );
    },
  );
}

/// Executes a **light-mode** golden test.
///
/// Identical contract to [goldenTest] except:
/// - [MaterialApp] theme is [Brightness.light] with `Color(0xFFF2F2F7)` scaffold.
/// - A [GlassTheme] with `brightness: Brightness.light` is injected at the
///   highest-priority cascade level so [GlassTheme.brightnessOf] always returns
///   [Brightness.light] regardless of the test runner's OS setting.
/// - The [ScaffoldBackgroundColor] matches the iOS system grouped background
///   so drop-shadow rendering (`_InverseShapeClipper`, `_InverseBarClipper`) has
///   a realistic light backdrop to paint against.
///
/// Use [buildWithLightBackground] and [LightGoldenTestGroup] inside [builder].
void goldenTestLight(
  String description, {
  required String fileName,
  required Widget Function() builder,
  Future<void> Function(WidgetTester)? pumpBeforeTest,
  BoxConstraints? scenarioConstraints,
  BoxConstraints? constraints,
  List<String>? tags,
}) {
  testWidgets(
    description,
    tags: tags,
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        GlassTheme(
          // Level-1 brightness override: all glass widgets see Brightness.light
          // regardless of the runner's OS setting.
          data: const GlassThemeData(brightness: Brightness.light),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF2F2F7),
            ),
            home: Scaffold(
              backgroundColor: const Color(0xFFF2F2F7),
              body: SingleChildScrollView(
                child: RepaintBoundary(
                  key: const ValueKey('golden_scenario_root'),
                  child: builder(),
                ),
              ),
            ),
          ),
        ),
      );

      if (pumpBeforeTest != null) {
        await pumpBeforeTest(tester);
      } else {
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byKey(const ValueKey('golden_scenario_root')),
        matchesGoldenFile('goldens/$fileName.png'),
      );
    },
  );
}

/// Wraps a widget with grid paper background for visual reference in golden tests
Widget buildWithGridPaper(Widget child) {
  return ColoredBox(
    color: Colors.white,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          const Positioned.fill(
            child: GridPaper(
              color: Colors.black,
            ),
          ),
          Center(
            child: child,
          ),
        ],
      ),
    ),
  );
}

/// Wraps a widget with a colorful gradient background for contrast
Widget buildWithGradientBackground(Widget child) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6366F1),
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
        ],
      ),
    ),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  );
}

/// Wraps a widget with the Apple iOS system grouped background (`#F2F2F7`)
/// for light-mode golden tests.
///
/// This gives the inverse-clipped drop-shadow subsystem (`_InverseShapeClipper`,
/// `_InverseBarClipper`) a realistic high-luminance backdrop to paint against,
/// which is the key scenario that all-dark golden tests cannot exercise.
Widget buildWithLightBackground(Widget child) {
  return Container(
    color: const Color(0xFFF2F2F7),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  );
}

/// A [GoldenTestGroup] variant for light-mode golden snapshots.
///
/// Uses a white-based panel (`Color(0xFFFFFFFF)`) with dark scenario labels
/// (`Color(0xFF6E6E73)` — iOS secondary label) instead of the dark-mode
/// panel that the standard [GoldenTestGroup] produces.
class LightGoldenTestGroup extends StatelessWidget {
  /// Creates a [LightGoldenTestGroup].
  const LightGoldenTestGroup({
    required this.children,
    this.scenarioConstraints,
    this.columns = 2,
    super.key,
  });

  /// List of test scenarios to display.
  final List<LightGoldenTestScenario> children;

  /// Default constraints applied to each scenario child.
  final BoxConstraints? scenarioConstraints;

  /// Number of columns (when applicable).
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E5EA), // iOS system group background
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final scenario in children)
            if (scenarioConstraints != null && scenario.constraints == null)
              LightGoldenTestScenario(
                name: scenario.name,
                constraints: scenarioConstraints,
                child: scenario.child,
              )
            else
              scenario,
        ],
      ),
    );
  }
}

/// A scenario within a [LightGoldenTestGroup].
///
/// Renders the scenario label in iOS secondary-label gray (`#6E6E73`) so it
/// is legible on the light panel background.
class LightGoldenTestScenario extends StatelessWidget {
  /// Creates a [LightGoldenTestScenario].
  const LightGoldenTestScenario({
    required this.name,
    required this.child,
    this.constraints,
    super.key,
  });

  /// The name / label of the scenario.
  final String name;

  /// The widget under test.
  final Widget child;

  /// Optional constraints for the scenario.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (constraints != null) {
      content = ConstrainedBox(
        constraints: constraints!,
        child: content,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            name,
            style: const TextStyle(
              color: Color(0xFF6E6E73), // iOS secondary label
              fontSize: 13,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
          ),
        ),
        content,
      ],
    );
  }
}

/// Wraps a widget with gradient background AND a glass layer for golden tests
Widget buildWithGradientAndGlass(Widget child,
    {LiquidGlassSettings? settings}) {
  return buildWithGradientBackground(
    AdaptiveLiquidGlassLayer(
      settings: settings ?? defaultTestGlassSettings,
      child: child,
    ),
  );
}

/// Creates a standard test wrapper with MaterialApp for widget tests
Widget createTestApp({
  required Widget child,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ??
        ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.transparent,
        ),
    home: Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
    ),
  );
}

/// Creates a test wrapper with a LiquidGlassLayer configured for testing
Widget createTestAppWithGlassLayer({
  required Widget child,
  LiquidGlassSettings? settings,
  ThemeData? theme,
}) {
  return createTestApp(
    theme: theme,
    child: AdaptiveLiquidGlassLayer(
      settings: settings ?? defaultTestGlassSettings,
      child: child,
    ),
  );
}
