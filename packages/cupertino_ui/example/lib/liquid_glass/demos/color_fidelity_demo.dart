// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT

/// Color Fidelity & Decoupled Quality Showcase (Issue #269).
///
/// Demonstrates:
///   1. [GlassBodyMode.clear] vs [GlassBodyMode.adaptive] (Apple `Glass.clear` vs `Glass.regular`).
///      Addresses GitHub Issue #269: when blur=0, clear mode composites the exact hex tint
///      without ambient luminance shift, while retaining specular highlights, Fresnel sheen,
///      and 3D meniscus edge refraction.
///   2. Decoupled [GlassTabBar.backgroundQuality]: tab bar containers can render with lightweight
///      frosted glass (e.g. GlassQuality.minimal) while the selection indicator retains full
///      liquid glass refraction (GlassQuality.premium).
///
/// To run standalone:
///   flutter run -t example/lib/demos/color_fidelity_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const ColorFidelityDemoApp()));
}

class ColorFidelityDemoApp extends StatelessWidget {
  const ColorFidelityDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Color Fidelity & Decoupled Quality',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const ColorFidelityDemoPage(),
    );
  }
}

class ColorFidelityDemoPage extends StatefulWidget {
  const ColorFidelityDemoPage({super.key});

  @override
  State<ColorFidelityDemoPage> createState() => _ColorFidelityDemoPageState();
}

class _ColorFidelityDemoPageState extends State<ColorFidelityDemoPage> {
  // ── Color fidelity state (Issue #269) ──────────────────────────────────────
  GlassBodyMode _bodyMode = GlassBodyMode.clear;
  double _blur = 0.0;
  double _thickness = 22.0;
  double _lightIntensity = 0.8;
  Color _selectedColor = const Color(0xD9C3E0F5); // Exact color from Issue #269
  GlassQuality _selectedQuality = GlassQuality.premium;

  // ── Tab bar decoupled quality state ────────────────────────────────────────
  int _selectedTab = 0;
  int _trackQualityIndex =
      1; // 0: null (inherit), 1: minimal, 2: standard, 3: premium

  GlassQuality? get _trackQuality => switch (_trackQualityIndex) {
        0 => null,
        1 => GlassQuality.minimal,
        2 => GlassQuality.standard,
        3 => GlassQuality.premium,
        _ => null,
      };

  String get _trackQualityName => switch (_trackQualityIndex) {
        0 => 'Inherit (Premium)',
        1 => 'Minimal (Frosted)',
        2 => 'Standard (2D)',
        3 => 'Premium (3D Liquid)',
        _ => 'Unknown',
      };

  static const List<(String, Color)> _swatches = [
    ('Issue #269 Blue', Color(0xD9C3E0F5)),
    ('Pure Frost White', Color(0xD9FFFFFF)),
    ('Electric Cyan', Color(0xD900F5D4)),
    ('Neon Magenta', Color(0xD9F72585)),
    ('Sunset Amber', Color(0xD9FF9E00)),
    ('Obsidian Noir', Color(0xD91E1E24)),
  ];

