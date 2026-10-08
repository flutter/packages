// Visual harness for verifying UV coordinate stability under scale (#292).
//
// Addresses GitHub issue #292:
//   "responsive_framework causes UV freeze jitter on all premium glass widgets"
//
// In responsive_framework, the entire widget tree is rendered inside a persistent
// scale transform (e.g. 0.90× on compact devices, 1.15× on tablets).
//
// Prior to #292, RenderLiquidGlassLayer._hasScale() detected any outer scale
// < 0.9999 as a CupertinoSheet push-back, freezing UV coordinates onto the
// viewport. This caused constant visual jitter / swimming distortion on GlassTabBar,
// GlassAppBar, and all premium glass widgets as content scrolled or idled at rest.
//
// This harness provides:
//   1. A real GlassTabBar.bottom with 4 interactive tabs.
//   2. An AlwaysScrollable CustomScrollView with 25 high-contrast cards
//      passing directly behind the GlassTabBar.
//   3. A live A/B toggle:
//        • "PR #292 Fix" (UV freeze inactive at rest → rock-solid tab bar)
//        • "Simulate Bug #292" (forces UV freeze at 0.90× scale → reveals jitter)
//   4. Configurable scale factor (0.50× to 1.50×, default 0.90×).
//   5. Auto-scroll and manual scroll controls.
//
//   cd example && flutter run -t lib/harnesses/uv_freeze_harness.dart
library;

import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
// ignore: implementation_imports
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_push_back_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'UV Freeze Harness (#292)',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: UvFreezeHarness(),
    );
  }
}

/// Visual regression harness for GitHub issue #292.
class UvFreezeHarness extends StatefulWidget {
  const UvFreezeHarness({super.key});

  @override
  State<UvFreezeHarness> createState() => _UvFreezeHarnessState();
}

