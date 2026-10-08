import 'package:liquid_glass_widgets/widgets/containers/glass_card.dart';
import 'package:liquid_glass_widgets/widgets/containers/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../shared/test_helpers.dart';

void main() {
  goldenTest(
    'GlassContainer renders correctly',
    fileName: 'glass_container',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'default',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassContainer(
                width: 200,
                height: 150,
                child: Center(
                  child: Text(
                    'Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_padding',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassContainer(
                width: 200,
                height: 150,
                padding: EdgeInsets.all(24),
                child: Text(
                  'Padded\nContainer',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassCard renders correctly',
    fileName: 'glass_card',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'default',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Card Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Card content goes here',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'no_padding',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassCard(
                padding: EdgeInsets.zero,
                width: 200,
                height: 150,
                child: Center(
                  child: Text(
                    'No Padding',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