  @override
  Widget build(BuildContext context) {
    final adaptiveSettings = LiquidGlassSettings(
      bodyMode: GlassBodyMode.adaptive,
      blur: _blur,
      thickness: _thickness,
      lightIntensity: _lightIntensity,
      glassColor: _selectedColor,
    );

    final clearSettings = LiquidGlassSettings(
      bodyMode: GlassBodyMode.clear,
      blur: _blur,
      thickness: _thickness,
      lightIntensity: _lightIntensity,
      glassColor: _selectedColor,
    );

    final activeSettings =
        _bodyMode == GlassBodyMode.clear ? clearSettings : adaptiveSettings;

    return GlassPage(
      background: Stack(
        fit: StackFit.expand,
        children: [
          // High-contrast background pattern to reveal refraction & color fidelity
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: _HighContrastPatternPainter(),
            child: const SizedBox.expand(),
          ),
        ],
      ),
      child: GlassScaffold(
        extendBody: true,
        appBar: const GlassAppBar.pinned(
          title: Text('Color Fidelity & Quality'),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            children: [
              // ── Header Banner ───────────────────────────────────────────────
              _buildHeaderBanner(),
              const SizedBox(height: 16),

              // ── 1. Side-by-Side Comparison (Issue #269) ────────────────────
              _buildSectionTitle('ISSUE #269: BLUR = 0 COLOR FIDELITY'),
              const SizedBox(height: 8),
              _buildComparisonCards(adaptiveSettings, clearSettings),
              const SizedBox(height: 20),

              // ── 2. Live Interactive Tuner ──────────────────────────────────
              _buildSectionTitle('SURFACE PARAMETERS & BODY MODE'),
              const SizedBox(height: 8),
              _buildTunerCard(activeSettings),
              const SizedBox(height: 20),

              // ── 3. Decoupled Track Quality in GlassTabBar ──────────────────
              _buildSectionTitle('DECOUPLED TRACK QUALITY IN GLASSTABBAR'),
              const SizedBox(height: 8),
              _buildDecoupledTrackExplainer(),
              const SizedBox(height: 12),
            ],
          ),
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _selectedTab,
          onTabSelected: (i) => setState(() => _selectedTab = i),
          quality: GlassQuality.premium,
          backgroundQuality: _trackQuality,
          selectedIconColor: CupertinoColors.white,
          unselectedIconColor: CupertinoColors.white.withValues(alpha: 0.4),
          indicatorColor: CupertinoColors.activeBlue.withValues(alpha: 0.25),
          tabs: const [
            GlassTab(icon: Icon(CupertinoIcons.sparkles), label: 'Fidelity'),
            GlassTab(
                icon: Icon(CupertinoIcons.slider_horizontal_3), label: 'Tuner'),
            GlassTab(icon: Icon(CupertinoIcons.layers_alt), label: 'Decoupled'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: CupertinoColors.activeBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'iOS 26 Liquid Glass Color Fidelity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'With GlassBodyMode.clear (Apple Glass.clear), glassColor compositing bypasses adaptive luminance and saturation drift when blur=0, matching the exact designer hex while preserving 3D meniscus refraction and specular sheen.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: CupertinoColors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCards(
    LiquidGlassSettings adaptiveSettings,
    LiquidGlassSettings clearSettings,
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Left: Adaptive (Glass.regular)
            Expanded(
              child: _buildGlassCard(
                title: 'Adaptive (Glass.regular)',
                subtitle: 'Ambient & light scaled',
                badgeColor: CupertinoColors.systemOrange,
                settings: adaptiveSettings,
              ),
            ),
            const SizedBox(width: 12),
            // Right: Clear (Glass.clear)
            Expanded(
              child: _buildGlassCard(
                title: 'Clear (Glass.clear)',
                subtitle: 'Exact hex fidelity',
                badgeColor: CupertinoColors.activeGreen,
                settings: clearSettings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Reference Swatch: raw Flutter Container with exact color
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: CupertinoColors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: CupertinoColors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: CupertinoColors.white.withValues(alpha: 0.3)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reference Raw Overlay (100% Target Hex)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                    Text(
                      'Clear mode matches this color exactly; adaptive applies optical luminance shift.',
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required String title,
    required String subtitle,
    required Color badgeColor,
    required LiquidGlassSettings settings,
  }) {
    return AdaptiveGlass(
      quality: _selectedQuality,
      settings: settings,
      shape: const LiquidRoundedSuperellipse(borderRadius: 16),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
              ),
              child: Text(
                settings.bodyMode.name.toUpperCase(),
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTunerCard(LiquidGlassSettings currentSettings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: CupertinoColors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body Mode Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Body Mode',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoSlidingSegmentedControl<GlassBodyMode>(
                groupValue: _bodyMode,
                children: const {
                  GlassBodyMode.adaptive: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text('Adaptive', style: TextStyle(fontSize: 12)),
                  ),
                  GlassBodyMode.clear: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                },
                onValueChanged: (m) {
                  if (m != null) setState(() => _bodyMode = m);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quality Tier Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quality Tier',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoSlidingSegmentedControl<GlassQuality>(
                groupValue: _selectedQuality,
                children: const {
                  GlassQuality.premium: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text('Premium', style: TextStyle(fontSize: 12)),
                  ),
                  GlassQuality.standard: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text('Standard', style: TextStyle(fontSize: 12)),
                  ),
                  GlassQuality.minimal: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text('Minimal', style: TextStyle(fontSize: 12)),
                  ),
                },
                onValueChanged: (q) {
                  if (q != null) setState(() => _selectedQuality = q);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Blur slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Backdrop Blur: ${_blur.toStringAsFixed(1)}px',
                style:
                    const TextStyle(color: CupertinoColors.white, fontSize: 13),
              ),
              if (_blur == 0.0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ISSUE #269 USE CASE',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          CupertinoSlider(
            value: _blur,
            min: 0.0,
            max: 20.0,
            onChanged: (v) => setState(() => _blur = v),
          ),
          const SizedBox(height: 8),

          // Thickness slider
          Text(
            'Thickness (Refraction): ${_thickness.toStringAsFixed(0)}px',
            style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
          ),
          CupertinoSlider(
            value: _thickness,
            min: 0.0,
            max: 50.0,
            onChanged: (v) => setState(() => _thickness = v),
          ),
          const SizedBox(height: 8),

          // Light intensity slider
          Text(
            'Light Intensity (Specular): ${_lightIntensity.toStringAsFixed(2)}',
            style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
          ),
          CupertinoSlider(
            value: _lightIntensity,
            min: 0.0,
            max: 2.0,
            onChanged: (v) => setState(() => _lightIntensity = v),
          ),
          const SizedBox(height: 12),

          // Swatches
          const Text(
            'Color Tint Swatches',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _swatches.map((swatch) {
              final isSelected = _selectedColor == swatch.$2;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = swatch.$2),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: swatch.$2.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.white.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    swatch.$1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: swatch.$2.computeLuminance() > 0.5
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDecoupledTrackExplainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: CupertinoColors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.layers,
                  color: CupertinoColors.systemTeal, size: 20),
              const SizedBox(width: 8),
              const Text(
                'GlassTabBar.backgroundQuality',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Decouples the tab bar\'s container track from the animated selection indicator. You can set the track to lightweight minimal frosted glass while the sliding indicator maintains full 3D liquid refraction.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Active Track Quality: $_trackQualityName',
            style: const TextStyle(
              color: CupertinoColors.systemTeal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: _trackQualityIndex,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('Inherit', style: TextStyle(fontSize: 11)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('Minimal', style: TextStyle(fontSize: 11)),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('Standard', style: TextStyle(fontSize: 11)),
              ),
              3: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('Premium', style: TextStyle(fontSize: 11)),
              ),
            },
            onValueChanged: (v) {
              if (v != null) setState(() => _trackQualityIndex = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: CupertinoColors.white.withValues(alpha: 0.6),
      ),
    );
  }
}

/// Grid/checker painter to reveal refraction, transparency, and color fidelity.
class _HighContrastPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
