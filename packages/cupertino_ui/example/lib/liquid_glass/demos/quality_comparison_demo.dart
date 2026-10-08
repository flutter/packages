/// Quality Comparison Demo — Premium vs Standard side-by-side
///
/// Renders GlassButton, GlassSegmentedControl, GlassCard, and GlassTabBar
/// with IDENTICAL [LiquidGlassSettings] at both quality levels so you can
/// directly compare how the thickness/light normalization affects each widget
/// on the Standard (2D lightweight shader) path.
///
/// Settings are deliberately higher than defaults (thickness: 28,
/// lightIntensity: 0.9) to make the normalization delta clearly visible.
///
/// Run standalone:
///   flutter run -t example/lib/demos/quality_comparison_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ── Thematic presets for testing ─────────────────────────────────────────────
class _ThemePreset {
  final String name;
  final Color glassColor;
  final double baseOpacity;
  final double thickness;
  final double lightIntensity;
  final double blur;
  final double ambient;
  final double saturation;
  final double refractiveIndex;

  const _ThemePreset({
    required this.name,
    required this.glassColor,
    required this.baseOpacity,
    required this.thickness,
    required this.lightIntensity,
    required this.blur,
    required this.ambient,
    required this.saturation,
    required this.refractiveIndex,
  });
}

const _kThemePresets = [
  _ThemePreset(
    name: 'Default White',
    glassColor: CupertinoColors.white,
    baseOpacity: 0.12,
    thickness: 28.0,
    lightIntensity: 0.9,
    blur: 3.0,
    ambient: 0.22,
    saturation: 1.2,
    refractiveIndex: 1.25,
  ),
  _ThemePreset(
    name: 'Emerald Mint',
    glassColor: Color(0xFF80CBC4), // Richer teal-mint with more chroma
    baseOpacity: 0.35,
    thickness: 30.0,
    lightIntensity: 1.1,
    blur: 4.5,
    ambient: 0.28,
    saturation: 1.5,
    refractiveIndex: 1.30,
  ),
  _ThemePreset(
    name: 'Obsidian Night',
    glassColor: Color(0xFF1E1E24), // Ultra deep dark obsidian
    baseOpacity: 0.48,
    thickness: 18.0,
    lightIntensity: 0.65,
    blur: 4.0,
    ambient: 0.12,
    saturation: 0.95,
    refractiveIndex: 1.18,
  ),
  _ThemePreset(
    name: 'Cyberpunk Neon',
    glassColor: Color(0xFFFF007F), // Glowing hot magenta
    baseOpacity: 0.22,
    thickness: 34.0,
    lightIntensity: 1.35,
    blur: 5.5,
    ambient: 0.32,
    saturation: 1.7,
    refractiveIndex: 1.40,
  ),
  _ThemePreset(
    name: 'Frosted Bronze',
    glassColor: Color(0xFFD2B48C), // Warm luxury tan bronze tint
    baseOpacity: 0.20,
    thickness: 26.0,
    lightIntensity: 1.0,
    blur: 6.0,
    ambient: 0.24,
    saturation: 1.3,
    refractiveIndex: 1.28,
  ),
  _ThemePreset(
    name: 'Glacial Ice',
    glassColor: Color(0xFFE0F7FA), // Crisp arctic pale cyan tint
    baseOpacity: 0.10,
    thickness: 32.0,
    lightIntensity: 1.2,
    blur: 2.0,
    ambient: 0.18,
    saturation: 1.25,
    refractiveIndex: 1.35,
  ),
  _ThemePreset(
    name: 'Royal Amethyst',
    glassColor: Color(0xFFE1BEE7), // Deep majestic pale purple tint
    baseOpacity: 0.16,
    thickness: 28.0,
    lightIntensity: 0.95,
    blur: 5.0,
    ambient: 0.26,
    saturation: 1.4,
    refractiveIndex: 1.26,
  ),
  _ThemePreset(
    name: 'Auroral Glow',
    glassColor: Color(0xFFB2DFDB), // Polar lights teal mint tint
    baseOpacity: 0.14,
    thickness: 29.0,
    lightIntensity: 1.05,
    blur: 4.0,
    ambient: 0.20,
    saturation: 1.45,
    refractiveIndex: 1.27,
  ),
];

