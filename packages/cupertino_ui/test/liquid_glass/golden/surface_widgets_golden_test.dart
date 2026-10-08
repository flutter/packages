import 'package:liquid_glass_widgets/widgets/interactive/glass_button.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/glass_app_bar.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/glass_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../shared/test_helpers.dart';

void main() {
  goldenTest(
    'GlassAppBar renders correctly',
    fileName: 'glass_app_bar',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints:
          const BoxConstraints.tightFor(width: 400, height: 100),
      children: [
        GoldenTestScenario(
          name: 'centered_title',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const Material(
                color: Colors.transparent,
                child: GlassAppBar(
                  title: Text(
                    'App Title',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_actions',
          child: buildWithGradientBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: Material(
                color: Colors.transparent,
                child: GlassAppBar(
                  title: const Text(
                    'Title',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    GlassButton(icon: Icon(Icons.search), onTap: () {}),
                    GlassButton(icon: Icon(Icons.more_horiz), onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassTabBar.bottom renders correctly',
    fileName: 'glass_tab_bar_bottom',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints:
          const BoxConstraints.tightFor(width: 400, height: 120),
      children: [
        GoldenTestScenario(
          name: 'three_tabs',
          child: buildWithGradientBackground(
            GlassTabBar.bottom(
              tabs: const [
                GlassTab(
                  label: 'Home',
                  icon: Icon(CupertinoIcons.home),
                ),
                GlassTab(
                  label: 'Search',
                  icon: Icon(CupertinoIcons.search),
                ),
                GlassTab(
                  label: 'Profile',
                  icon: Icon(CupertinoIcons.person),
                ),
              ],
              selectedIndex: 0,
              onTabSelected: (_) {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'with_extra_button',
          child: buildWithGradientBackground(
            GlassTabBar.bottom(
              tabs: const [
                GlassTab(
                  label: 'Home',
                  icon: Icon(CupertinoIcons.home),
                ),
                GlassTab(
                  label: 'Search',
                  icon: Icon(CupertinoIcons.search),
                ),
              ],
              selectedIndex: 0,
              onTabSelected: (_) {},
              extraButton: GlassTabBarExtraButton(
                icon: Icon(CupertinoIcons.add),
                label: 'Add',
                onTap: () {},
              ),
            ),
          ),
        ),
        // Expand mode (tabWidth: null) — kept as a regression sentinel.
        // Verifies that the legacy full-width behaviour is not accidentally
        // broken when the default compact sizing changes.
        GoldenTestScenario(
          name: 'three_tabs_expand',
          child: buildWithGradientBackground(
            GlassTabBar.bottom(
              tabs: const [
                GlassTab(
                  label: 'Home',
                  icon: Icon(CupertinoIcons.home),
                ),
                GlassTab(
                  label: 'Search',
                  icon: Icon(CupertinoIcons.search),
                ),
                GlassTab(
                  label: 'Profile',
                  icon: Icon(CupertinoIcons.person),
                ),
              ],
              tabWidth: null, // explicit expand — overrides the 88.0 default

              selectedIndex: 0,
              onTabSelected: (_) {},
            ),
          ),
        ),
      ],
    ),
  );
}
