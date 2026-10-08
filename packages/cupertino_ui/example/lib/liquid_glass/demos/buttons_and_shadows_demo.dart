/// Demo for testing GlassButtons, GlassButtonGroups, drop shadows,
/// and the whitenStrength legibility veil.
///
/// This example demonstrates buttons with different shadow elevations
/// in premium quality, and provides a real-time slider to preview
/// the whitenStrength veil on the bottom bar. Scroll to the bottom
/// to see the whiten-at-bottom scroll-boost in action.
///
/// To run: flutter run -t example/lib/main.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const ShadowClippingDemoApp()));
}

class ShadowClippingDemoApp extends StatelessWidget {
  const ShadowClippingDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.light),
      builder: (context, child) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: child!,
      ),
      home: const ShadowClippingDemoPage(),
    );
  }
}

class ShadowClippingDemoPage extends StatefulWidget {
  const ShadowClippingDemoPage({super.key});

  @override
  State<ShadowClippingDemoPage> createState() => _ShadowClippingDemoPageState();
}

class _ShadowClippingDemoPageState extends State<ShadowClippingDemoPage> {
  int _tabIndex = 0;
  bool _searchActive = false;
  double _whitenStrength = 0.30;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── GPU Shadows Demo ─────────────────────────────────────────────────────
    // Drop shadows on glass surfaces are only visible in Light Mode, since
    // dark mode backgrounds are naturally too dark for a black shadow to cast.
    //
    // We force this demo into Light Mode so the GPU SDF shadows are always visible.
    return CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        brightness: Brightness.light,
      ),
      child: GlassScaffold(
        background: Container(
          color: const Color(0xFFF0F0F5), // Light background to see shadows
        ),
        appBar: const GlassAppBar(
          title: Text('Buttons & Shadows Demo'),
        ),
        bottomBar: GlassTabBar.searchable(
          selectedIndex: _tabIndex,
          onTabSelected: (idx) => setState(() {
            _tabIndex = idx;
            _searchActive = false;
          }),
          isSearchActive: _searchActive,
          searchConfig: GlassSearchBarConfig(
            onSearchToggle: (active) => setState(() => _searchActive = active),
          ),
          // ── Whiten veil — driven by the slider in the body ──
          settings: LiquidGlassSettings(
            shadowElevation: 2.0,
            blur: 15,
            thickness: 20,
            whitenStrength: _whitenStrength,
          ),
          // ── Whiten-at-bottom — scroll to the end to see the boost ──
          scrollController: _scrollController,
          whitenAtBottom: true,
          tabs: [
            GlassTab(
              icon: Icon(CupertinoIcons.house),
              label: 'Home',
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.compass),
              label: 'Discover',
            ),
          ],
        ),
        body: AdaptiveLiquidGlassLayer(
          settings: const LiquidGlassSettings(
            thickness: 20,
            blur: 8,
          ),
          quality: GlassQuality.premium,
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Premium Buttons with Elevations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Shadows should visibly expand around the buttons and not be cut off at the edge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.black.withValues(alpha: 0.54),
                    ),
                  ),
                  SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ElevatedButton(elevation: 1.0),
                      _ElevatedButton(elevation: 2.0),
                      _ElevatedButton(elevation: 4.0),
                    ],
                  ),
                  SizedBox(height: 64),
                  Text(
                    'Glass Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: GlassMenu(
                      settings: const LiquidGlassSettings(
                        thickness: 20,
                        blur: 12,
                        shadowElevation: 1.0,
                      ),
                      quality: GlassQuality.premium,
                      items: [
                        GlassMenuItem(
                          title: 'Option 1',
                          icon: Icon(CupertinoIcons.star),
                          onTap: () {},
                        ),
                        GlassMenuItem(
                          title: 'Option 2',
                          icon: Icon(CupertinoIcons.heart),
                          onTap: () {},
                        ),
                        GlassMenuItem(
                          title: 'Option 3',
                          titleStyle:
                              TextStyle(color: CupertinoColors.destructiveRed),
                          icon: Icon(CupertinoIcons.trash,
                              color: CupertinoColors.destructiveRed),
                          onTap: () {},
                        ),
                      ],
                      triggerBuilder: (context, toggle) => GlassButton(
                        icon: Icon(CupertinoIcons.ellipsis),
                        width: 56,
                        height: 56,
                        iconSize: 24,
                        iconColor:
                            CupertinoColors.black.withValues(alpha: 0.87),
                        onTap: toggle, // Correctly wire up the toggle function
                        useOwnLayer: true, // Required for standalone shadows
                        settings: const LiquidGlassSettings(
                          shadowElevation: 1.0,
                          glassColor: Color(0x99FFFFFF), // Make glass visible
                        ),
                        quality: GlassQuality.premium,
                      ),
                    ),
                  ),
                  SizedBox(height: 64),
                  Text(
                    'Button Groups',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  SizedBox(height: 24),
                  GlassButtonGroup.icons(
                    direction: Axis.horizontal,
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    settings: const LiquidGlassSettings(
                      shadowElevation: 2.0,
                    ),
                    items: [
                      GlassButtonGroupItem(
                        icon: Icon(CupertinoIcons.reply),
                        onTap: () {},
                      ),
                      GlassButtonGroupItem(
                        icon: Icon(CupertinoIcons.heart),
                        onTap: () {},
                      ),
                      GlassButtonGroupItem(
                        icon: Icon(CupertinoIcons.share),
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 64),
                  Text(
                    'Wide Button',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  SizedBox(height: 24),
                  GlassButton.custom(
                    width: 300,
                    height: 64,
                    shape: const LiquidRoundedRectangle(
                        borderRadius: 12), // Gentle corner radius
                    onTap: () {},
                    useOwnLayer: true,
                    settings: const LiquidGlassSettings(
                      shadowElevation: 1.0,
                      thickness: 20,
                      blur: 10,
                      glassColor: Color(0x99FFFFFF),
                    ),
                    quality: GlassQuality.premium,
                    child: Text(
                      'Wide Button with Shadow',
                      style: TextStyle(
                        color: CupertinoColors.black.withValues(alpha: 0.87),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 64),
                  // ── Whiten Strength slider ──────────────────────────
                  Text(
                    'Whiten Strength (Legibility Veil)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Drag the slider to lift the bottom bar toward white. '
                    'Scroll to the bottom to see the whiten-at-bottom boost.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.black.withValues(alpha: 0.54),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '0.0',
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                CupertinoColors.black.withValues(alpha: 0.54)),
                      ),
                      Expanded(
                        child: CupertinoSlider(
                          min: 0.0,
                          max: 1.0,
                          value: _whitenStrength,
                          onChanged: (v) => setState(() => _whitenStrength = v),
                        ),
                      ),
                      Text(
                        '1.0',
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                CupertinoColors.black.withValues(alpha: 0.54)),
                      ),
                    ],
                  ),
                  Text(
                    'whitenStrength: ${_whitenStrength.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Side-by-side comparison cards
                  Row(
                    children: [
                      Expanded(
                        child: _WhitenCard(
                          label: 'With Whiten',
                          whitenStrength: _whitenStrength,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _WhitenCard(
                          label: 'No Whiten',
                          whitenStrength: 0.0,
                        ),
                      ),
                    ],
                  ),
                  // Extra height so the page is scrollable to trigger
                  // the whiten-at-bottom boost on the bar.
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      '↓ Scroll here to trigger whiten-at-bottom ↓',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.black.withValues(alpha: 0.38),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ElevatedButton extends StatelessWidget {
  const _ElevatedButton({required this.elevation});

  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassButton(
          icon: Icon(CupertinoIcons.heart_fill),
          width: 64,
          height: 64,
          iconSize: 28,
          quality: GlassQuality.premium,
          useOwnLayer:
              true, // Required for standalone shadows in premium quality
          iconColor: CupertinoColors.black.withValues(alpha: 0.87),
          onTap: () {},
          settings: LiquidGlassSettings(
            shadowElevation: elevation,
            thickness: 20,
            blur: 10,
            glassColor: const Color(0x99FFFFFF), // Make glass visible
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Elev $elevation',
          style: TextStyle(
            color: CupertinoColors.black.withValues(alpha: 0.54),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Side-by-side comparison card: a small glass surface over a colorful
/// background, with the specified whitenStrength applied.
class _WhitenCard extends StatelessWidget {
  const _WhitenCard({
    required this.label,
    required this.whitenStrength,
  });

  final String label;
  final double whitenStrength;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Stack(
            children: [
              // Colorful content behind the glass
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFF4ECDC4),
                          Color(0xFF45B7D1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Content Behind Glass',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Glass overlay with whiten
              Positioned.fill(
                child: AdaptiveGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  quality: GlassQuality.premium,
                  settings: LiquidGlassSettings(
                    blur: 12,
                    thickness: 20,
                    whitenStrength: whitenStrength,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black.withValues(alpha: 0.54),
          ),
        ),
        Text(
          whitenStrength.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.black.withValues(alpha: 0.38),
          ),
        ),
      ],
    );
  }
}