// ── Per-widget Standard preset defaults ───────────────────────────────────────
// lightweight_glass.frag shader uniform mapping:
//   opacity   → glassColor.alpha  (body density / translucency — MOST VISIBLE)
//   ambient   → ambientStrength   (multiplier on bgRgb in body layer, subtle)
//   glow      → glowIntensity     (additive brightness — very visible)
//   light     → lightIntensity    (rim specular brightness)
//   thickness → rim width
//   blur      → BackdropFilter frosting
// NOTE: uSaturation in this shader = HUE saturation (mix(luma,color,sat)).
//   For white/achromatic glass it has no effect, so we map opacity → glassColor.alpha instead.
// Tune these until Standard matches Premium, then report values.

const _kPillDefault = _Preset(
  // Animated pill / indicator — tuned 2026-05-20 (calibrated with 0.25x shader scaling)
  // thickness→rimThickness (÷0.35 dampener → 0.35×1/0.35=0.35 rendered rim)
  // light→lightIntensity   (÷0.6  dampener → 0.60×1/0.6 =0.60 rendered spec)
  // blur must be 0.0: AnimatedGlassIndicator.baseIndicatorSettings mandates blur=0 for
  // indicators. A non-zero value propagates through _mergeWithBase and triggers the
  // BackdropFilter clip path — indicators are not frosted surfaces.
  thickness: 1.0, ambient: 0.28, glow: 0.50, light: 1.0,
  blur: 0.0,
  stdOpacityMultiplier: 1.0,
);
const _kBtnDefault = _Preset(
  // GlassButton — tuned 2026-05-20 (calibrated with 0.25x shader scaling)
  // light↑ 0.72→0.88: rim specular needs to be brighter on 2D shader to match
  // the 3D SDF Fresnel rim of Premium. glow↓ 0.75→0.65: compensates so total
  // perceived brightness doesn't overshoot. Result: ~88% parity with Premium.
  thickness: 17, ambient: 0.28, glow: 0.65, light: 0.88,
  blur: 3.0,
  stdOpacityMultiplier: 1.0,
);
const _kCardDefault = _Preset(
  // GlassCard + tab bar surface — tuned for ~88% visual parity
  thickness: 19, ambient: 0.26, glow: 0.0, light: 0.90,
  blur: 3.0,
  stdOpacityMultiplier: 1.0,
);

// ── Entry point ───────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    // Recommended for production: auto-benchmarks the device and
    // degrades quality gracefully on weaker hardware.
    adaptiveQuality: true,
    child: const _App(),
  ));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Quality Comparison',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const GlassQualityComparisonDemo(),
    );
  }
}

// ── Demo page ─────────────────────────────────────────────────────────────────

class GlassQualityComparisonDemo extends StatefulWidget {
  const GlassQualityComparisonDemo({super.key});

  @override
  State<GlassQualityComparisonDemo> createState() =>
      GlassQualityComparisonDemoState();
}

