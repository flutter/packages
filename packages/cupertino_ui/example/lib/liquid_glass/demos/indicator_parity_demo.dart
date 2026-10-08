/// Indicator Parity Demo
///
/// Shows all five [AnimatedGlassIndicator]-powered widgets side-by-side with
/// live tuning sliders so you can compare and calibrate iOS 26 parity:
///   • GlassSegmentedControl (flat track)
///   • GlassSegmentedControl with icons + labels
///   • GlassTabBar.inline (compact glass track, text-only)
///   • GlassTabBar.bottom
///   • GlassTabBar.searchable
///
/// Run standalone:
///   flutter run -t example/lib/demos/indicator_parity_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// Capsule sentinel — delegates to GlassDefaults so the demo stays in sync
// with the package constant. Both bar and indicator pass this through to the
// shader so it clamps to a true capsule at any bar height.
const _kCapsuleSentinel = GlassDefaults.capsuleRadius;
// The slider UI travels 4..36; at the max position we remap to _kCapsuleSentinel.
const _kSliderCapsuleThreshold = 36.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _DemoApp()));
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Indicator Parity',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const IndicatorParityDemoPage(),
    );
  }
}

// =============================================================================
// Main page
// =============================================================================

class IndicatorParityDemoPage extends StatefulWidget {
  const IndicatorParityDemoPage({super.key});

  @override
  State<IndicatorParityDemoPage> createState() =>
      _IndicatorParityDemoPageState();
}

class _IndicatorParityDemoPageState extends State<IndicatorParityDemoPage> {
  // ── Shared live tuning values ──────────────────────────────────────────────
  double _pinchStrength = 0.4;
  double _expansionH = 12.0;
  double _expansionV = 8.0;
  double _aberration = 0.15;
  // glassColor alpha — 0.0 = no tint (new default), 0.15 = old default
  double _glassTint = 0.0;
  // refractiveIndex — 1.15 matches GlassDefaults.refractiveIndex, the same
  // value used by all Apple demos and the main example app.
  double _refraction = 1.15;
  // ── Shape — 3-tier radius hierarchy ─────────────────────────────────────
  // Tier 1 (default): both bar and indicator are capsule (iOS 26 authentic).
  //   9999 is the sentinel value — widgets pass it directly to the shader so
  //   it clamps to a perfect capsule even during jelly-bloom expansion.
  // Tier 2 (bar slider): user drags bar radius below 36 → indicator auto-tracks
  //   at barBorderRadius − 4 (nested-arc formula, same as GlassSegmentedControl).
  // Tier 3 (indicator slider): explicit override, shown with a Reset-to-Auto button.
  //
  // Slider mapping: the slider travels 4..36 in the UI. When the slider is at
  // its maximum (36), we write 9999.0 to mean "true capsule sentinel". Values
  // below 36 are written verbatim.
  double _barBorderRadius = _kCapsuleSentinel; // default: true capsule (iOS 26)
  double?
      _indicatorBorderRadiusOverride; // null = auto (capsule or barRadius − 4)

  // ── Per-widget state ───────────────────────────────────────────────────────
  int _segSelected = 0;
  int _tabSelected = 0;
  int _inlineSelected = 0;
  int _inlineIconSelected = 0;
  int _barSelected = 0;
  int _searchBarSelected = 0;
  bool _isSearching = false;

  // ── Tab/segment data ───────────────────────────────────────────────────────
  static const _segments = <GlassSegment>[
    GlassSegment(label: 'Journals'),
    GlassSegment(label: 'Photos'),
    GlassSegment(label: 'Clips')
  ];

  static const _tabs = [
    GlassSegment(label: 'Featured', icon: Icon(CupertinoIcons.star_fill)),
    GlassSegment(label: 'Browse', icon: Icon(CupertinoIcons.square_grid_2x2)),
    GlassSegment(label: 'Charts', icon: Icon(CupertinoIcons.chart_bar_fill)),
    GlassSegment(label: 'Radio', icon: Icon(CupertinoIcons.radiowaves_left)),
  ];

