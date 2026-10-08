/// Shape comparison demo — LiquidRoundedRectangle vs LiquidRoundedSuperellipse
/// across both Standard and Premium quality tiers.
///
/// Standard quality: lightweight blur shader + ShapeBorderClipper (shape-type-blind).
/// Premium quality:  Impeller geometry shader (sdfSquircle on GPU).
///
/// To run standalone: flutter run -t lib/demos/shape_debug_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const ShapeDebugApp()));
}

class ShapeDebugApp extends StatelessWidget {
  const ShapeDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const ShapeDebugPage(),
    );
  }
}

class ShapeDebugPage extends StatefulWidget {
  const ShapeDebugPage({super.key});

  @override
  State<ShapeDebugPage> createState() => _ShapeDebugPageState();
}

class _ShapeDebugPageState extends State<ShapeDebugPage> {
  GlassQuality _quality = GlassQuality.standard;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0d1117), Color(0xFF161b22), Color(0xFF1c2526)],
          ),
        ),
      ),
      child: GlassScaffold(
        backgroundColor: const Color(0x00000000),
        body: AdaptiveLiquidGlassLayer(
          settings: RecommendedGlassSettings.standard,
          quality: _quality,
          child: SafeArea(
            child: Column(
              children: [
                // ── Header + quality toggle ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shape Debug',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'RoundedRect vs Superellipse',
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quality toggle pill
                      _QualityToggle(
                        quality: _quality,
                        onChanged: (q) => setState(() => _quality = q),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // ── Quality badge ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _QualityBadge(quality: _quality),
                ),
                SizedBox(height: 16),

                // ── Scrollable content ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Moderate radii — squircle difference is visible here
                        const _SectionLabel('Moderate Radius'),
                        SizedBox(height: 4),
                        const _SectionHint(
                          'Squircle corners fill further into the diagonal — '
                          'look for the smoother "sweep" vs the circular arc pop.',
                        ),
                        SizedBox(height: 14),
                        for (final r in [16.0, 24.0, 32.0]) ...[
                          _CardComparisonRow(
                            radius: r,
                            quality: _quality,
                            cardHeight: 100,
                          ),
                          SizedBox(height: 16),
                        ],

                        SizedBox(height: 12),

                        // Button-sized shapes — still distinguishable at r=12-18
                        const _SectionLabel('Button Size'),
                        SizedBox(height: 4),
                        const _SectionHint(
                          'Smaller shapes at typical button radii (r = 12–18).',
                        ),
                        SizedBox(height: 14),
                        for (final r in [12.0, 18.0]) ...[
                          _CardComparisonRow(
                            radius: r,
                            quality: _quality,
                            cardHeight: 52,
                          ),
                          SizedBox(height: 16),
                        ],

                        SizedBox(height: 12),

                        // Pill / Stadium — BOTH identical by design
                        const _SectionLabel('Pill / Stadium (r ≥ half-height)'),
                        SizedBox(height: 4),
                        const _SectionHint(
                          'When radius is clamped to the half-height, both '
                          'shapes become a perfect stadium — identical by design.',
                        ),
                        SizedBox(height: 14),
                        _CardComparisonRow(
                          radius: 999,
                          quality: _quality,
                          cardHeight: 62,
                          radiusLabel: '∞ (pill)',
                        ),
                        SizedBox(height: 32),

                        // Inline buttons
                        const _SectionLabel('Inline Buttons'),
                        SizedBox(height: 14),
                        _ButtonComparisonRow(quality: _quality),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Quality toggle + badge
// =============================================================================

class _QualityToggle extends StatelessWidget {
  const _QualityToggle({
    required this.quality,
    required this.onChanged,
  });

  final GlassQuality quality;
  final ValueChanged<GlassQuality> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: () => onChanged(
        quality == GlassQuality.standard
            ? GlassQuality.premium
            : GlassQuality.standard,
      ),
      height: 36,
      quality: GlassQuality.premium,
      useOwnLayer: true,
      shape: const LiquidRoundedRectangle(borderRadius: 18),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              quality == GlassQuality.premium
                  ? CupertinoIcons.circle
                  : CupertinoIcons.square_stack_3d_up,
              color: CupertinoColors.white.withValues(alpha: 0.70),
              size: 14,
            ),
            SizedBox(width: 6),
            Text(
              quality == GlassQuality.premium ? 'Premium' : 'Standard',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.quality});
  final GlassQuality quality;

  @override
  Widget build(BuildContext context) {
    final isPremium = quality == GlassQuality.premium;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPremium
            ? const Color(0xFF7B61FF).withValues(alpha: 0.15)
            : CupertinoColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPremium
              ? const Color(0xFF7B61FF).withValues(alpha: 0.4)
              : CupertinoColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        isPremium
            ? '⬦ Premium — Impeller sdfSquircle geometry shader (GPU L4 blend)'
            : '◈ Standard — ShapeBorderClipper + lightweight blur shader (shape-blind)',
        style: TextStyle(
          fontSize: 11,
          color: isPremium
              ? const Color(0xFFB09FFF)
              : CupertinoColors.white.withValues(alpha: 0.5),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// =============================================================================
// Section labels
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.white.withValues(alpha: 0.70),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SectionHint extends StatelessWidget {
  const _SectionHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: CupertinoColors.white.withValues(alpha: 0.38),
        height: 1.4,
      ),
    );
  }
}

// =============================================================================
// Card comparison row — RoundedRect (left) vs Superellipse (right)
// =============================================================================

class _CardComparisonRow extends StatelessWidget {
  const _CardComparisonRow({
    required this.radius,
    required this.quality,
    required this.cardHeight,
    this.radiusLabel,
  });

  final double radius;
  final GlassQuality quality;
  final double cardHeight;
  final String? radiusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'r = ${radiusLabel ?? radius.toInt()}',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.3),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _LabelledCard(
                shape: LiquidRoundedRectangle(borderRadius: radius),
                label: 'RoundedRect',
                sublabel: 'sdfRRect / circular arc',
                height: cardHeight,
                quality: quality,
                accentColor: const Color(0xFF4A9EFF),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _LabelledCard(
                shape: LiquidRoundedSuperellipse(borderRadius: radius),
                label: 'Superellipse',
                sublabel: 'sdfSquircle / Ln Lamé curve',
                height: cardHeight,
                quality: quality,
                accentColor: const Color(0xFF7B61FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LabelledCard extends StatelessWidget {
  const _LabelledCard({
    required this.shape,
    required this.label,
    required this.sublabel,
    required this.height,
    required this.quality,
    required this.accentColor,
  });

  final LiquidShape shape;
  final String label;
  final String sublabel;
  final double height;
  final GlassQuality quality;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final showSublabel = height >= 70;
    return GlassContainer(
      shape: shape,
      useOwnLayer: quality == GlassQuality.premium,
      quality: quality,
      height: height,
      child: showSublabel
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Center(
              child: Text(
                label,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
    );
  }
}

// =============================================================================
// Inline button comparison row
// =============================================================================

class _ButtonComparisonRow extends StatelessWidget {
  const _ButtonComparisonRow({required this.quality});
  final GlassQuality quality;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LabelledButton(
          shape: const LiquidRoundedRectangle(borderRadius: 14),
          label: 'RoundedRect',
          quality: quality,
          accentColor: const Color(0xFF4A9EFF),
        ),
        SizedBox(width: 16),
        _LabelledButton(
          shape: const LiquidRoundedSuperellipse(borderRadius: 14),
          label: 'Superellipse',
          quality: quality,
          accentColor: const Color(0xFF7B61FF),
        ),
      ],
    );
  }
}

class _LabelledButton extends StatelessWidget {
  const _LabelledButton({
    required this.shape,
    required this.label,
    required this.quality,
    required this.accentColor,
  });

  final LiquidShape shape;
  final String label;
  final GlassQuality quality;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassButton.custom(
          shape: shape,
          quality: quality,
          useOwnLayer: quality == GlassQuality.premium,
          height: 44,
          width: 140,
          onTap: () {},
          child: Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'r = 14',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.3),
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
