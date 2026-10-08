// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../shared/test_helpers.dart';

/// Light-mode golden snapshots for key widgets.
///
/// Each test targets a widget that has a materially different codepath in
/// [Brightness.light] — including inverse-clipped drop shadows, doubled
/// [GlassDefaults.ambientBaseLight], Rec.709 luminance-based adaptive glass
/// strength (0.8×), and inverted glyph colors.
///
/// These tests intentionally exercise subsystems that the existing all-dark
/// golden suite cannot reach:
///   - [AdaptiveGlass._wrapWithLightModeShadow] / [_InverseShapeClipper]
///   - [TabBarBottomPillState.buildShadowOverlay] / [_InverseBarClipper]
///   - [GlassButton] ambient base light doubling (0.14 vs 0.07 in dark)
///   - [GlassToolbar] hairline divider tinting
///
/// Golden images are generated locally on macOS (Impeller renderer).
/// They are excluded from CI via `dart_test.yaml` tag filtering.
void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. GlassButton — light mode
  //
  // Exercises:
  //   - ambientBaseLight = 0.14 (vs 0.07 in dark)
  //   - nativeGlowColor = 0x1AFFFFFF (vs 0x12FFFFFF in dark)
  //   - CupertinoColors.label → dark glyph on light surface
  // ─────────────────────────────────────────────────────────────────────────
  goldenTestLight(
    'GlassButton renders correctly in light mode',
    fileName: 'light_glass_button',
    tags: ['golden'],
    pumpBeforeTest: pumpOnce,
    builder: () => LightGoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        LightGoldenTestScenario(
          name: 'default',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
              ),
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'prominent',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart_fill),
                onTap: () {},
                style: GlassButtonStyle.prominent,
              ),
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'disabled',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
                enabled: false,
              ),
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'custom_child',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton.custom(
                onTap: () {},
                width: 120,
                height: 44,
                child: const Text(
                  'Light Mode',
                  style: TextStyle(
                    color: CupertinoColors.label,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 2. GlassAppBar — light mode
  //
  // Exercises:
  //   - Dark title / subtitle text (CupertinoColors.label)
  //   - Hairline divider in light-mode tint
  // ─────────────────────────────────────────────────────────────────────────
  goldenTestLight(
    'GlassAppBar renders correctly in light mode',
    fileName: 'light_glass_app_bar',
    tags: ['golden'],
    pumpBeforeTest: pumpOnce,
    builder: () => LightGoldenTestGroup(
      scenarioConstraints:
          const BoxConstraints.tightFor(width: 400, height: 100),
      children: [
        LightGoldenTestScenario(
          name: 'centered_title',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const Material(
                color: Colors.transparent,
                child: GlassAppBar(
                  title: Text('App Title'),
                ),
              ),
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'with_actions',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: Material(
                color: Colors.transparent,
                child: GlassAppBar(
                  title: const Text('Title'),
                  actions: [
                    GlassButton(
                      icon: const Icon(CupertinoIcons.search),
                      onTap: () {},
                    ),
                    GlassButton(
                      icon: const Icon(CupertinoIcons.ellipsis),
                      onTap: () {},
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

  // ─────────────────────────────────────────────────────────────────────────
  // 3. GlassTabBar.bottom — light mode
  //
  // Exercises:
  //   - TabBarBottomPillState.buildShadowOverlay (dark mode: returns null)
  //   - _InverseBarClipper — paints external drop shadow, inverse-clipped so
  //     the glass blur doesn't sample its own shadow
  //   - Label / icon color: CupertinoColors.label (dark glyph on light surface)
  // ─────────────────────────────────────────────────────────────────────────
  goldenTestLight(
    'GlassTabBar.bottom renders correctly in light mode',
    fileName: 'light_glass_tab_bar_bottom',
    tags: ['golden'],
    pumpBeforeTest: pumpOnce,
    builder: () => LightGoldenTestGroup(
      scenarioConstraints:
          const BoxConstraints.tightFor(width: 400, height: 120),
      children: [
        LightGoldenTestScenario(
          name: 'three_tabs',
          child: buildWithLightBackground(
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
        LightGoldenTestScenario(
          name: 'middle_selected',
          child: buildWithLightBackground(
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
              selectedIndex: 1,
              onTabSelected: (_) {},
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'with_extra_button',
          child: buildWithLightBackground(
            GlassTabBar.bottom(
              tabs: const [
                GlassTab(
                  label: 'Home',
                  icon: Icon(CupertinoIcons.home),
                ),
                GlassTab(
                  label: 'Library',
                  icon: Icon(CupertinoIcons.book),
                ),
              ],
              selectedIndex: 0,
              onTabSelected: (_) {},
              extraButton: GlassTabBarExtraButton(
                icon: const Icon(CupertinoIcons.add),
                label: 'Add',
                onTap: () {},
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 4. AdaptiveGlass / GlassCard — light mode
  //
  // Exercises:
  //   - AdaptiveGlass._wrapWithLightModeShadow (dark mode: returns widget unchanged)
  //   - _InverseShapeClipper — external drop shadow on rounded-rect glass pill
  //   - _FrostedFallback alpha ceiling 0.55 (light backer)
  //   - Rec.709 adaptive glass strength: 0.8× on light backgrounds
  // ─────────────────────────────────────────────────────────────────────────
  goldenTestLight(
    'AdaptiveGlass renders correctly in light mode',
    fileName: 'light_adaptive_glass',
    tags: ['golden'],
    pumpBeforeTest: pumpOnce,
    builder: () => LightGoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        LightGoldenTestScenario(
          name: 'glass_card',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Light Mode Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Drop shadow via _InverseShapeClipper',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'glass_container',
          child: buildWithLightBackground(
            AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: const GlassContainer(
                width: 200,
                height: 100,
                child: Center(
                  child: Text(
                    'Glass Container',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 5. GlassToolbar — light mode
  //
  // Exercises:
  //   - GlassTheme.brightnessOf: divider tint (light: Color(0xFF3C3C43) @ 36%)
  //   - Hairline divider separating toolbar from scroll content
  //   - Surface glass against high-luminance iOS grouped background
  // ─────────────────────────────────────────────────────────────────────────
  goldenTestLight(
    'GlassToolbar renders correctly in light mode',
    fileName: 'light_glass_toolbar',
    tags: ['golden'],
    pumpBeforeTest: pumpOnce,
    builder: () => LightGoldenTestGroup(
      scenarioConstraints:
          const BoxConstraints.tightFor(width: 400, height: 80),
      children: [
        LightGoldenTestScenario(
          name: 'two_actions',
          child: buildWithLightBackground(
            GlassToolbar(
              children: [
                GlassButton(
                  icon: const Icon(CupertinoIcons.share),
                  onTap: () {},
                  label: 'Share',
                ),
                const Spacer(),
                GlassButton(
                  icon: const Icon(CupertinoIcons.add),
                  onTap: () {},
                  label: 'New',
                ),
              ],
            ),
          ),
        ),
        LightGoldenTestScenario(
          name: 'three_actions',
          child: buildWithLightBackground(
            GlassToolbar(
              children: [
                GlassButton(
                  icon: const Icon(CupertinoIcons.arrow_left),
                  onTap: () {},
                ),
                const Spacer(),
                GlassButton(
                  icon: const Icon(CupertinoIcons.star),
                  onTap: () {},
                ),
                const Spacer(),
                GlassButton(
                  icon: const Icon(CupertinoIcons.arrow_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
