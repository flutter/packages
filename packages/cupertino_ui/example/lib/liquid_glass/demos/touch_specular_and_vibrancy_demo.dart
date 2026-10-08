import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Interactive demonstration of the v1.5.0 features:
/// 1. Shader-Level Touch Specular Highlight (GLSL isotropic contact highlight)
/// 2. Nested Glass Degradation via Vibrancy Fill (AdaptiveGlass.vibrancy)
/// 3. Continuous Menu Pointer Tracking (GlassMenu.glowOnTapOnly default: false)
class TouchSpecularAndVibrancyDemo extends StatefulWidget {
  const TouchSpecularAndVibrancyDemo({super.key});

  @override
  State<TouchSpecularAndVibrancyDemo> createState() =>
      _TouchSpecularAndVibrancyDemoState();
}

class _TouchSpecularAndVibrancyDemoState
    extends State<TouchSpecularAndVibrancyDemo> {
  // Specular settings
  double _lightIntensity = 0.8;
  double _thickness = 22.0;
  GlassSpecularSharpness _sharpness = GlassSpecularSharpness.medium;

  // Telemetry
  bool _isPointerDown = false;

  // Theme
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    final settings = LiquidGlassSettings(
      thickness: _thickness,
      blur: 14,
      lightIntensity: _lightIntensity,
      specularSharpness: _sharpness,
      refractiveIndex: 1.25,
      glassColor: _isDark
          ? CupertinoColors.white.withValues(alpha: 0.12)
          : CupertinoColors.white.withValues(alpha: 0.28),
      ambientStrength: 0.15,
      chromaticAberration: 0.015,
    );

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Touch & Vibrancy'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _isDark = !_isDark),
            child: Icon(
              _isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
              size: 20,
            ),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background photo or rich gradient
            Image.asset(
              'assets/wallpaper.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0D0B18),
                      Color(0xFF1B1435),
                      Color(0xFF0F2B48),
                      Color(0xFF091224),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Theme tint scrim
            Container(
              color: _isDark
                  ? CupertinoColors.black.withValues(alpha: 0.35)
                  : CupertinoColors.white.withValues(alpha: 0.20),
            ),

            SafeArea(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                children: [
                  _buildTouchSpecularSection(settings),
                  const SizedBox(height: 28),
                  _buildNestedVibrancySection(settings),
                  const SizedBox(height: 28),
                  _buildMenuTrackingSection(),
                  const SizedBox(height: 28),
                  _buildControlsCard(settings),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchSpecularSection(LiquidGlassSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Touch Specular Highlight',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Drag across the glass surface to see isotropic rim reflections tracking your touch.',
          style: TextStyle(
            fontSize: 12,
            color: _isDark
                ? CupertinoColors.systemGrey3
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 12),

        // Interactive Glass Slab
        AdaptiveLiquidGlassLayer(
          settings: settings,
          child: Listener(
            onPointerDown: (_) => setState(() => _isPointerDown = true),
            onPointerUp: (_) => setState(() => _isPointerDown = false),
            onPointerCancel: (_) => setState(() => _isPointerDown = false),
            child: GlassGlow(
              glowRadius: 1.2,
              glowBlurRadius: 32,
              glowColor: CupertinoColors.white.withValues(alpha: 0.35),
              child: GlassContainer(
                height: 190,
                shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                settings: settings,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.sparkles,
                                color: _isPointerDown
                                    ? const Color(0xFF34C759)
                                    : (_isDark
                                        ? CupertinoColors.white
                                            .withValues(alpha: 0.7)
                                        : CupertinoColors.black
                                            .withValues(alpha: 0.7)),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPointerDown
                                    ? 'Specular Glint Active'
                                    : 'Touch & Drag Surface',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: _isPointerDown
                                      ? const Color(0xFF34C759)
                                      : (_isDark
                                          ? CupertinoColors.white
                                          : CupertinoColors.black),
                                ),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isPointerDown
                                  ? const Color(0xFF34C759)
                                      .withValues(alpha: 0.2)
                                  : (_isDark
                                      ? const Color(0x33000000)
                                      : const Color(0x44FFFFFF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isPointerDown ? 'Tracking 120Hz' : 'Resting',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _isPointerDown
                                    ? const Color(0xFF34C759)
                                    : (_isDark
                                        ? CupertinoColors.systemGrey2
                                        : CupertinoColors.systemGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isPointerDown ? 0.35 : 0.85,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.hand_draw,
                                size: 30,
                                color: _isDark
                                    ? CupertinoColors.white
                                        .withValues(alpha: 0.8)
                                    : CupertinoColors.black
                                        .withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Slide finger anywhere on this surface',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _isDark
                                      ? CupertinoColors.white
                                          .withValues(alpha: 0.9)
                                      : CupertinoColors.black
                                          .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNestedVibrancySection(LiquidGlassSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Nested Glass Vibrancy Fill',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Nested glass controls automatically use vibrancy fills to avoid recursive blur passes.',
          style: TextStyle(
            fontSize: 12,
            color: _isDark
                ? CupertinoColors.systemGrey3
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 12),

        // Outer Root Glass Container
        GlassContainer(
          settings: settings,
          shape: const LiquidRoundedSuperellipse(borderRadius: 24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.waveform_path_ecg,
                          color: Color(0xFF007AFF),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Host Glass Surface',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Zero Overdraw',
                        style: TextStyle(
                          color: Color(0xFF34C759),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nested Card (Uses _VibrancyFill under the hood)
                GlassCard(
                  settings: settings,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF007AFF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.music_note_2,
                            color: Color(0xFF007AFF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Spatial Audio Engine',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Vibrancy fill preserves rim highlights without secondary blur',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isDark
                                      ? CupertinoColors.systemGrey2
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Row of Nested Glass Buttons
                Row(
                  children: [
                    Expanded(
                      child: GlassButton.custom(
                        onTap: () {},
                        settings: settings,
                        shape: const LiquidRoundedRectangle(borderRadius: 14),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.play_fill, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Resume',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton.custom(
                        onTap: () {},
                        settings: settings,
                        shape: const LiquidRoundedRectangle(borderRadius: 14),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.slider_horizontal_3,
                                  size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Options',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Continuous Menu Drag Tracking',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Slide across items without lifting your finger. Specular lighting tracks seamlessly.',
          style: TextStyle(
            fontSize: 12,
            color: _isDark
                ? CupertinoColors.systemGrey3
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GlassMenu(
            menuAlignment: GlassMenuAlignment.bottomCenter,
            autoAdjustToScreen: true,
            // Uses default glowOnTapOnly: false (1.5.0 tracking)
            items: [
              GlassMenuItem(
                title: 'Option 1 — First Item',
                icon: const Icon(CupertinoIcons.star_fill),
                onTap: () {},
              ),
              GlassMenuItem(
                title: 'Option 2 — Drag to Me',
                icon: const Icon(CupertinoIcons.hand_draw_fill),
                onTap: () {},
              ),
              GlassMenuItem(
                title: 'Option 3 — Continuous Glow',
                icon: const Icon(CupertinoIcons.sparkles),
                onTap: () {},
              ),
              const GlassMenuDivider(),
              GlassMenuItem(
                title: 'Cancel Action',
                isDestructive: true,
                icon: const Icon(CupertinoIcons.xmark_circle),
                onTap: () {},
              ),
            ],
            triggerBuilder: (ctx, toggle) => GlassButton.custom(
              onTap: toggle,
              width: 240,
              height: 46,
              shape: const LiquidRoundedRectangle(borderRadius: 23),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.line_horizontal_3_decrease, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Open Interactive Menu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsCard(LiquidGlassSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lighting & Optics',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Fine-tune real-time GLSL specular parameters and physical rim response.',
          style: TextStyle(
            fontSize: 12,
            color: _isDark
                ? CupertinoColors.systemGrey3
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          settings: settings,
          shape: const LiquidRoundedSuperellipse(borderRadius: 20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Light Intensity
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.sun_max,
                      size: 16,
                      color: _isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 72,
                      child: Text(
                        'Intensity',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoSlider(
                        value: _lightIntensity,
                        min: 0.0,
                        max: 2.0,
                        divisions: 20,
                        onChanged: (v) => setState(() => _lightIntensity = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: Text(
                        _lightIntensity.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Depth / Thickness
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.layers,
                      size: 16,
                      color: _isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 72,
                      child: Text(
                        'Depth',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoSlider(
                        value: _thickness,
                        min: 8.0,
                        max: 45.0,
                        divisions: 15,
                        onChanged: (v) => setState(() => _thickness = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${_thickness.toStringAsFixed(0)}pt',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Sharpness
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.circle_grid_hex,
                          size: 16,
                          color: _isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sharpness',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSegmentedControl<GlassSpecularSharpness>(
                      groupValue: _sharpness,
                      children: const {
                        GlassSpecularSharpness.soft: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text('Soft', style: TextStyle(fontSize: 12)),
                        ),
                        GlassSpecularSharpness.medium: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text('Medium', style: TextStyle(fontSize: 12)),
                        ),
                        GlassSpecularSharpness.sharp: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text('Sharp', style: TextStyle(fontSize: 12)),
                        ),
                      },
                      onValueChanged: (v) => setState(() => _sharpness = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