  static const _barTabs = <GlassTab>[
    GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
    GlassTab(label: 'Discover', icon: Icon(CupertinoIcons.compass_fill)),
    GlassTab(label: 'Library', icon: Icon(CupertinoIcons.book_fill)),
    GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person_fill)),
  ];

  // Text-only tabs — highlights the label-centric inline use case.
  static const _inlineTabs = <GlassTab>[
    GlassTab(label: 'For You'),
    GlassTab(label: 'Following'),
    GlassTab(label: 'New'),
  ];

  // ── Derived ────────────────────────────────────────────────────────────────

  /// Builds the shared indicatorSettings from the live sliders.
  /// Uses baseIndicatorSettings.copyWith so other base values (blur:0, etc.)
  /// are preserved — this is the merge-gap fix in action.
  LiquidGlassSettings get _indicatorSettings =>
      AnimatedGlassIndicator.baseIndicatorSettings.copyWith(
        chromaticAberration: _aberration,
        refractiveIndex: _refraction,
        glassColor: Color.from(
          alpha: _glassTint,
          red: 1,
          green: 1,
          blue: 1,
        ),
      );

  EdgeInsets get _expansion =>
      EdgeInsets.symmetric(horizontal: _expansionH, vertical: _expansionV);

  // ==========================================================================
  // Build
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Background — rich gradient so glass refraction is visible ─────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0D1A),
                  Color(0xFF0F1E3E),
                  Color(0xFF12103A),
                  Color(0xFF1B0A3E),
                ],
              ),
            ),
          ),
          // Decorative orbs — give the glass something colourful to refract.
          Positioned(
            top: 120,
            left: -60,
            child: _GlowOrb(color: const Color(0xFF5E3AFF), size: 220),
          ),
          Positioned(
            top: 300,
            right: -40,
            child: _GlowOrb(color: const Color(0xFF0A84FF), size: 180),
          ),
          Positioned(
            top: 520,
            left: 60,
            child: _GlowOrb(color: const Color(0xFFFF375F), size: 160),
          ),
          Positioned(
            top: 720,
            right: 20,
            child: _GlowOrb(color: const Color(0xFF30D158), size: 140),
          ),
          Positioned(
            top: 920,
            left: -30,
            child: _GlowOrb(color: const Color(0xFFFFD60A), size: 150),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 240),
              children: [
                // Title
                Text(
                  'Indicator Parity',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'iOS 26 calibration — all six pill widgets, live tuning',
                  style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 20),

                // ── Tuner panel ─────────────────────────────────────────────
                _TunerPanel(
                  pinchStrength: _pinchStrength,
                  expansionH: _expansionH,
                  expansionV: _expansionV,
                  aberration: _aberration,
                  glassTint: _glassTint,
                  refraction: _refraction,
                  barBorderRadius: _barBorderRadius,
                  indicatorBorderRadius: _indicatorBorderRadiusOverride,
                  onPinchChanged: (v) => setState(() => _pinchStrength = v),
                  onExpansionHChanged: (v) => setState(() => _expansionH = v),
                  onExpansionVChanged: (v) => setState(() => _expansionV = v),
                  onAberrationChanged: (v) => setState(() => _aberration = v),
                  onGlassTintChanged: (v) => setState(() => _glassTint = v),
                  onRefractionChanged: (v) => setState(() => _refraction = v),
                  onBarBorderRadiusChanged: (v) =>
                      setState(() => _barBorderRadius = v),
                  onIndicatorBorderRadiusChanged: (v) =>
                      setState(() => _indicatorBorderRadiusOverride = v),
                  onResetIndicatorBorderRadius: () =>
                      setState(() => _indicatorBorderRadiusOverride = null),
                ),

                SizedBox(height: 28),

                // ── GlassSegmentedControl ────────────────────────────────────
                _WidgetSection(
                  label: 'GlassSegmentedControl',
                  color: const Color(0xFF5E3AFF),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: GlassSegmentedControl(
                      segments: _segments,
                      selectedIndex: _segSelected,
                      onSegmentSelected: (i) =>
                          setState(() => _segSelected = i),
                      quality: GlassQuality.premium,
                      borderRadius: _barBorderRadius,
                      indicatorBorderRadius: _indicatorBorderRadiusOverride,
                      indicatorPinchStrength: _pinchStrength,
                      indicatorExpansion: _expansion,
                      indicatorSettings: _indicatorSettings,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // ── GlassSegmentedControl ──────────────────────────────────────────────
                _WidgetSection(
                  label: 'GlassSegmentedControl',
                  color: const Color(0xFF0A84FF),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: GlassSegmentedControl(
                      segments: _tabs,
                      selectedIndex: _tabSelected,
                      onSegmentSelected: (i) =>
                          setState(() => _tabSelected = i),
                      quality: GlassQuality.premium,
                      // height: 56 required for icon + label tabs.
                      // Default 44 is for icon-only or text-only.
                      height: 56,
                      // Full-pill radius is now the default out of the box!
                      iconSize: 20,
                      selectedTextStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedTextStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      borderRadius: _barBorderRadius,
                      indicatorBorderRadius: _indicatorBorderRadiusOverride,
                      indicatorPinchStrength: _pinchStrength,
                      indicatorExpansion: _expansion,
                      indicatorSettings: _indicatorSettings,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // ── GlassTabBar.inline ───────────────────────────────────────
                _WidgetSection(
                  label: 'GlassTabBar.inline',
                  color: const Color(0xFF30B0C7),
                  child: Column(
                    children: [
                      // Extra breathing room — the 40px glass track refracts
                      // anything within ~20px. Push label clear of the surface.
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: GlassTabBar.inline(
                          tabs: _inlineTabs,
                          selectedIndex: _inlineSelected,
                          onTabSelected: (i) =>
                              setState(() => _inlineSelected = i),
                          quality: GlassQuality.premium,
                          barBorderRadius: _barBorderRadius,
                          indicatorBorderRadius: _indicatorBorderRadiusOverride,
                          indicatorPinchStrength: _pinchStrength,
                          indicatorSettings: _indicatorSettings,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                _WidgetSection(
                  label: 'GlassTabBar.inline (icon + text)',
                  color: const Color(0xFF5AC8FA),
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      GlassTabBar.inline(
                        tabs: _barTabs,
                        selectedIndex: _inlineIconSelected,
                        onTabSelected: (i) =>
                            setState(() => _inlineIconSelected = i),
                        quality: GlassQuality.premium,
                        barHeight: 52,
                        barBorderRadius: _barBorderRadius,
                        indicatorBorderRadius: _indicatorBorderRadiusOverride,
                        indicatorPinchStrength: _pinchStrength,
                        indicatorSettings: _indicatorSettings,
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // ── GlassTabBar.bottom (Premium) ─────────────────────────────
                _WidgetSection(
                  label: 'GlassBottomBar — Premium',
                  color: const Color(0xFFFF375F),
                  child: GlassTabBar.bottom(
                    tabs: _barTabs,
                    selectedIndex: _barSelected,
                    onTabSelected: (i) => setState(() => _barSelected = i),
                    quality: GlassQuality.premium,
                    indicatorPinchStrength: _pinchStrength,
                    indicatorExpansion: _expansion,
                    indicatorSettings: _indicatorSettings,
                    barBorderRadius: _barBorderRadius,
                    indicatorBorderRadius: _indicatorBorderRadiusOverride,
                  ),
                ),

                SizedBox(height: 16),

                // ── GlassTabBar.bottom (Standard) ─────────────────────────────
                _WidgetSection(
                  label: 'GlassBottomBar — Standard',
                  color: const Color(0xFFFF9F0A),
                  child: GlassTabBar.bottom(
                    tabs: _barTabs,
                    selectedIndex: _barSelected,
                    onTabSelected: (i) => setState(() => _barSelected = i),
                    quality: GlassQuality.standard,
                    indicatorPinchStrength: _pinchStrength,
                    indicatorExpansion: _expansion,
                    indicatorSettings: _indicatorSettings,
                    barBorderRadius: _barBorderRadius,
                    indicatorBorderRadius: _indicatorBorderRadiusOverride,
                  ),
                ),

                SizedBox(height: 16),

                // ── GlassSearchableBottomBar ─────────────────────────────────
                _WidgetSection(
                  label: 'GlassSearchableBottomBar',
                  color: const Color(0xFF30D158),
                  child: GlassTabBar.searchable(
                    tabs: _barTabs,
                    selectedIndex: _searchBarSelected,
                    isSearchActive: _isSearching,
                    onTabSelected: (i) =>
                        setState(() => _searchBarSelected = i),
                    quality: GlassQuality.premium,
                    indicatorPinchStrength: _pinchStrength,
                    indicatorExpansion: _expansion,
                    indicatorSettings: _indicatorSettings,
                    barBorderRadius: _barBorderRadius,
                    indicatorBorderRadius: _indicatorBorderRadiusOverride,
                    searchConfig: GlassSearchBarConfig(
                      hintText: 'Search…',
                      showsCancelButton: true,
                      onSearchToggle: (v) => setState(() => _isSearching = v),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // ── Live values badge ────────────────────────────────────────
                _LiveValuesBadge(
                  pinchStrength: _pinchStrength,
                  expansionH: _expansionH,
                  expansionV: _expansionV,
                  aberration: _aberration,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tuner panel — collapsible, default closed
// =============================================================================

class _TunerPanel extends StatefulWidget {
  const _TunerPanel({
    required this.pinchStrength,
    required this.expansionH,
    required this.expansionV,
    required this.aberration,
    required this.glassTint,
    required this.refraction,
    required this.barBorderRadius,
    required this.indicatorBorderRadius,
    required this.onPinchChanged,
    required this.onExpansionHChanged,
    required this.onExpansionVChanged,
    required this.onAberrationChanged,
    required this.onGlassTintChanged,
    required this.onRefractionChanged,
    required this.onBarBorderRadiusChanged,
    required this.onIndicatorBorderRadiusChanged,
    required this.onResetIndicatorBorderRadius,
  });

  final double pinchStrength;
  final double expansionH;
  final double expansionV;
  final double aberration;
  final double glassTint;
  final double refraction;
  final double barBorderRadius;

  /// null = auto (barBorderRadius − 4). Non-null = explicit Tier-3 override.
  final double? indicatorBorderRadius;
  final ValueChanged<double> onPinchChanged;
  final ValueChanged<double> onExpansionHChanged;
  final ValueChanged<double> onExpansionVChanged;
  final ValueChanged<double> onAberrationChanged;
  final ValueChanged<double> onGlassTintChanged;
  final ValueChanged<double> onRefractionChanged;
  final ValueChanged<double> onBarBorderRadiusChanged;
  final ValueChanged<double> onIndicatorBorderRadiusChanged;

  /// Resets indicator radius back to auto (Tier 2 → Tier 1/2).
  final VoidCallback onResetIndicatorBorderRadius;

  @override
  State<_TunerPanel> createState() => _TunerPanelState();
}

class _TunerPanelState extends State<_TunerPanel> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !_isOpen ? () => setState(() => _isOpen = true) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isOpen
              ? CupertinoColors.white.withValues(alpha: 0.09)
              : CupertinoColors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isOpen
                ? CupertinoColors.white.withValues(alpha: 0.18)
                : CupertinoColors.white.withValues(alpha: 0.10),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row — always visible, tappable ─────────────────────
              GestureDetector(
                onTap: () => setState(() => _isOpen = !_isOpen),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.tuningfork,
                          color: CupertinoColors.white.withValues(alpha: 0.70),
                          size: 14),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'LIVE TUNER — bottom bar, searchable & segmented controls',
                          style: TextStyle(
                            color:
                                CupertinoColors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      // Current values summary (visible when closed)
                      if (!_isOpen) ...[
                        _MiniValuePill(
                            label: 'P',
                            value: widget.pinchStrength.toStringAsFixed(1),
                            color: const Color(0xFF5E3AFF)),
                        SizedBox(width: 4),
                        _MiniValuePill(
                            label: 'E',
                            value:
                                '${widget.expansionH.round()}×${widget.expansionV.round()}',
                            color: const Color(0xFF0A84FF)),
                      ],
                      SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        child: Icon(
                          CupertinoIcons.chevron_down,
                          color: CupertinoColors.white.withValues(alpha: 0.4),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Sliders — only when open ──────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _isOpen
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Color(0x22FFFFFF)),
                            SizedBox(height: 10),
                            _SliderRow(
                              label: 'Pinch Strength',
                              value: widget.pinchStrength,
                              min: 0,
                              max: 1,
                              divisions: 20,
                              displayValue:
                                  widget.pinchStrength.toStringAsFixed(2),
                              accentColor: const Color(0xFF5E3AFF),
                              onChanged: widget.onPinchChanged,
                            ),
                            _SliderRow(
                              label: 'Expansion H',
                              value: widget.expansionH,
                              min: 0,
                              max: 28,
                              divisions: 28,
                              displayValue: '${widget.expansionH.round()} px',
                              accentColor: const Color(0xFF0A84FF),
                              onChanged: widget.onExpansionHChanged,
                            ),
                            _SliderRow(
                              label: 'Expansion V',
                              value: widget.expansionV,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              displayValue: '${widget.expansionV.round()} px',
                              accentColor: const Color(0xFF0A84FF),
                              onChanged: widget.onExpansionVChanged,
                            ),
                            _SliderRow(
                              label: 'Chromatic Aberration',
                              value: widget.aberration,
                              min: 0,
                              max: 0.5,
                              divisions: 50,
                              displayValue:
                                  widget.aberration.toStringAsFixed(2),
                              accentColor: const Color(0xFFFF9F0A),
                              onChanged: widget.onAberrationChanged,
                            ),
                            _SliderRow(
                              label: 'Glass Tint (α)',
                              value: widget.glassTint,
                              min: 0,
                              max: 0.5,
                              divisions: 50,
                              displayValue: widget.glassTint.toStringAsFixed(2),
                              accentColor: const Color(0xFFBF5AF2),
                              onChanged: widget.onGlassTintChanged,
                            ),
                            _SliderRow(
                              label: 'Refraction (n)',
                              value: widget.refraction,
                              min: 1.0,
                              max: 1.5,
                              divisions: 50,
                              displayValue:
                                  widget.refraction.toStringAsFixed(2),
                              accentColor: const Color(0xFF64D2FF),
                              onChanged: widget.onRefractionChanged,
                            ),
                            SizedBox(height: 6),
                            Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Color(0x22FFFFFF)),
                            SizedBox(height: 6),
                            // ── Shape — 3-tier radius ──────────────────────
                            // Slider travels 4..36 in the UI; the max value (36)
                            // is mapped to the 9999 capsule sentinel on write.
                            _SliderRow(
                              label: 'Bar Radius  (Tier 1→2)',
                              value: widget.barBorderRadius >= _kCapsuleSentinel
                                  ? _kSliderCapsuleThreshold
                                  : widget.barBorderRadius,
                              min: 4,
                              max: 36,
                              divisions: 32,
                              displayValue:
                                  widget.barBorderRadius >= _kCapsuleSentinel
                                      ? 'capsule (default)'
                                      : '${widget.barBorderRadius.round()} px',
                              accentColor: const Color(0xFFFF9F0A),
                              onChanged: (v) => widget.onBarBorderRadiusChanged(
                                // Map slider max → true capsule sentinel
                                v >= _kSliderCapsuleThreshold
                                    ? _kCapsuleSentinel
                                    : v,
                              ),
                            ),
                            // Indicator radius — Tier 2 (auto) / Tier 3 (override)
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Indicator Radius  (Tier 2→3)',
                                        style: TextStyle(
                                          color: CupertinoColors.white
                                              .withValues(alpha: 0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (widget.indicatorBorderRadius !=
                                              null)
                                            GestureDetector(
                                              onTap: widget
                                                  .onResetIndicatorBorderRadius,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 6),
                                                child: Icon(
                                                  CupertinoIcons.refresh,
                                                  size: 14,
                                                  color: CupertinoColors.white
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF375F)
                                                  .withValues(
                                                alpha:
                                                    widget.indicatorBorderRadius ==
                                                            null
                                                        ? 0.1
                                                        : 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              widget.indicatorBorderRadius ==
                                                      null
                                                  ? 'auto'
                                                  : '${widget.indicatorBorderRadius!.round()} px',
                                              style: TextStyle(
                                                color: const Color(0xFFFF375F)
                                                    .withValues(
                                                  alpha:
                                                      widget.indicatorBorderRadius ==
                                                              null
                                                          ? 0.55
                                                          : 1.0,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures()
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: CupertinoSlider(
                                      value: (widget.indicatorBorderRadius ??
                                              (widget.barBorderRadius - 4)
                                                  .clamp(4.0, 30.0))
                                          .clamp(4.0, 30.0),
                                      min: 4,
                                      max: 30,
                                      divisions: 26,
                                      activeColor: const Color(0xFFFF375F),
                                      onChanged:
                                          widget.onIndicatorBorderRadiusChanged,
                                    ),
                                  ),
                                  if (widget.indicatorBorderRadius == null)
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 2, bottom: 2),
                                      child: Text(
                                        widget.barBorderRadius >=
                                                _kCapsuleSentinel
                                            ? 'auto: capsule  ·  drag to override'
                                            : 'auto: bar − 4 = ${(widget.barBorderRadius - 4).clamp(0, 999).round()} px  ·  drag to override',
                                        style: TextStyle(
                                          color: CupertinoColors.white
                                              .withValues(alpha: 0.35),
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact pill showing a single tuning value in the collapsed tuner header.
class _MiniValuePill extends StatelessWidget {
  const _MiniValuePill(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.accentColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final Color accentColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: CupertinoColors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: CupertinoSlider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              activeColor: accentColor,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Widget section card
// =============================================================================

class _WidgetSection extends StatelessWidget {
  const _WidgetSection({
    required this.label,
    required this.color,
    required this.child,
  });

  final String label;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coloured dot + label for identification in the demo
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Glass sits directly against the demo backdrop — no wrapper container.
        // Wrapping in a styled container would create a glass-in-glass situation
        // and cause the indicator glow to refract the container colour.
        child,
      ],
    );
  }
}

// =============================================================================
// Live values summary badge
// =============================================================================

class _LiveValuesBadge extends StatelessWidget {
  const _LiveValuesBadge({
    required this.pinchStrength,
    required this.expansionH,
    required this.expansionV,
    required this.aberration,
  });

  final double pinchStrength;
  final double expansionH;
  final double expansionV;
  final double aberration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT CODE SNIPPET',
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 10),
          Text(
            _buildSnippet(),
            style: TextStyle(
              color: Color(0xFF9EF8A8), // code green
              fontSize: 11,
              fontFamily: 'Menlo',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSnippet() {
    final h = expansionH.round();
    final v = expansionV.round();
    final pinch = pinchStrength.toStringAsFixed(2);
    final aber = aberration.toStringAsFixed(2);
    return 'GlassTabBar.bottom(\n'
        '  indicatorPinchStrength: $pinch,\n'
        '  indicatorExpansion: EdgeInsets.symmetric(\n'
        '    horizontal: $h, vertical: $v,\n'
        '  ),\n'
        '  indicatorSettings:\n'
        '    AnimatedGlassIndicator.baseIndicatorSettings\n'
        '      .copyWith(chromaticAberration: $aber),\n'
        '  // Same params on all 4 widgets ↑\n'
        ')';
  }
}

// =============================================================================
// Glow orb — decorative background circle for refraction
// =============================================================================

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.45),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