class _UvFreezeHarnessState extends State<UvFreezeHarness>
    with SingleTickerProviderStateMixin {
  /// Simulated responsive_framework scale factor.
  /// 0.90 is the typical scale applied by responsive_framework on mobile.
  double _scale = 0.90;

  /// Selected tab index for the GlassTabBar.
  int _selectedTab = 0;

  /// When true, forcefully simulates the pre-fix bug by setting pushBackActive = true.
  /// At scale < 0.9999, this forces _hasScale() to return true, freezing UVs and
  /// reproducing the exact jitter from issue #292.
  bool _simulateOldBug = false;

  /// Continuous background animated motion.
  bool _animateBackground = true;

  /// Interactive card horizontal offset (doesn't block vertical scrolling).
  double _cardHorizontalOffset = 0.0;

  /// Glass quality tier under test.
  /// Standard quality is used here because GlassQuality.premium requires a
  /// LiquidGlassLayer ancestor (which GlassScaffold normally provides).
  /// UV coordinate stability under Transform.scale is testable at any tier.
  GlassQuality _quality = GlassQuality.standard;

  late final AnimationController _animController;
  final ScrollController _scrollController = ScrollController();

  static const _tabs = [
    GlassTab(
      label: 'Feed',
      icon: Icon(CupertinoIcons.rectangle_grid_2x2),
      activeIcon: Icon(CupertinoIcons.rectangle_grid_2x2_fill),
    ),
    GlassTab(
      label: 'Explore',
      icon: Icon(CupertinoIcons.compass),
      activeIcon: Icon(CupertinoIcons.compass_fill),
    ),
    GlassTab(
      label: 'Activity',
      icon: Icon(CupertinoIcons.bell),
      activeIcon: Icon(CupertinoIcons.bell_fill),
    ),
    GlassTab(
      label: 'Settings',
      icon: Icon(CupertinoIcons.gear),
      activeIcon: Icon(CupertinoIcons.gear_solid),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setScale(double s) {
    setState(() => _scale = (s * 100).roundToDouble() / 100);
  }

  void _scrollTo(double offset) {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  double get _maxScrollExtent => _scrollController.hasClients
      ? _scrollController.position.maxScrollExtent
      : 0.0;

  @override
  Widget build(BuildContext context) {
    // RESTRUCTURED: We no longer use GlassScaffold as the layout skeleton.
    //
    // The old approach routed the body through GlassScaffold → GlassScrollEdgeEffect
    // → bare Stack, which converted tight constraints to loose ones. The ListView
    // inside a loose-constrained Stack has infinite room, so it never scrolled.
    //
    // New approach: flat Stack with direct Positioned.fill → Transform.scale → ListView.
    // Positioned.fill guarantees tight screen-size constraints, Transform.scale passes
    // them through unchanged, and the ListView gets a finite viewport it must scroll
    // within. GlassTabBar and GlassAppBar are standalone Positioned overlays.
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF030712),
      child: Stack(
        children: [
          // ── 1. Animated background (unscaled, always fills the screen) ──────
          Positioned.fill(
            child: _HighFrequencyBackdrop(
              controller: _animController,
              animate: _animateBackground,
            ),
          ),

          // ── 2. Scrollable content list ────────────────────────────────────
          // Positioned.fill gives this subtree TIGHT constraints (screen size).
          // Transform.scale does NOT change layout constraints — it only affects
          // painting. So the ListView always receives tight height = screen height
          // and can scroll correctly regardless of the scale factor.
          Positioned.fill(
            child: Transform.scale(
              scale: _scale,
              alignment: Alignment.center,
              child: _buildBody(),
            ),
          ),

          // ── 3. GlassTabBar overlay (inside Transform.scale) ───────────────
          // This is THE surface under test for issue #292.
          // It's inside a scale transform (simulating responsive_framework) while
          // content scrolls behind it. UV coordinates must not freeze/jitter.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: _scale,
              alignment: Alignment.bottomCenter,
              child: LiquidGlassPushBackScope(
                active: _simulateOldBug,
                child: GlassTabBar.bottom(
                  selectedIndex: _selectedTab,
                  onTabSelected: (i) => setState(() => _selectedTab = i),
                  interactionBehavior: GlassInteractionBehavior.full,
                  selectedIconColor: const Color(0xFFA855F7),
                  iconSize: 26,
                  labelFontSize: 10,
                  tabs: _tabs,
                ),
              ),
            ),
          ),

          // ── 5. Floating diagnostic HUD (unscaled, always on top) ─────────
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: _DiagnosticHud(
              scale: _scale,
              simulateOldBug: _simulateOldBug,
              quality: _quality,
              animateBackground: _animateBackground,
              onScaleChanged: _setScale,
              onToggleBugSimulation: () =>
                  setState(() => _simulateOldBug = !_simulateOldBug),
              onToggleAnimate: () {
                setState(() => _animateBackground = !_animateBackground);
                if (_animateBackground) {
                  _animController.repeat();
                } else {
                  _animController.stop();
                }
              },
              onQualityChanged: (q) => setState(() => _quality = q),
              onOpenSheet: () => _presentModalSheet(context),
              onScrollToTop: () => _scrollTo(0),
              onScrollToBottom: () => _scrollTo(_maxScrollExtent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Positioned.fill (in build()) → Transform.scale → this ListView.
    // Transform.scale passes constraints through unchanged, so ListView gets
    // tight height = screen height from Positioned.fill. No GlassScrollEdgeEffect
    // or bare Stack in between to convert tight → loose constraints.
    return ListView(
      controller: _scrollController,
      primary: false,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      // Top: clears GlassAppBar + safe area. Bottom: clears GlassTabBar.
      padding: const EdgeInsets.fromLTRB(16, 128, 16, 160),
      children: [
        _buildStatusBanner(),
        const SizedBox(height: 16),
        _buildSheetTestCard(),
        const SizedBox(height: 16),
        _buildInteractiveCard(),
        const SizedBox(height: 16),
        // 25 high-contrast cards scrolling directly behind the GlassTabBar.
        for (int i = 1; i <= 25; i++) ...[
          _ContentSampleCard(index: i, quality: _quality),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// Prominent sheet test card — tap to open the real CupertinoSheet push-back.
  Widget _buildSheetTestCard() {
    return GestureDetector(
      onTap: () => _presentModalSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8B5CF6),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.square_stack_3d_up_fill,
                color: CupertinoColors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open Push-Back Sheet →',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tests real secondaryAnimation → UV freeze path.\n'
                    'Drag the sheet slowly. Watch the tab bar below.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFFDDD6FE),
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

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _simulateOldBug
            ? const Color(0xFFDC2626).withValues(alpha: 0.25)
            : const Color(0xFF059669).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _simulateOldBug
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _simulateOldBug
                    ? CupertinoIcons.exclamationmark_triangle_fill
                    : CupertinoIcons.checkmark_shield_fill,
                color: _simulateOldBug
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF6EE7B7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _simulateOldBug
                      ? 'SIMULATING ISSUE #292 BUG'
                      : 'PR #292 FIX ACTIVE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _simulateOldBug
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF6EE7B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _simulateOldBug
                ? 'UV coordinates are FORCED FROZEN (pre-fix bug under outer scale).\n'
                    '👉 Scroll this list now: watch the GlassTabBar at the bottom jitter and swim!'
                : 'UV coordinates track LIVE (PR #292 fix).\n'
                    '👉 Scroll this list now: the GlassTabBar remains 100% rock-solid under ${_scale.toStringAsFixed(2)}× scale.',
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCard() {
    return Center(
      child: GestureDetector(
        // Use horizontal drag so vertical scroll is NEVER blocked
        onHorizontalDragUpdate: (details) {
          setState(() {
            _cardHorizontalOffset =
                (_cardHorizontalOffset + details.delta.dx).clamp(-80.0, 80.0);
          });
        },
        child: Transform.translate(
          offset: Offset(_cardHorizontalOffset, 0),
          child: SizedBox(
            width: 290,
            height: 130,
            child: GlassCard(
              quality: _quality,
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.arrow_left_right,
                    size: 26,
                    color: Color(0xFF60A5FA),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Drag Horizontally / Scroll Vertically',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Swipe up/down to scroll list behind GlassTabBar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _presentModalSheet(BuildContext context) {
    // Use showCupertinoSheet (not showCupertinoModalPopup) so the parent route's
    // secondaryAnimation fires. GlassPage listens to secondaryAnimation and emits
    // LiquidGlassPushBackScope(active: true) — the real UV-freeze gate for push-backs.
    //
    // WHAT TO WATCH:
    //   • During open/close animation: GlassTabBar should be LOCKED solid (UV freeze ON).
    //   • While sheet is resting open at rest: GlassTabBar should track live (UV freeze OFF).
    //   • Scroll the list with sheet open — tab bar must still be solid.
    showCupertinoSheet<void>(
      context: context,
      // ignore: deprecated_member_use
      builder: (ctx) => GlassPage(
        background: const _SheetBackground(),
        statusBarStyle: GlassStatusBarStyle.light,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Color(0x44000000),
            middle: Text(
              'Push-Back Sheet',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👇 Drag this sheet slowly up and down.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Watch the GlassTabBar at the bottom of the page behind this sheet.\n\n'
                    '✅ PR #292 FIX: The tab bar should stay LOCKED during the scale '
                    'animation (UV freeze active via LiquidGlassPushBackScope).\n\n'
                    '✅ At rest: The tab bar should track live content (UV freeze OFF).\n\n'
                    'If the tab bar shimmers or swims during the drag, '
                    'the push-back scope is not emitting correctly.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Dismiss'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentSampleCard extends StatelessWidget {
  const _ContentSampleCard({required this.index, required this.quality});

  final int index;
  final GlassQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
      const [Color(0xFFEC4899), Color(0xFFF43F5E)],
      const [Color(0xFF10B981), Color(0xFF06B6D4)],
      const [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ][(index - 1) % 4];

    return GlassCard(
      quality: quality,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$index',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feed Item $index',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Passes behind the GlassTabBar at the bottom',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: Color(0x66FFFFFF),
            size: 16,
          ),
        ],
      ),
    );
  }
}

/// Floating HUD to configure scale, toggle bug simulation, and inspect state.
class _DiagnosticHud extends StatefulWidget {
  const _DiagnosticHud({
    required this.scale,
    required this.simulateOldBug,
    required this.quality,
    required this.animateBackground,
    required this.onScaleChanged,
    required this.onToggleBugSimulation,
    required this.onToggleAnimate,
    required this.onQualityChanged,
    required this.onOpenSheet,
    required this.onScrollToTop,
    required this.onScrollToBottom,
  });

  final double scale;
  final bool simulateOldBug;
  final GlassQuality quality;
  final bool animateBackground;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback onToggleBugSimulation;
  final VoidCallback onToggleAnimate;
  final ValueChanged<GlassQuality> onQualityChanged;
  final VoidCallback onOpenSheet;
  final VoidCallback onScrollToTop;
  final VoidCallback onScrollToBottom;

  @override
  State<_DiagnosticHud> createState() => _DiagnosticHudState();
}

class _DiagnosticHudState extends State<_DiagnosticHud> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF2111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.simulateOldBug
              ? const Color(0xFFEF4444)
              : const Color(0x33FFFFFF),
          width: widget.simulateOldBug ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onToggleBugSimulation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.simulateOldBug
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.simulateOldBug ? 'BUG: UV FROZEN' : 'FIX: LIVE UV',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.scale.toStringAsFixed(2)}×',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(30, 30),
                color: widget.simulateOldBug
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
                onPressed: widget.onToggleBugSimulation,
                child: Text(
                  widget.simulateOldBug ? 'Enable Fix' : 'Simulate Bug',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                child: Icon(
                  _expanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 16,
                  color: CupertinoColors.white,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0x22FFFFFF), height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Scale: ',
                  style: TextStyle(fontSize: 11, color: CupertinoColors.white),
                ),
                for (final preset in [0.75, 0.85, 0.90, 1.00, 1.15]) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      onTap: () => widget.onScaleChanged(preset),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (widget.scale - preset).abs() < 0.01
                              ? const Color(0xFF3B82F6)
                              : const Color(0x22FFFFFF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${preset.toStringAsFixed(2)}×',
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'Fine: ',
                  style: TextStyle(fontSize: 11, color: CupertinoColors.white),
                ),
                Expanded(
                  child: CupertinoSlider(
                    value: widget.scale,
                    min: 0.50,
                    max: 1.50,
                    divisions: 40,
                    onChanged: widget.onScaleChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: widget.animateBackground
                      ? const Color(0xFF10B981)
                      : const Color(0x33FFFFFF),
                  minimumSize: const Size(26, 26),
                  onPressed: widget.onToggleAnimate,
                  child: Text(
                    widget.animateBackground ? 'Motion: ON' : 'Motion: OFF',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      color: const Color(0x33FFFFFF),
                      minimumSize: const Size(26, 26),
                      onPressed: widget.onScrollToBottom,
                      child: const Text('Scroll End',
                          style: TextStyle(fontSize: 10)),
                    ),
                    const SizedBox(width: 4),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      color: const Color(0x33FFFFFF),
                      minimumSize: const Size(26, 26),
                      onPressed: widget.onScrollToTop,
                      child: const Text('Top', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A high-frequency geometric and gradient backdrop.
class _HighFrequencyBackdrop extends StatelessWidget {
  const _HighFrequencyBackdrop({
    required this.controller,
    required this.animate,
  });

  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = animate ? controller.value : 0.0;
        final angle = t * 2 * math.pi;

        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF030712),
                    Color(0xFF0B132B),
                    Color(0xFF1C2541),
                  ],
                ),
              ),
            ),
            CustomPaint(
              painter: _FineGridPainter(),
              size: Size.infinite,
            ),
            Positioned(
              left: 40 + math.cos(angle) * 120,
              top: 140 + math.sin(angle) * 100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFEC4899).withValues(alpha: 0.45),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.20),
                      const Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30 + math.sin(angle) * 100,
              bottom: 120 + math.cos(angle) * 120,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.50),
                      const Color(0xFF06B6D4).withValues(alpha: 0.20),
                      const Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FineGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x18FFFFFF)
      ..strokeWidth = 1.0;

    const step = 24.0;
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

/// High-contrast background for the push-back sheet test.
/// Bold diagonal stripes make any UV drift / glass refraction jitter
/// immediately obvious during the CupertinoSheet open/close animation.
class _SheetBackground extends StatelessWidget {
  const _SheetBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A).withValues(alpha: 0.9),
              const Color(0xFF7C3AED).withValues(alpha: 0.9),
              const Color(0xFFDB2777).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 18.0;

    // Bold diagonal stripes — any UV freeze jitter makes these swim visibly.
    const spacing = 48.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
