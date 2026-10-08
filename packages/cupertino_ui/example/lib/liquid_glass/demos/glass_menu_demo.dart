/// GlassMenu Demo — all 9 alignment positions, adjustable item count,
/// scrollable overflow handling, continuous swipe-to-select, and premium glass quality.
///
/// Includes test controls for text scaling and light/dark theme to verify
/// the fixes for GitHub issues (auto-scroll with large text, light mode colors).
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_menu_demo.dart
library;

import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ── Glass settings matching the Apple Messages demo quality ──────────────────

final _kTriggerGlass = LiquidGlassSettings(
  glassColor: CupertinoColors.white.withValues(alpha: 0.1),
  thickness: 18,
  blur: 3,
  lightIntensity: 0.4,
  ambientStrength: 0.08,
  chromaticAberration: 0.01,
  refractiveIndex: 1.2,
  saturation: 1.15,
);

final _kMenuGlass = LiquidGlassSettings(
  glassColor: CupertinoColors.white.withValues(alpha: 0.12),
  thickness: 18,
  blur: 6,
  lightIntensity: 0.6,
  ambientStrength: 0.15,
  chromaticAberration: 0.0,
  refractiveIndex: 0.7,
  saturation: 1.2,
);

// ── App entry point ──────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    adaptiveQuality: true,
    child: const _App(),
  ));
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'GlassMenu Demo',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
      ),
      home: MenuDemoPage(
        isDark: _isDark,
        onThemeToggle: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

// ── Demo screen ─────────────────────────────────────────────────────────────

class MenuDemoPage extends StatefulWidget {
  const MenuDemoPage({
    super.key,
    this.isDark,
    this.onThemeToggle,
  });

  /// External theme state. If null, the widget manages its own toggle.
  final bool? isDark;

  /// External theme toggle callback. If null, the widget manages its own toggle.
  final VoidCallback? onThemeToggle;

  @override
  State<MenuDemoPage> createState() => _MenuDemoPageState();
}

class _MenuDemoPageState extends State<MenuDemoPage> {
  int _itemCount = 5;
  double _textScale = 1.0;
  bool _internalIsDark = true;
  bool _glowOnTapOnly = false;
  // ── Continuous swipe demo state (Issue #331) ──────────────────────────────
  bool _continuousSwipeEnabled = true;
  double _continuousSwipeSlop = 10.0;
  String? _lastSelected;

  bool get _isDark => widget.isDark ?? _internalIsDark;

  void _toggleTheme() {
    if (widget.onThemeToggle != null) {
      widget.onThemeToggle!();
    } else {
      setState(() => _internalIsDark = !_internalIsDark);
    }
  }

  List<Widget> get _items => [
        // Section label — tests theme color inheritance
        const GlassMenuLabel(title: 'Actions'),
        GlassMenuItem(
          title: 'Navigate to Page',
          icon: const Icon(CupertinoIcons.arrow_right_circle_fill),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => const _SampleDestinationPage(),
              ),
            );
          },
        ),
        ...List.generate(
          _itemCount,
          (i) => GlassMenuItem(
            title: 'Option ${i + 1}',
            icon: Icon(CupertinoIcons.star_fill),
            onTap: () => debugPrint('tapped ${i + 1}'),
          ),
        ),
        // Divider — tests theme color inheritance
        const GlassMenuDivider(),
        GlassMenuItem(
          title: 'Delete',
          icon: Icon(CupertinoIcons.trash),
          isDestructive: true,
          onTap: () => debugPrint('delete'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final labelColor = _isDark
        ? CupertinoColors.white.withValues(alpha: 0.70)
        : CupertinoColors.black.withValues(alpha: 0.54);
    final titleColor = _isDark
        ? CupertinoColors.white
        : CupertinoColors.black.withValues(alpha: 0.87);

    // Wrap with MediaQuery to override text scale for testing
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(_textScale),
      ),
      child: CupertinoPageScaffold(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Wallpaper
            Image.asset(
              'assets/wallpaper.jpg',
              fit: BoxFit.cover,
            ),

            // Theme-aware scrim
            Container(
              color: _isDark
                  ? CupertinoColors.black.withValues(alpha: 0.25)
                  : CupertinoColors.white.withValues(alpha: 0.15),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── Title ────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'GlassMenu — All Alignments',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // ── Controls row ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Item count slider
                        Row(
                          children: [
                            Text(
                              'Items: $_itemCount',
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: CupertinoSlider(
                                value: _itemCount.toDouble(),
                                min: 1,
                                max: 20,
                                divisions: 19,
                                onChanged: (v) =>
                                    setState(() => _itemCount = v.round()),
                              ),
                            ),
                          ],
                        ),

                        // Text scale slider (to test the auto-scroll fix)
                        Row(
                          children: [
                            Text(
                              'Text: ${_textScale.toStringAsFixed(1)}×',
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: CupertinoSlider(
                                value: _textScale,
                                min: 1.0,
                                max: 3.0,
                                divisions: 20,
                                onChanged: (v) =>
                                    setState(() => _textScale = v),
                              ),
                            ),
                          ],
                        ),

                        // Theme toggle
                        Row(
                          children: [
                            Text(
                              'Theme:',
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            CupertinoButton(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              onPressed: _toggleTheme,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isDark
                                        ? CupertinoIcons.moon_fill
                                        : CupertinoIcons.sun_max_fill,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    _isDark ? 'Dark' : 'Light',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Touch glow tracking mode (1.5.0 parity test)
                        Row(
                          children: [
                            Text(
                              'Glow Mode:',
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              onPressed: () => setState(
                                  () => _glowOnTapOnly = !_glowOnTapOnly),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _glowOnTapOnly
                                        ? CupertinoIcons.hand_point_right
                                        : CupertinoIcons.hand_draw_fill,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _glowOnTapOnly
                                        ? 'Tap-Only'
                                        : 'Tracking (iOS 26 Default)',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  // ── Continuous swipe demo ─────────────────────────────────
                  _buildContinuousSwipeSection(labelColor, titleColor),

                  SizedBox(height: 8),

                  // ── 3×3 grid of menu triggers ─────────────────────────
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _row([
                            _trigger(
                              label: '↖ TL',
                              alignment: GlassMenuAlignment.topLeft,
                              width: 52,
                              height: 52,
                              shape: const LiquidOval(),
                            ),
                            _trigger(
                              label: '↑ TC',
                              alignment: GlassMenuAlignment.topCenter,
                              width: 96,
                              height: 40,
                            ),
                            _trigger(
                              label: '↗ TR',
                              alignment: GlassMenuAlignment.topRight,
                              width: 52,
                              height: 52,
                              shape: const LiquidOval(),
                            ),
                          ]),
                          _row([
                            _trigger(
                              label: '← CL',
                              alignment: GlassMenuAlignment.centerLeft,
                              width: 96,
                              height: 40,
                            ),
                            _trigger(
                              label: '●',
                              alignment: GlassMenuAlignment.center,
                              width: 56,
                              height: 56,
                              shape: const LiquidOval(),
                            ),
                            _trigger(
                              label: 'CR →',
                              alignment: GlassMenuAlignment.centerRight,
                              width: 96,
                              height: 40,
                            ),
                          ]),
                          _row([
                            _trigger(
                              label: '↙ BL',
                              alignment: GlassMenuAlignment.bottomLeft,
                              width: 52,
                              height: 52,
                              shape: const LiquidOval(),
                            ),
                            _trigger(
                              label: '↓ BC',
                              alignment: GlassMenuAlignment.bottomCenter,
                              width: 96,
                              height: 40,
                            ),
                            _trigger(
                              label: '↘ BR',
                              alignment: GlassMenuAlignment.bottomRight,
                              width: 52,
                              height: 52,
                              shape: const LiquidOval(),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );

  Widget _trigger({
    required String label,
    required GlassMenuAlignment alignment,
    double width = 96,
    double height = 40,
    LiquidShape? shape,
  }) =>
      _Trigger(
        label: label,
        alignment: alignment,
        items: _items,
        width: width,
        height: height,
        shape: shape,
        glowOnTapOnly: _glowOnTapOnly,
      );

  // ── Continuous swipe demo panel ───────────────────────────────────────────

  Widget _buildContinuousSwipeSection(Color labelColor, Color titleColor) {
    final List<Widget> swipeItems = [
      GlassMenuItem(
        title: '🔔  Notifications',
        icon: const Icon(CupertinoIcons.bell_fill),
        onTap: () => setState(() => _lastSelected = 'Notifications'),
      ),
      GlassMenuItem(
        title: '📷  Camera',
        icon: const Icon(CupertinoIcons.camera_fill),
        onTap: () => setState(() => _lastSelected = 'Camera'),
      ),
      GlassMenuItem(
        title: '📁  Files',
        icon: const Icon(CupertinoIcons.folder_fill),
        onTap: () => setState(() => _lastSelected = 'Files'),
      ),
      const GlassMenuDivider(),
      GlassMenuItem(
        title: '🗑  Delete',
        icon: const Icon(CupertinoIcons.trash_fill),
        isDestructive: true,
        onTap: () => setState(() => _lastSelected = 'Delete'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Text(
            'Continuous Swipe-to-Select  (#331)',
            style: TextStyle(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Press-and-hold, slide to an item, release — no second tap needed.',
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
            ),
          ),
        ),

        // ── Toggle ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Enable:',
                style: TextStyle(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: _continuousSwipeEnabled,
                onChanged: (v) => setState(() => _continuousSwipeEnabled = v),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _continuousSwipeEnabled
                      ? 'ON — swipe to select'
                      : 'OFF — tap to open, tap to select',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Slop slider ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Slop: ${_continuousSwipeSlop.round()} px',
                style: TextStyle(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: CupertinoSlider(
                  value: _continuousSwipeSlop,
                  min: 2,
                  max: 40,
                  divisions: 38,
                  onChanged: (v) => setState(() => _continuousSwipeSlop = v),
                ),
              ),
            ],
          ),
        ),

        // ── Interactive row of pull-down buttons ──────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Standard GlassPullDownButton — uses the feature by default.
              Column(
                children: [
                  GlassPullDownButton(
                    enableContinuousSwipe: _continuousSwipeEnabled,
                    continuousSwipeSlop: _continuousSwipeSlop,
                    quality: GlassQuality.premium,
                    icon: const Icon(CupertinoIcons.ellipsis_circle_fill),
                    items: swipeItems,
                    onSelected: (title) =>
                        setState(() => _lastSelected = title),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PullDownButton',
                    style: TextStyle(color: labelColor, fontSize: 10),
                  ),
                ],
              ),

              // Raw GlassMenu with opt-in swipe — shows the API for custom triggers.
              Column(
                children: [
                  GlassMenu(
                    enableContinuousSwipe: _continuousSwipeEnabled,
                    continuousSwipeSlop: _continuousSwipeSlop,
                    menuAlignment: GlassMenuAlignment.topCenter,
                    quality: GlassQuality.premium,
                    items: swipeItems,
                    trigger: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            CupertinoColors.activeBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color:
                              CupertinoColors.activeBlue.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.activeBlue,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'GlassMenu (raw)',
                    style: TextStyle(color: labelColor, fontSize: 10),
                  ),
                ],
              ),

              // GlassPullDownButton with a fixed-height scrollable menu.
              // Continuous swipe must NOT arm here (Bug #331 regression check).
              Column(
                children: [
                  GlassPullDownButton(
                    enableContinuousSwipe: _continuousSwipeEnabled,
                    continuousSwipeSlop: _continuousSwipeSlop,
                    quality: GlassQuality.premium,
                    menuWidth: 180,
                    icon: const Icon(CupertinoIcons.list_bullet),
                    items: [
                      ...List.generate(
                        8,
                        (i) => GlassMenuItem(
                          title: 'Row ${i + 1}',
                          onTap: () =>
                              setState(() => _lastSelected = 'Row ${i + 1}'),
                        ),
                      ),
                    ],
                    onSelected: (t) => setState(() => _lastSelected = t),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scrollable (no swipe)',
                    style: TextStyle(color: labelColor, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Last selected indicator ───────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _lastSelected != null
                  ? '✅  Last selected: $_lastSelected'
                  : '← Try a swipe gesture on any button above',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Trigger widget ───────────────────────────────────────────────────────────

class _Trigger extends StatelessWidget {
  const _Trigger({
    required this.label,
    required this.alignment,
    required this.items,
    this.width = 96,
    this.height = 40,
    this.shape,
    this.glowOnTapOnly = false,
  });

  final String label;
  final GlassMenuAlignment alignment;
  final List<Widget> items;
  final double width;
  final double height;
  final LiquidShape? shape;
  final bool glowOnTapOnly;

  @override
  Widget build(BuildContext context) {
    final effectiveShape =
        shape ?? LiquidRoundedRectangle(borderRadius: height / 2);

    return GlassMenu(
      menuAlignment: alignment,
      autoAdjustToScreen: true,
      items: items,
      settings: _kMenuGlass,
      quality: GlassQuality.premium,
      glowOnTapOnly: glowOnTapOnly,
      triggerBuilder: (ctx, toggle) => AdaptiveLiquidGlassLayer(
        child: GlassButton.custom(
          onTap: toggle,
          width: width,
          height: height,
          settings: _kTriggerGlass,
          quality: GlassQuality.premium,
          shape: effectiveShape,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleDestinationPage extends StatelessWidget {
  const _SampleDestinationPage();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Destination Page'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: CupertinoColors.activeGreen,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Route Transition Test',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The menu dismissed instantly on frame 0 of the transition without overlapping this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .color
                      ?.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
