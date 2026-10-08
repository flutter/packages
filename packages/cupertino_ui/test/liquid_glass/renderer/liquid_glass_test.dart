// Adapted from liquid_glass_renderer 0.2.0-dev.4
// Original: test/src/liquid_glass_test.dart
// Changes:
//   - Import paths updated to liquid_glass_widgets internal paths
//   - blend parameter moved from LiquidGlassSettings to LiquidGlassBlendGroup
//   - shared.dart helpers inlined from test/shared/test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass.dart';

import '../shared/test_helpers.dart';

void main() {
  group('LiquidGlass', () {
    test('can be used', () async {
      expect(
        const LiquidGlass(shape: LiquidOval(), child: SizedBox()),
        isA<Widget>(),
      );
    });

    testWidgets('renders cleanly with bodyMode: GlassBodyMode.clear',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlass.withOwnLayer(
              shape: const LiquidOval(),
              settings: const LiquidGlassSettings(
                bodyMode: GlassBodyMode.clear,
                blur: 0,
                glassColor: Color(0xD9C3E0F5),
              ),
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      expect(find.byType(LiquidGlass), findsOneWidget);
    });

    group('LiquidRoundedSuperellipse', () {
      goldenTest(
        'should render a rounded superellipse with different thickness',
        fileName: 'rounded_superellipse_thicknesses',
        pumpBeforeTest: pumpOnce,
        builder: () => GoldenTestGroup(
          scenarioConstraints: testScenarioConstraints,
          children: [
            for (final thickness in [0.0, 5, 10, 15, 20, 40, 100])
              GoldenTestScenario(
                name: 'thickness ${thickness.toStringAsFixed(0)}px',
                child: buildWithGridPaper(
                  LiquidGlass.withOwnLayer(
                    settings: settingsWithoutLighting.copyWith(
                      thickness: thickness.toDouble(),
                    ),
                    shape: const LiquidRoundedSuperellipse(
                      borderRadius: 100,
                    ),
                    child: const SizedBox.square(
                      dimension: 400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

      goldenTest(
        'should render a rounded superellipse with different radii',
        fileName: 'rounded_superellipse_radii',
        pumpBeforeTest: pumpOnce,
        builder: () {
          final radii = [0.0, 50.0, 100.0, 200.0];
          return GoldenTestGroup(
            scenarioConstraints: testScenarioConstraints,
            children: [
              for (final radius in radii)
                GoldenTestScenario(
                  name: 'square shape radius ${radius.toStringAsFixed(0)}px',
                  child: buildWithGridPaper(
                    LiquidGlass.withOwnLayer(
                      settings: settingsWithoutLighting.copyWith(
                        thickness: 2,
                        glassColor: Colors.blue.withValues(alpha: 0.5),
                      ),
                      glassContainsChild: true,
                      shape: LiquidRoundedSuperellipse(
                        borderRadius: radius,
                      ),
                      child: SizedBox.square(
                        dimension: 400,
                        child: Container(
                          decoration: ShapeDecoration(
                            color: Colors.red.withValues(alpha: 0.5),
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              for (final radius in radii)
                GoldenTestScenario(
                  name: 'wide shape radius ${radius.toStringAsFixed(0)}px',
                  child: buildWithGridPaper(
                    LiquidGlassLayer(
                      settings: settingsWithoutLighting.copyWith(
                        thickness: 2,
                        glassColor: Colors.blue.withValues(alpha: 0.5),
                      ),
                      child: LiquidGlassBlendGroup(
                        child: LiquidGlass.grouped(
                          glassContainsChild: true,
                          shape: LiquidRoundedSuperellipse(
                            borderRadius: radius,
                          ),
                          child: SizedBox.fromSize(
                            size: const Size(400, 200),
                            child: Container(
                              decoration: ShapeDecoration(
                                color: Colors.red.withValues(alpha: 0.5),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });

    group('merging', () {
      goldenTest(
        'shapes merge with different blend values',
        fileName: 'merging_blend_values',
        pumpBeforeTest: pumpOnce,
        builder: () => GoldenTestGroup(
          scenarioConstraints: testScenarioConstraints,
          children: [
            // blend is set on LiquidGlassBlendGroup, not LiquidGlassSettings
            for (final blend in [0.0, 40.0, 80.0, 100.0])
              GoldenTestScenario(
                name: 'blend $blend',
                child: buildWithGridPaper(
                  LiquidGlassLayer(
                    settings: settingsWithoutLighting.copyWith(
                      glassColor: Colors.red.withValues(alpha: 0.5),
                    ),
                    child: LiquidGlassBlendGroup(
                      blend: blend,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LiquidGlass.grouped(
                            shape: LiquidOval(),
                            child: SizedBox.square(dimension: 100),
                          ),
                          LiquidGlass.grouped(
                            shape: LiquidRoundedRectangle(
                              borderRadius: 20,
                            ),
                            child: SizedBox.square(dimension: 100),
                          ),
                          LiquidGlass.grouped(
                            shape: LiquidRoundedSuperellipse(
                              borderRadius: 20,
                            ),
                            child: SizedBox.square(dimension: 100),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  });
}
