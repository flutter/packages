import '../../shared/test_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassProgressIndicator Golden Tests', () {
    goldenTest(
      'Circular progress indicators',
      fileName: 'glass_progress_indicator_circular',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          // Skip indeterminate (infinite animation causes timeout)
          GoldenTestScenario(
            name: 'circular_determinate_0',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.0,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_determinate_25',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.25,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_determinate_50',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_determinate_75',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.75,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_determinate_100',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Circular progress indicators - sizes',
      fileName: 'glass_progress_indicator_circular_sizes',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          GoldenTestScenario(
            name: 'circular_small',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                    size: 14.0,
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_medium',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                    size: 20.0,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_large',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                    size: 28.0,
                    strokeWidth: 3.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Circular progress indicators - colors',
      fileName: 'glass_progress_indicator_circular_colors',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          GoldenTestScenario(
            name: 'circular_blue',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_green',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'circular_red',
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.circular(
                    value: 0.5,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Linear progress indicators',
      fileName: 'glass_progress_indicator_linear',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          // Skip indeterminate (infinite animation causes timeout)
          GoldenTestScenario(
            name: 'linear_determinate_0',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.0,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_determinate_25',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.25,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_determinate_50',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_determinate_75',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.75,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_determinate_100',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Linear progress indicators - heights',
      fileName: 'glass_progress_indicator_linear_heights',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          GoldenTestScenario(
            name: 'linear_thin',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                    height: 2.0,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_standard',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                    height: 4.0,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_thick',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                    height: 8.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Linear progress indicators - colors',
      fileName: 'glass_progress_indicator_linear_colors',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          GoldenTestScenario(
            name: 'linear_blue',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_green',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'linear_red',
            child: Container(
              width: 400,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 30,
                    blur: 12,
                  ),
                  child: GlassProgressIndicator.linear(
                    value: 0.5,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
