// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassTabBar Golden Tests', () {
    goldenTest(
      'renders with labels only',
      fileName: 'glass_tab_bar_labels',
      tags: ['golden'],
      constraints: testScenarioConstraints,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'first tab selected',
            child: buildWithGradientBackground(
              Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: GlassSegmentedControl(
                    segments: const [
                      GlassSegment(label: 'Timeline'),
                      GlassSegment(label: 'Mentions'),
                      GlassSegment(label: 'Messages'),
                    ],
                    selectedIndex: 0,
                    onSegmentSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'middle tab selected',
            child: buildWithGradientBackground(
              Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: GlassSegmentedControl(
                    segments: const [
                      GlassSegment(label: 'Timeline'),
                      GlassSegment(label: 'Mentions'),
                      GlassSegment(label: 'Messages'),
                    ],
                    selectedIndex: 1,
                    onSegmentSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders with icons only',
      fileName: 'glass_tab_bar_icons',
      tags: ['golden'],
      constraints: testScenarioConstraints,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'home selected',
            child: buildWithGradientBackground(
              Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: GlassSegmentedControl(
                    segments: const [
                      GlassSegment(icon: Icon(Icons.home)),
                      GlassSegment(icon: Icon(Icons.search)),
                      GlassSegment(icon: Icon(Icons.notifications)),
                      GlassSegment(icon: Icon(Icons.settings)),
                    ],
                    selectedIndex: 0,
                    onSegmentSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders with icons and labels',
      fileName: 'glass_tab_bar_icons_labels',
      tags: ['golden'],
      constraints: testScenarioConstraints,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'first selected',
            child: buildWithGradientBackground(
              Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: GlassSegmentedControl(
                    height: 56,
                    segments: const [
                      GlassSegment(icon: Icon(Icons.home), label: 'Home'),
                      GlassSegment(icon: Icon(Icons.search), label: 'Search'),
                      GlassSegment(icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    selectedIndex: 0,
                    onSegmentSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders with custom styling',
      fileName: 'glass_tab_bar_custom_styling',
      tags: ['golden'],
      constraints: testScenarioConstraints,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom colors',
            child: buildWithGradientBackground(
              Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: GlassSegmentedControl(
                    height: 60,
                    segments: const [
                      GlassSegment(label: 'Tab 1'),
                      GlassSegment(label: 'Tab 2'),
                      GlassSegment(label: 'Tab 3'),
                    ],
                    selectedIndex: 1,
                    onSegmentSelected: (_) {},
                    selectedTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                    unselectedTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    indicatorColor: Colors.blue.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders scrollable with many tabs',
      fileName: 'glass_tab_bar_scrollable',
      tags: ['golden'],
      constraints: testScenarioConstraints,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'many tabs',
            child: buildWithGradientBackground(
              Center(
                child: AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: GlassSegmentedControl.scrollable(
                    segments: List.generate(
                      8,
                      (i) => GlassSegment(label: 'Category ${i + 1}'),
                    ),
                    selectedIndex: 3,
                    onSegmentSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders in standalone mode',
      fileName: 'glass_tab_bar_standalone',
      tags: ['golden'],
      constraints: testScenarioConstraints,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'with own layer',
            child: buildWithGradientBackground(
              Center(
                child: GlassSegmentedControl(
                  useOwnLayer: true,
                  settings: settingsWithoutLighting,
                  segments: const [
                    GlassSegment(label: 'Tab 1'),
                    GlassSegment(label: 'Tab 2'),
                    GlassSegment(label: 'Tab 3'),
                  ],
                  selectedIndex: 1,
                  onSegmentSelected: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
