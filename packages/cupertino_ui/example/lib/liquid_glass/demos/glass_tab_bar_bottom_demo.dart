/// Simple demo showcasing GlassBottomBar features:
/// - Magic lens masking effect (MaskingQuality.high)
/// - Icon-only tab support (null labels)
/// - Glass refraction on icons
///
/// For a full-featured example, see example/lib/main.dart
///
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const GlassBottomBarDemoApp()));
}

class GlassBottomBarDemoApp extends StatelessWidget {
  const GlassBottomBarDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Glass Bottom Bar Demo',
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const GlassBottomBarDemoPage(),
    );
  }
}

class GlassBottomBarDemoPage extends StatefulWidget {
  const GlassBottomBarDemoPage({super.key});

  @override
  State<GlassBottomBarDemoPage> createState() => _GlassBottomBarDemoPageState();
}

class _GlassBottomBarDemoPageState extends State<GlassBottomBarDemoPage> {
  int _selectedIndex = 0;
  int _bgQualityIndex = 1; // Default to minimal to showcase decoupled track

  GlassQuality? get _backgroundQuality => switch (_bgQualityIndex) {
        0 => null, // Inherits quality (premium)
        1 => GlassQuality.minimal,
        2 => GlassQuality.standard,
        3 => GlassQuality.premium,
        _ => null,
      };

  String get _bgQualityLabel => switch (_bgQualityIndex) {
        0 => 'Inherit (Premium)',
        1 => 'Minimal (Frosted)',
        2 => 'Standard (2D)',
        3 => 'Premium (3D)',
        _ => 'Unknown',
      };

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: Image.network(
        'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=2070&auto=format&fit=crop',
        fit: BoxFit.cover,
      ),
      statusBarStyle: GlassStatusBarStyle.auto,
      child: GlassScaffold(
        extendBody: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tab $_selectedIndex Selected',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: CupertinoColors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ── Decoupled Track Quality Selector ───────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CupertinoColors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Decoupled Track Quality',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Track: $_bgQualityLabel  ·  Pill: Premium',
                        style: TextStyle(
                          color: CupertinoColors.systemTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoSlidingSegmentedControl<int>(
                        groupValue: _bgQualityIndex,
                        children: const {
                          0: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child:
                                Text('Inherit', style: TextStyle(fontSize: 12)),
                          ),
                          1: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child:
                                Text('Minimal', style: TextStyle(fontSize: 12)),
                          ),
                          2: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('Standard',
                                style: TextStyle(fontSize: 12)),
                          ),
                          3: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child:
                                Text('Premium', style: TextStyle(fontSize: 12)),
                          ),
                        },
                        onValueChanged: (v) {
                          if (v != null) setState(() => _bgQualityIndex = v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _selectedIndex,
          onTabSelected: (index) => setState(() => _selectedIndex = index),
          backgroundQuality: _backgroundQuality,
          // Use distinct colors to verify masking
          selectedIconColor: CupertinoColors.white,
          unselectedIconColor: CupertinoColors.white.withValues(alpha: 0.4),
          indicatorColor: CupertinoColors.activeBlue.withValues(alpha: 0.2),
          maskingQuality: MaskingQuality.high,
          extraButton: GlassTabBarExtraButton.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'Options',
            menuItems: [
              GlassMenuItem(
                icon: const Icon(CupertinoIcons.share),
                title: 'Share',
                onTap: () {},
              ),
              GlassMenuItem(
                icon: const Icon(CupertinoIcons.bookmark),
                title: 'Bookmark',
                onTap: () {},
              ),
              const GlassMenuDivider(),
              GlassMenuItem(
                icon: const Icon(CupertinoIcons.gear),
                title: 'Settings',
                onTap: () {},
              ),
            ],
          ),
          tabs: [
            GlassTab(
              label: 'Home',
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.home),
            ),
            GlassTab(
              // Empty label - should center icon
              label: null,
              icon: Icon(CupertinoIcons.add_circled),
              activeIcon: Icon(CupertinoIcons.add_circled),
            ),
            GlassTab(
              label: 'Profile',
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
            ),
          ],
        ),
      ),
    );
  }
}
