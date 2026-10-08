import 'package:liquid_glass_widgets/widgets/interactive/glass_button.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_chip.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_icon_button.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_segmented_control.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/glass_tab_bar.dart'
    show GlassSegment;
import 'package:liquid_glass_widgets/widgets/interactive/glass_slider.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_switch.dart';
import 'package:liquid_glass_widgets/widgets/input/glass_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../shared/test_helpers.dart';

void main() {
  goldenTest(
    'GlassButton renders correctly',
    fileName: 'glass_button',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'default',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: Icon(CupertinoIcons.heart),
                onTap: () {},
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'disabled',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: Icon(CupertinoIcons.heart),
                onTap: () {},
                enabled: false,
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'custom_child',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton.custom(
                onTap: () {},
                width: 120,
                height: 48,
                child: const Text(
                  'Custom',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassIconButton renders correctly',
    fileName: 'glass_icon_button',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'circle',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassIconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {},
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'rounded_square',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassIconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
                shape: GlassIconButtonShape.roundedSquare,
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'disabled',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassIconButton(
                icon: Icon(Icons.delete),
                onPressed: null,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassSwitch renders correctly',
    fileName: 'glass_switch',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'off',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSwitch(
                value: false,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'on',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSwitch(
                value: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassChip renders correctly',
    fileName: 'glass_chip',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'default',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassChip(
                label: 'Flutter',
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_icon',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassChip(
                label: 'Favorite',
                icon: Icon(CupertinoIcons.heart_fill),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'selected',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassChip(
                label: 'Selected',
                selected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_delete',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassChip(
                label: 'Tag',
                onDeleted: () {},
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassSlider renders correctly',
    fileName: 'glass_slider',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: '0_percent',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSlider(
                value: 0.0,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: '50_percent',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSlider(
                value: 0.5,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: '100_percent',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSlider(
                value: 1.0,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassSegmentedControl renders correctly',
    fileName: 'glass_segmented_control',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'two_segments',
          child: buildWithGradientBackground(
            GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'Daily'),
                GlassSegment(label: 'Weekly')
              ],
              selectedIndex: 0,
              onSegmentSelected: (_) {},
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'three_segments',
          child: buildWithGradientBackground(
            GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'One'),
                GlassSegment(label: 'Two'),
                GlassSegment(label: 'Three')
              ],
              selectedIndex: 1,
              onSegmentSelected: (_) {},
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassSearchBar renders correctly',
    fileName: 'glass_search_bar',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'default',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassSearchBar(),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_placeholder',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassSearchBar(
                placeholder: 'Search messages',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