class GlassQualityComparisonDemoState
    extends State<GlassQualityComparisonDemo> {
  int _segIndex = 0;
  int _tabIndex = 0;
  bool _switchValue = false;
  double _sliderValue = 0.4;

  // ── Live tuning panel ──────────────────────────────────────────────────
  bool _showTuning = false;

  // ── Per-widget Standard presets ──────────────────────────────────────
  // Premium uses the dynamic thematic values which can be customized.
  _Preset _pill = _kPillDefault;
  _Preset _btn = _kBtnDefault;
  _Preset _card = _kCardDefault;

  // ── Thematic / Glass Preset State ─────────────────────────────────────
  int _selectedPresetIndex = 0;
  Color _glassColor = _kThemePresets[0].glassColor;
  double _baseOpacity = _kThemePresets[0].baseOpacity;
  double _thickness = _kThemePresets[0].thickness;
  double _lightIntensity = _kThemePresets[0].lightIntensity;
  double _blur = _kThemePresets[0].blur;
  double _ambient = _kThemePresets[0].ambient;
  double _saturation = _kThemePresets[0].saturation;
  double _refractiveIndex = _kThemePresets[0].refractiveIndex;

  /// Premium — reference settings that update dynamically based on the active
  /// thematic preset or global custom overrides.
  LiquidGlassSettings get _kGlass => LiquidGlassSettings(
        glassColor: _glassColor.withValues(alpha: _baseOpacity),
        blur: _blur,
        thickness: _thickness,
        lightIntensity: _lightIntensity,
        ambientStrength: _ambient,
        chromaticAberration: 0.02,
        refractiveIndex: _refractiveIndex,
        saturation: _saturation,
      );

  /// Standard pill / animated indicator settings.
  LiquidGlassSettings get _kGlassPill => _pill.toSettings(_kGlass.glassColor);

  /// Standard button settings.
  LiquidGlassSettings get _kGlassBtn => _btn.toSettings(_kGlass.glassColor);

  /// Standard card / surface settings (also used for tab bar background).
  LiquidGlassSettings get _kGlassCard => _card.toSettings(_kGlass.glassColor);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Plain background — renders as a normal Flutter layer so both
        // standard BackdropFilter and premium Impeller shader can sample it.
        Image.asset('assets/mountain_landscape.jpg', fit: BoxFit.cover),
        Container(color: CupertinoColors.black.withValues(alpha: 0.28)),

        // GlassPage with no background param — wraps the content only.
        GlassPage(
          child: GlassScaffold(
            backgroundColor: const Color(0x00000000),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  if (_showTuning)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: SizedBox(
                        height: 280,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                CupertinoColors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.1)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildPremiumTuningPanel(),
                                  SizedBox(height: 16),
                                  _buildStandardTuningPanel(),
                                  SizedBox(height: 16),
                                  _buildDiagnosticsPanel(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 8),
                  _buildColumnLabels(),
                  SizedBox(height: 4),
                  Expanded(child: _buildComparisonList()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Quality Comparison',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Thematic Preset Selector (Glass Menu)
          Text(
            'THEME PRESETS',
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.38),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kThemePresets.length,
              itemBuilder: (context, index) {
                final preset = _kThemePresets[index];
                final isSelected = _selectedPresetIndex == index;
                final presetColor = preset.glassColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPresetIndex = index;
                      _glassColor = preset.glassColor;
                      _baseOpacity = preset.baseOpacity;
                      _thickness = preset.thickness;
                      _lightIntensity = preset.lightIntensity;
                      _blur = preset.blur;
                      _ambient = preset.ambient;
                      _saturation = preset.saturation;
                      _refractiveIndex = preset.refractiveIndex;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? presetColor.withValues(alpha: 0.2)
                          : CupertinoColors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? presetColor.withValues(alpha: 0.8)
                            : CupertinoColors.white.withValues(alpha: 0.08),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: presetColor.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: presetColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: presetColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          preset.name,
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.white.withValues(alpha: 0.70),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),

          // Tuning toggle
          GestureDetector(
            onTap: () => setState(() => _showTuning = !_showTuning),
            child: Row(
              children: [
                Text(
                  _showTuning
                      ? '▲ Hide Advanced Tuning'
                      : '▼ Tune Premium & Standard',
                  style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!_showTuning) ...[
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB830).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PREMIUM OVERRIDES',
                      style: TextStyle(
                        color: Color(0xFFFFB830),
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTuningPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GLOBAL PREMIUM CONFIG (Interactive Playground)',
          style: TextStyle(
            color: Color(0xFFFFB830),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 8),
        _Slider('Opacity', _baseOpacity, 0.01, 1.0,
            (v) => setState(() => _baseOpacity = v),
            color: CupertinoColors.white),
        _Slider('Thickness', _thickness, 1.0, 60.0,
            (v) => setState(() => _thickness = v),
            color: CupertinoColors.white),
        _Slider('Specularity', _lightIntensity, 0.0, 2.5,
            (v) => setState(() => _lightIntensity = v),
            color: CupertinoColors.white),
        _Slider('Blur', _blur, 0.0, 20.0, (v) => setState(() => _blur = v),
            color: CupertinoColors.white),
        _Slider(
            'Ambient', _ambient, 0.0, 0.6, (v) => setState(() => _ambient = v),
            color: CupertinoColors.white),
        _Slider('Saturation', _saturation, 0.0, 3.0,
            (v) => setState(() => _saturation = v),
            color: CupertinoColors.white),
        _Slider('Refraction', _refractiveIndex, 1.0, 2.0,
            (v) => setState(() => _refractiveIndex = v),
            color: CupertinoColors.white),
      ],
    );
  }

  Widget _buildStandardTuningPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STANDARD ONLY  ·  Premium is locked',
              style: TextStyle(
                  color: Color(0xFF5AC8FA),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _pill = _kPillDefault;
                  _btn = _kBtnDefault;
                  _card = _kCardDefault;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5AC8FA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFF5AC8FA).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'RESET TO DEFAULTS',
                  style: TextStyle(
                    color: Color(0xFF5AC8FA),
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2, width: double.infinity),
        Text(
          'saturation → bgBoost  ·  ambient → lift  ·  glow → fresnel edge',
          style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.24),
              fontSize: 8,
              fontFamily: 'monospace'),
        ),
        SizedBox(height: 8),
        _PresetSection(
            label: '● PILL / INDICATOR',
            color: const Color(0xFF5AC8FA),
            preset: _pill,
            onChanged: (p) => setState(() => _pill = p),
            thicknessMin: 0.1,
            thicknessMax: 8.0,
            thicknessLabel: 'rim px'),
        SizedBox(height: 8),
        _PresetSection(
            label: '● BUTTON',
            color: const Color(0xFF4ADE80),
            preset: _btn,
            onChanged: (p) => setState(() => _btn = p),
            thicknessMin: 0.0,
            thicknessMax: 30.0),
        SizedBox(height: 8),
        _PresetSection(
            label: '● CARD / SURFACE',
            color: const Color(0xFFBB86FC),
            preset: _card,
            onChanged: (p) => setState(() => _card = p),
            thicknessMin: 0.0,
            thicknessMax: 30.0),
      ],
    );
  }

  Widget _buildDiagnosticsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REAL-TIME STANDARD PARITY MATHEMATICS',
          style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.38),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8),
        ),
        SizedBox(height: 4),
        Text(
          'pill  th=${_pill.thickness.toStringAsFixed(1)} amb=${_pill.ambient.toStringAsFixed(3)}\n'
          '      glow=${_pill.glow.toStringAsFixed(2)} li=${_pill.light.toStringAsFixed(2)} blur=${_pill.blur.toStringAsFixed(1)}',
          style: TextStyle(
            color: const Color(0xFF5AC8FA).withValues(alpha: 0.9),
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 4),
        Text(
          'btn   th=${_btn.thickness.toStringAsFixed(0)} amb=${_btn.ambient.toStringAsFixed(3)}\n'
          '      glow=${_btn.glow.toStringAsFixed(2)} li=${_btn.light.toStringAsFixed(2)} blur=${_btn.blur.toStringAsFixed(1)}',
          style: TextStyle(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.9),
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 4),
        Text(
          'card  th=${_card.thickness.toStringAsFixed(0)} amb=${_card.ambient.toStringAsFixed(3)}\n'
          '      glow=${_card.glow.toStringAsFixed(2)} li=${_card.light.toStringAsFixed(2)} blur=${_card.blur.toStringAsFixed(1)}',
          style: TextStyle(
            color: const Color(0xFFBB86FC).withValues(alpha: 0.9),
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  // ── Column labels ─────────────────────────────────────────────────────────

  Widget _buildColumnLabels() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QualityBadge(
              label: 'PREMIUM',
              subtitle: 'Impeller · 3D SDF',
              color: const Color(0xFFFFB830),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _QualityBadge(
              label: 'STANDARD',
              subtitle: 'Skia/Web · 2D shader',
              color: const Color(0xFF5AC8FA),
            ),
          ),
        ],
      ),
    );
  }

  // ── Comparison list ───────────────────────────────────────────────────────

  Widget _buildComparisonList() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        children: [
          // ── GlassButton ─────────────────────────────────────────────────
          _ComparisonRow(
            label: 'GlassButton',
            premium: GlassButton(
              useOwnLayer: true,
              settings: _kGlass,
              quality: GlassQuality.premium,
              onTap: () {},
              icon: Icon(CupertinoIcons.play_fill),
              label: 'Press',
            ),
            standard: GlassButton(
              useOwnLayer: true,
              settings: _kGlassBtn,
              quality: GlassQuality.standard,
              onTap: () {},
              icon: Icon(CupertinoIcons.play_fill),
              label: 'Press',
            ),
          ),

          SizedBox(height: 20),

          // ── GlassSegmentedControl ────────────────────────────────────────
          _ComparisonRow(
            label: 'GlassSegmentedControl',
            premium: GlassSegmentedControl(
              useOwnLayer: true,
              settings: _kGlass,
              // indicatorSettings intentionally omitted: the indicator pill is a
              // refractive lens, not a frosted surface. Passing surface settings
              // (which carry blur > 0) triggers a BackdropFilter on the pill,
              // smearing the underlying labels and destroying the SDF rim.
              // Omitting it falls back to AnimatedGlassIndicator.baseIndicatorSettings
              // (blur: 0), matching GlassTabBar.inline behaviour in the row below.
              quality: GlassQuality.premium,
              segments: [
                GlassSegment(label: 'Day'),
                GlassSegment(label: 'Week'),
                GlassSegment(label: 'Month')
              ],
              selectedIndex: _segIndex,
              onSegmentSelected: (i) => setState(() => _segIndex = i),
            ),
            standard: GlassSegmentedControl(
              useOwnLayer: true,
              settings: _kGlassCard,
              indicatorSettings: _kGlassPill,
              quality: GlassQuality.standard,
              segments: [
                GlassSegment(label: 'Day'),
                GlassSegment(label: 'Week'),
                GlassSegment(label: 'Month')
              ],
              selectedIndex: _segIndex,
              onSegmentSelected: (i) => setState(() => _segIndex = i),
            ),
          ),

          SizedBox(height: 20),

          // ── GlassCard ───────────────────────────────────────────────────
          _ComparisonRow(
            label: 'GlassCard',
            premium: GlassCard(
              useOwnLayer: true,
              settings: _kGlass,
              quality: GlassQuality.premium,
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3D bevel · specular\nreflection',
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.70),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            standard: GlassCard(
              useOwnLayer: true,
              settings: _kGlassCard,
              quality: GlassQuality.standard,
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2D rim · normalised\nthickness & light',
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.70),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // ── GlassTabBar (full-width stacked) ─────────────────────────────
          _FullWidthRow(
            label: 'GlassTabBar',
            premiumWidget: GlassTabBar.inline(
              quality: GlassQuality.premium,
              settings: _kGlass,
              tabs: const [
                GlassTab(icon: Icon(CupertinoIcons.home)),
                GlassTab(icon: Icon(CupertinoIcons.search)),
                GlassTab(icon: Icon(CupertinoIcons.person)),
              ],
              selectedIndex: _tabIndex,
              onTabSelected: (i) => setState(() => _tabIndex = i),
            ),
            standardWidget: GlassTabBar.inline(
              quality: GlassQuality.standard,
              settings: _kGlassCard,
              indicatorSettings: _kGlassPill,
              tabs: const [
                GlassTab(icon: Icon(CupertinoIcons.home)),
                GlassTab(icon: Icon(CupertinoIcons.search)),
                GlassTab(icon: Icon(CupertinoIcons.person)),
              ],
              selectedIndex: _tabIndex,
              onTabSelected: (i) => setState(() => _tabIndex = i),
            ),
          ),

          SizedBox(height: 20),

          // ── GlassSwitch ───────────────────────────────────────────────────
          _ComparisonRow(
            label: 'GlassSwitch',
            premium: GlassSwitch(
              value: _switchValue,
              quality: GlassQuality.premium,
              onChanged: (v) => setState(() => _switchValue = v),
            ),
            standard: GlassSwitch(
              value: _switchValue,
              quality: GlassQuality.standard,
              onChanged: (v) => setState(() => _switchValue = v),
            ),
          ),

          SizedBox(height: 20),

          // ── GlassSlider ───────────────────────────────────────────────────
          _FullWidthRow(
            label: 'GlassSlider',
            premiumWidget: GlassSlider(
              value: _sliderValue,
              quality: GlassQuality.premium,
              activeColor: const Color(0xFF007AFF), // iOS system blue
              inactiveColor:
                  const Color(0x20FFFFFF), // glass tint for frosted track
              trackHeight: 5, // matches real iOS slider track thickness
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
            standardWidget: GlassSlider(
              value: _sliderValue,
              quality: GlassQuality.standard,
              activeColor: const Color(0xFF007AFF), // iOS system blue
              inactiveColor:
                  const Color(0x20FFFFFF), // glass tint for frosted track
              trackHeight: 5, // matches real iOS slider track thickness
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

/// Column header badge showing quality tier name and renderer description.
class _QualityBadge extends StatelessWidget {
  const _QualityBadge({
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Side-by-side comparison row for widgets that fit in equal columns.
class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.premium,
    required this.standard,
  });

  final String label;
  final Widget premium;
  final Widget standard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(child: premium),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Center(child: standard),
            ),
          ],
        ),
      ],
    );
  }
}

