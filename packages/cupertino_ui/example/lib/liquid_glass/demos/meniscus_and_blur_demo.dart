// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT

/// Meniscus Rim Darkening & 24-Tap Progressive Blur showcase.
///
/// Demonstrates [LiquidGlassSettings.edgeAbsorption] across every interactive
/// component that uses [AnimatedGlassIndicator]:
///   • GlassCard (static glass surface)
///   • GlassSegmentedControl (animated pill)
///   • GlassSlider (thumb indicator)
///   • GlassSwitch (thumb indicator)
///   • ProgressiveBlur (24-tap IIR optimisation)
///
/// All sliders drive live shader uniforms — no hot-reload required.
///
/// To run directly:
///   flutter run -t example/lib/demos/meniscus_and_blur_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const MeniscusAndBlurDemoApp()));
}

class MeniscusAndBlurDemoApp extends StatelessWidget {
  const MeniscusAndBlurDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Meniscus & Blur Showcase',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: MeniscusAndBlurDemoPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class MeniscusAndBlurDemoPage extends StatefulWidget {
  const MeniscusAndBlurDemoPage({super.key});

  @override
  State<MeniscusAndBlurDemoPage> createState() =>
      _MeniscusAndBlurDemoPageState();
}

class _MeniscusAndBlurDemoPageState extends State<MeniscusAndBlurDemoPage> {
  // ── Tunable shader parameters ──────────────────────────────────────────────
  double _edgeAbsorption = 0.0;
  double _fresnelStrength = 1.0;
  double _thickness = 25.0;
  double _blur = 12.0;

  // ── Widget state ───────────────────────────────────────────────────────────
  int _segmentIndex = 0;
  int _tabBarPillIndex = 0;
  int _tabBarNavIndex = 1;
  double _sliderValue = 0.55;
  bool _switchValue = true;
  bool _switch2Value = false;
  int _backgroundIndex = 1;
  bool _isDarkMode = true;

  static const List<(String, List<Color>)> _backgrounds = [
    (
      'Sunset Glow',
      [
        Color(0xFFFF5E3A),
        Color(0xFFFF2A68),
        Color(0xFF8E2DE2),
        Color(0xFF4A00E0)
      ]
    ),
    (
      'Pacific Deep',
      [
        Color(0xFF00C6FF),
        Color(0xFF0072FF),
        Color(0xFF0A1128),
        Color(0xFF001F3F)
      ]
    ),
    (
      'Emerald Forest',
      [
        Color(0xFF11998E),
        Color(0xFF38EF7D),
        Color(0xFF0575E6),
        Color(0xFF021B79)
      ]
    ),
    (
      'Monochrome',
      [
        Color(0xFFE0E0E0),
        Color(0xFF9E9E9E),
        Color(0xFF424242),
        Color(0xFF121212)
      ]
    ),
  ];

  // Shared settings built from the sliders — surface glass components use this.
  LiquidGlassSettings get _liveSettings => LiquidGlassSettings(
        thickness: _thickness,
        blur: _blur,
        edgeAbsorption: _edgeAbsorption,
        fresnelStrength: _fresnelStrength,
        lightIntensity: 0.8,
        glassColor: _isDarkMode
            ? const Color.fromARGB(25, 255, 255, 255)
            : const Color.fromARGB(40, 255, 255, 255),
      );

  // Indicator-specific settings — sliding pill indicators are transparent optical
  // lenses (blur: 0) over text/icons. We copy baseIndicatorSettings and inject the
  // live edgeAbsorption and fresnelStrength sliders so rim tuning works without
  // smearing the text underneath.
  LiquidGlassSettings get _indicatorLiveSettings =>
      AnimatedGlassIndicator.baseIndicatorSettings.copyWith(
        edgeAbsorption: _edgeAbsorption,
        fresnelStrength: _fresnelStrength,
      );

