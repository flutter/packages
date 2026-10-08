import 'package:liquid_glass_widgets/widgets/input/glass_text_field.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../shared/test_helpers.dart';

void main() {
  goldenTest(
    'GlassTextField renders correctly',
    fileName: 'glass_text_field',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'default',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassTextField(
                placeholder: 'Enter text...',
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_prefix_icon',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassTextField(
                placeholder: 'Search...',
                prefixIcon: Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_prefix_and_suffix',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassTextField(
                placeholder: 'Email',
                prefixIcon: Icon(Icons.email, color: Colors.white70),
                suffixIcon: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'disabled',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassTextField(
                placeholder: 'Disabled field',
                enabled: false,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