/// Full-width stacked row for widgets like GlassTabBar that need the full width.
class _FullWidthRow extends StatelessWidget {
  const _FullWidthRow({
    required this.label,
    required this.premiumWidget,
    required this.standardWidget,
  });

  final String label;
  final Widget premiumWidget;
  final Widget standardWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Premium
        Row(
          children: [
            _QualityPill('PREMIUM', const Color(0xFFFFB830)),
            SizedBox(width: 10),
            Expanded(child: premiumWidget),
          ],
        ),

        SizedBox(height: 12),

        // Standard
        Row(
          children: [
            _QualityPill('STANDARD', const Color(0xFF5AC8FA)),
            SizedBox(width: 10),
            Expanded(child: standardWidget),
          ],
        ),
      ],
    );
  }
}

/// Small vertical pill label for the full-width stacked rows.
class _QualityPill extends StatelessWidget {
  const _QualityPill(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _PresetSection extends StatefulWidget {
  const _PresetSection({
    required this.label,
    required this.color,
    required this.preset,
    required this.onChanged,
    this.thicknessMin = 0.0,
    this.thicknessMax = 30.0,
    this.thicknessLabel = 'thickness',
  });

  final String label;
  final Color color;
  final _Preset preset;
  final ValueChanged<_Preset> onChanged;
  final double thicknessMin;
  final double thicknessMax;
  final String thicknessLabel;

  @override
  State<_PresetSection> createState() => _PresetSectionState();
}

class _PresetSectionState extends State<_PresetSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.preset;
    final c = widget.color;
    return Container(
      padding: EdgeInsets.fromLTRB(8, 6, 8, 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(widget.label,
                    style: TextStyle(
                        color: c,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1)),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'th=${p.thickness.toStringAsFixed(0)} '
                    'amb=${p.ambient.toStringAsFixed(3)} '
                    'glow=${p.glow.toStringAsFixed(2)} '
                    'li=${p.light.toStringAsFixed(2)} '
                    'blur=${p.blur.toStringAsFixed(1)} '
                    'stdOp=${p.stdOpacityMultiplier.toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: c.withValues(alpha: 0.6),
                        fontSize: 8,
                        fontFamily: 'monospace'),
                  ),
                ),
                SizedBox(width: 4),
                Text(_expanded ? '▲' : '▼',
                    style: TextStyle(
                        color: c.withValues(alpha: 0.5), fontSize: 8)),
              ],
            ),
          ),
          if (_expanded) ...[
            SizedBox(height: 4),
            _Slider(
                widget.thicknessLabel,
                p.thickness,
                widget.thicknessMin,
                widget.thicknessMax,
                (v) => widget.onChanged(p.copyWith(thickness: v)),
                color: c),
            _Slider('ambient', p.ambient, 0.0, 0.35,
                (v) => widget.onChanged(p.copyWith(ambient: v)),
                color: c),
            _Slider('glow', p.glow, 0.0, 2.0,
                (v) => widget.onChanged(p.copyWith(glow: v)),
                color: c),
            _Slider('light', p.light, 0.0, 1.5,
                (v) => widget.onChanged(p.copyWith(light: v)),
                color: c),
            _Slider('blur', p.blur, 0.0, 12.0,
                (v) => widget.onChanged(p.copyWith(blur: v)),
                color: c),
            _Slider('stdOp', p.stdOpacityMultiplier, 0.0, 2.0,
                (v) => widget.onChanged(p.copyWith(stdOpacityMultiplier: v)),
                color: c),
          ],
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider(this.label, this.value, this.min, this.max, this.onChanged,
      {this.color = const Color(0xB2FFFFFF)});

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label: ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: CupertinoSlider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ── _Preset data class ─────────────────────────────────────────────────────────