  @override
  Widget build(BuildContext context) {
    final currentBg = _backgrounds[_backgroundIndex];
    final labelColor =
        _isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: GlassScaffold(
        topEdgeFade: true,
        appBar: GlassAppBar(
          title: const Text('Meniscus & Blur Lab'),
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              child: Icon(
                _isDarkMode
                    ? CupertinoIcons.sun_max_fill
                    : CupertinoIcons.moon_fill,
                color: _isDarkMode
                    ? CupertinoColors.systemYellow
                    : CupertinoColors.systemPurple,
              ),
            ),
          ],
        ),
        background: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: currentBg.$2,
            ),
          ),
          child: CustomPaint(
            painter: _GridPatternPainter(isDark: _isDarkMode),
            child: const SizedBox.expand(),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              // ── 1. Background picker ─────────────────────────────────────
              _sectionHeader('BACKGROUND'),
              const SizedBox(height: 8),
              _backgroundPicker(),
              const SizedBox(height: 28),

              // ── 2. Parameter Tuner ───────────────────────────────────────
              _sectionHeader('LIVE PARAMETER TUNER'),
              const SizedBox(height: 8),
              GlassCard(
                useOwnLayer: true,
                padding: const EdgeInsets.all(20),
                shape: const LiquidRoundedSuperellipse(borderRadius: 22),
                settings: _liveSettings,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: CupertinoColors.activeBlue
                                .withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.sparkles,
                            color: CupertinoColors.activeBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Beer-Lambert Rim Absorption',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: labelColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'All components below update in real time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: labelColor.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Presets
                    Row(
                      children: [
                        _presetChip('Flat (0.0)', 0.0),
                        const SizedBox(width: 8),
                        _presetChip('iOS 26 (0.15)', 0.15),
                        const SizedBox(width: 8),
                        _presetChip('Crystal (0.35)', 0.35),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _slider(
                      label: 'Edge Absorption',
                      value: _edgeAbsorption,
                      min: 0.0,
                      max: 0.60,
                      onChanged: (v) => setState(() => _edgeAbsorption = v),
                    ),
                    _slider(
                      label: 'Fresnel Rim Intensity',
                      value: _fresnelStrength,
                      min: 0.0,
                      max: 2.0,
                      onChanged: (v) => setState(() => _fresnelStrength = v),
                    ),
                    _slider(
                      label: 'Glass Thickness',
                      value: _thickness,
                      min: 5.0,
                      max: 60.0,
                      onChanged: (v) => setState(() => _thickness = v),
                    ),
                    _slider(
                      label: 'Blur Sigma (24-tap)',
                      value: _blur,
                      min: 0.0,
                      max: 30.0,
                      onChanged: (v) => setState(() => _blur = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── 3. Side-by-side Card comparison ─────────────────────────
              _sectionHeader('MENISCUS RIM DARKENING — CARD'),
              const SizedBox(height: 4),
              Text(
                'Drag the Edge Absorption slider above to compare.',
                style: TextStyle(
                    fontSize: 12, color: labelColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _comparisonCard(
                      label: 'Flat  0.0',
                      absorption: 0.0,
                      icon: CupertinoIcons.circle,
                      accent: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _comparisonCard(
                      label: 'Live  ${_edgeAbsorption.toStringAsFixed(2)}',
                      absorption: _edgeAbsorption,
                      icon: CupertinoIcons.sparkles,
                      accent: CupertinoColors.activeBlue,
                      active: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── 4. Segmented Control pill ────────────────────────────────
              _sectionHeader('ANIMATED PILL — GLASS SEGMENTED CONTROL'),
              const SizedBox(height: 4),
              Text(
                'Drag between segments — watch meniscus depth on the moving pill.',
                style: TextStyle(
                    fontSize: 12, color: labelColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 10),
              GlassSegmentedControl(
                selectedIndex: _segmentIndex,
                onSegmentSelected: (i) => setState(() => _segmentIndex = i),
                indicatorSettings: _indicatorLiveSettings,
                segments: const [
                  GlassSegment(label: 'Flat'),
                  GlassSegment(label: 'iOS 26'),
                  GlassSegment(label: 'Crystal'),
                ],
              ),
              const SizedBox(height: 28),

              // ── 5. Slider thumb ──────────────────────────────────────────
              _sectionHeader('ANIMATED PILL — GLASS SLIDER'),
              const SizedBox(height: 4),
              Text(
                'The thumb is an AnimatedGlassIndicator — same absorption applies.',
                style: TextStyle(
                    fontSize: 12, color: labelColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 10),
              GlassSlider(
                value: _sliderValue,
                onChanged: (v) => setState(() => _sliderValue = v),
                settings: _indicatorLiveSettings,
              ),
              const SizedBox(height: 28),

              // ── 6. Switch thumbs ─────────────────────────────────────────
              _sectionHeader('ANIMATED PILL — GLASS SWITCH'),
              const SizedBox(height: 4),
              Text(
                'The circular thumb uses the same indicator pipeline.',
                style: TextStyle(
                    fontSize: 12, color: labelColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _switchRow(
                      label: 'Enable feature',
                      value: _switchValue,
                      onChanged: (v) => setState(() => _switchValue = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _switchRow(
                      label: 'Dark contrast',
                      value: _switch2Value,
                      onChanged: (v) => setState(() => _switch2Value = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── 7. Premium Glass Tab Bars ────────────────────────────────
              _sectionHeader('GLASS TAB BAR — PREMIUM QUALITY (2 VARIANTS)'),
              const SizedBox(height: 4),
              Text(
                'Full GlassQuality.premium path — authentic 3D optical separation under the Fresnel hairline rim with jelly-spring tracking.',
                style: TextStyle(
                    fontSize: 12, color: labelColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 12),

              // Style A: Capsule Text Switcher
              Text(
                'Variant 1: Capsule Inline Switcher',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: labelColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              GlassTabBar.inline(
                quality: GlassQuality.premium,
                selectedIndex: _tabBarPillIndex,
                onTabSelected: (i) => setState(() => _tabBarPillIndex = i),
                settings: _liveSettings,
                indicatorSettings: _indicatorLiveSettings,
                tabs: const [
                  GlassTab(label: 'Overview'),
                  GlassTab(label: 'Refraction'),
                  GlassTab(label: 'Meniscus'),
                  GlassTab(label: 'Physics'),
                ],
              ),
              const SizedBox(height: 18),

              // Style B: Rich Navigation Bar with Icons & Glow
              Text(
                'Variant 2: Icon + Label Navigation Bar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: labelColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              GlassTabBar.inline(
                quality: GlassQuality.premium,
                barHeight: 56,
                iconSize: 20,
                labelFontSize: 11,
                iconLabelSpacing: 3,
                tabPadding: const EdgeInsets.symmetric(horizontal: 6),
                selectedIndex: _tabBarNavIndex,
                onTabSelected: (i) => setState(() => _tabBarNavIndex = i),
                settings: _liveSettings,
                indicatorSettings: _indicatorLiveSettings,
                tabs: const [
                  GlassTab(
                    icon: Icon(CupertinoIcons.sparkles),
                    label: 'Meniscus',
                    glowColor: CupertinoColors.activeBlue,
                  ),
                  GlassTab(
                    icon: Icon(CupertinoIcons.waveform_path),
                    label: 'Optics',
                    glowColor: CupertinoColors.systemIndigo,
                  ),
                  GlassTab(
                    icon: Icon(CupertinoIcons.slider_horizontal_3),
                    label: 'Tuner',
                    glowColor: CupertinoColors.systemTeal,
                  ),
                  GlassTab(
                    icon: Icon(CupertinoIcons.cube_box),
                    label: 'Bevel',
                    glowColor: CupertinoColors.systemPurple,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── 8. Progressive Blur ──────────────────────────────────────
              _sectionHeader('24-TAP PROGRESSIVE BLUR (IIR OPTIMISED)'),
              const SizedBox(height: 4),
              Text(
                '50% bandwidth reduction · Zero banding · No transcendental exp() in loop',
                style: TextStyle(
                    fontSize: 12, color: labelColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 10),
              _progressiveBlurShowcase(labelColor),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Background picker ────────────────────────────────────────────────────

  Widget _backgroundPicker() {
    return Row(
      children: List.generate(_backgrounds.length, (idx) {
        final isSelected = _backgroundIndex == idx;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _backgroundIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin:
                  EdgeInsets.only(right: idx < _backgrounds.length - 1 ? 8 : 0),
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _backgrounds[idx].$2,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? const Icon(CupertinoIcons.checkmark_alt,
                      color: CupertinoColors.white, size: 18)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ─── Comparison card ──────────────────────────────────────────────────────

  Widget _comparisonCard({
    required String label,
    required double absorption,
    required IconData icon,
    required Color accent,
    bool active = false,
  }) {
    return GlassCard(
      useOwnLayer: true,
      padding: const EdgeInsets.all(16),
      shape: const LiquidRoundedSuperellipse(borderRadius: 18),
      settings: LiquidGlassSettings(
        thickness: _thickness,
        blur: _blur,
        edgeAbsorption: absorption,
        fresnelStrength: _fresnelStrength,
        lightIntensity: 0.8,
        glassColor: _isDarkMode
            ? const Color.fromARGB(25, 255, 255, 255)
            : const Color.fromARGB(40, 255, 255, 255),
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: active ? 0.14 : 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: accent.withValues(alpha: active ? 0.35 : 0.1)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color:
                  _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            active ? 'Beer-Lambert rim depth' : 'No rim absorption',
            style: const TextStyle(
                fontSize: 11, color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Switch row ───────────────────────────────────────────────────────────

  Widget _switchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
        ),
        GlassSwitch(
          quality: GlassQuality.premium,
          value: value,
          onChanged: onChanged,
          settings: _liveSettings,
        ),
      ],
    );
  }

  // ─── Progressive blur showcase ────────────────────────────────────────────

  Widget _progressiveBlurShowcase(Color labelColor) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Content underneath the blur
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.speedometer,
                  size: 36,
                  color: labelColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'kHalf 48 → 24 · IIR Multiply Recurrence',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: labelColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zero transcendental exp() calls inside the blur loop',
                  style: TextStyle(
                      fontSize: 11, color: labelColor.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
          // The progressive blur overlay
          Positioned.fill(
            child: ProgressiveBlur(
              maxSigma: _blur.clamp(4, 30),
              direction: ProgressiveBlurDirection.topToBottom,
            ),
          ),
          // Label badge
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: CupertinoColors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'σ = ${_blur.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared UI helpers ────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: CupertinoColors.systemGrey,
      ),
    );
  }

  Widget _presetChip(String label, double value) {
    final isSelected = (_edgeAbsorption - value).abs() < 0.01;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _edgeAbsorption = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? CupertinoColors.white
                  : (_isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.activeBlue,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          CupertinoSlider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background grid painter
// ─────────────────────────────────────────────────────────────────────────────

class _GridPatternPainter extends CustomPainter {
  const _GridPatternPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isDark ? CupertinoColors.white : CupertinoColors.black)
          .withValues(alpha: 0.07)
      ..strokeWidth = 1.0;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final dotPaint = Paint()
      ..color = (isDark ? CupertinoColors.white : CupertinoColors.black)
          .withValues(alpha: 0.13);
    for (double x = spacing; x < size.width; x += spacing * 2) {
      for (double y = spacing; y < size.height; y += spacing * 2) {
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter old) => isDark != old.isDark;
}