/// Immutable tuning preset for one Standard widget type.
///
/// Field mapping to [LiquidGlassSettings] / shader uniforms
/// (lightweight_glass.frag — Standard path only, Premium untouched):
///
/// | Preset field | Settings mapping            | Visible effect                |
/// |-------------|----------------------------|-------------------------------|
/// | opacity     | glassColor.alpha            | Body density (most impactful) |
/// | ambient     | ambientStrength             | Background bleed (subtle)     |
/// | glow        | glowIntensity               | Additive brightness           |
/// | light       | lightIntensity              | Rim specular brightness       |
/// | thickness   | thickness                   | Rim width                     |
/// | blur        | blur                        | BackdropFilter frosting       |
class _Preset {
  const _Preset({
    required this.thickness,
    required this.ambient,
    required this.glow,
    required this.light,
    required this.blur,
    required this.stdOpacityMultiplier,
  });

  final double thickness;
  final double ambient; // → ambientStrength    (bgRgb multiplier, subtle)
  final double glow; // → glowIntensity      (additive glow)
  final double light; // → lightIntensity     (rim brightness)
  final double blur; // → blur               (frosting)
  final double stdOpacityMultiplier;

  LiquidGlassSettings toSettings(Color baseColor) => LiquidGlassSettings(
        glassColor: baseColor,
        thickness: thickness,
        saturation:
            1.08, // Neutral — uSaturation is hue-sat in lightweight_glass.frag;
        // has no effect on white glass, so fixed at 1.08.
        ambientStrength: ambient,
        glowIntensity: glow,
        lightIntensity: light,
        blur: blur,
        chromaticAberration: 0.02,
        refractiveIndex: 1.25,
        standardOpacityMultiplier: stdOpacityMultiplier,
      );

  _Preset copyWith({
    double? thickness,
    double? ambient,
    double? glow,
    double? light,
    double? blur,
    double? stdOpacityMultiplier,
  }) =>
      _Preset(
        thickness: thickness ?? this.thickness,
        ambient: ambient ?? this.ambient,
        glow: glow ?? this.glow,
        light: light ?? this.light,
        blur: blur ?? this.blur,
        stdOpacityMultiplier: stdOpacityMultiplier ?? this.stdOpacityMultiplier,
      );
}
