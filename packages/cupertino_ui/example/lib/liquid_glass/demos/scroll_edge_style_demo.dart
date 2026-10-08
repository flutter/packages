// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT

/// Scroll Edge Effect Showcase — `GlassScrollEdgeStyle` Interactive Playground.
///
/// Demonstrates [GlassScrollEdgeStyle.soft], [GlassScrollEdgeStyle.hard], and
/// [GlassScrollEdgeStyle.blur] on a live [GlassScaffold] with a floating
/// [GlassAppBar] and [GlassTabBar.bottom].
///
/// Follows Apple HIG & iOS 26 best practices:
///   • Glass materials are reserved for the chrome (AppBar & TabBar)
///   • Scroll content uses solid, high-contrast cards so edge transitions
///     (dissolving vs frosting) are starkly visible
///   • Live controls to tune top & bottom fade extents, maxSigma, and edge toggles
///
/// Run standalone:
///   flutter run -t example/lib/demos/scroll_edge_style_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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
      title: 'Scroll Edge Effect Playground',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: ScrollEdgeStyleDemo(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo Page
// ─────────────────────────────────────────────────────────────────────────────

class ScrollEdgeStyleDemo extends StatefulWidget {
  const ScrollEdgeStyleDemo({super.key});

  @override
  State<ScrollEdgeStyleDemo> createState() => _ScrollEdgeStyleDemoState();
}

class _ScrollEdgeStyleDemoState extends State<ScrollEdgeStyleDemo> {
  // ── Tuning Parameters ──────────────────────────────────────────────────────
  int _styleIndex = 0; // 0=soft (default), 1=hard, 2=blur
  double _topExtent = 20.0;
  double _bottomExtent = 20.0;
  double _maxSigma = 18.0;
  bool _fadeTop = true;
  bool _fadeBottom = true;

  // ── Tab Bar State ──────────────────────────────────────────────────────────
  int _selectedTabIndex = 0;

  static const _styles = [
    GlassScrollEdgeStyle.soft,
    GlassScrollEdgeStyle.hard,
    GlassScrollEdgeStyle.blur,
  ];

  static const _segments = [
    GlassSegment(label: 'Soft (Default)'),
    GlassSegment(label: 'Hard'),
    GlassSegment(label: 'Blur (GPU)'),
  ];

  GlassScrollEdgeStyle get _style => _styles[_styleIndex];

  // High-contrast, dense content items to demonstrate edge dissolving/blurring
  static const _items = [
    (
      '🎵',
      'Now Playing: Liquid Frequency',
      'Notice how this solid card dissolves as it enters the top app bar area. Compare Soft vs Hard vs Blur.',
      Color(0xFF0A84FF),
    ),
    (
      '📱',
      'iOS 26 System Parity (.soft)',
      'Soft is the iOS 26 default: a smooth, diffused gradient fade that seamlessly blends content into the navigation chrome.',
      Color(0xFF30D158),
    ),
    (
      '📐',
      'Structural Cutoff (.hard)',
      'Hard uses a 50% tighter transition zone with a steep curve. Ideal for dense settings lists and utility screens.',
      Color(0xFFFF9F0A),
    ),
    (
      '⚡',
      'GPU Progressive Frost (.blur)',
      'Blur applies an ImageFilter.shader progressive Gaussian frost. Live content remains visible while high frequencies melt away.',
      Color(0xFFFF375F),
    ),
    (
      '🎛️',
      'Configurable Fade Extents',
      'Use the Top and Bottom Extent sliders above to control how far into the content the fade zone extends.',
      Color(0xFFA855F7),
    ),
    (
      '🛡️',
      'Zero Glass in Scroll List',
      'Following Apple HIG: Glass is reserved for floating chrome (AppBar & TabBar). Content rows remain crisp and solid.',
      Color(0xFF5AC8FA),
    ),
    (
      '🔄',
      'Simultaneous Top & Bottom Fading',
      'Content dissolves behind both the top GlassAppBar and bottom GlassTabBar simultaneously as you scroll.',
      Color(0xFF34C759),
    ),
    (
      '🎨',
      'Dynamic Island & Safe Area Aware',
      'GlassScaffold automatically calculates topPad (status bar + app bar) and botPad (home indicator + tab bar) extents.',
      Color(0xFFFFD60A),
    ),
    (
      '🚀',
      '120 FPS ProMotion Ready',
      'Zero per-frame allocations during scrolling. Overlays are non-interactive via IgnorePointer.',
      Color(0xFFFF453A),
    ),
    (
      '💎',
      'Liquid Glass Tab Bar',
      'The floating bottom bar below responds dynamically as content slides beneath its refractive material.',
      Color(0xFF64D2FF),
    ),
    (
      '🧪',
      'Interactive Playground',
      'Try switching between Soft, Hard, and Blur while actively dragging this scroll list to observe the visual difference.',
      Color(0xFFBF5AF2),
    ),
    (
      '🏁',
      'End of Stream',
      'Scroll all the way down to observe the bottom edge fade cleanly above the floating GlassTabBar.',
      Color(0xFF30D158),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF090A10),
              Color(0xFF140F24),
              Color(0xFF0A1424),
            ],
          ),
        ),
      ),
      statusBarStyle: GlassStatusBarStyle.light,
      edgeStyle: _style,
      maxSigma: _maxSigma,
      topEdgeFade: _fadeTop,
      bottomEdgeFade: _fadeBottom,
      topEdgeFadeExtent: _topExtent,
      bottomEdgeFadeExtent: _bottomExtent,
      appBar: GlassAppBar(
        title: const Text(
          'Scroll Edge Effect',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomBar: GlassTabBar.bottom(
        selectedIndex: _selectedTabIndex,
        onTabSelected: (i) => setState(() => _selectedTabIndex = i),
        tabs: const [
          GlassTab(
            label: 'Edge Lab',
            icon: Icon(CupertinoIcons.slider_horizontal_3),
            activeIcon: Icon(CupertinoIcons.slider_horizontal_3),
          ),
          GlassTab(
            label: 'Library',
            icon: Icon(CupertinoIcons.square_stack_3d_up),
            activeIcon: Icon(CupertinoIcons.square_stack_3d_up_fill),
          ),
          GlassTab(
            label: 'Favorites',
            icon: Icon(CupertinoIcons.heart),
            activeIcon: Icon(CupertinoIcons.heart_fill),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Controls Panel (Padded cleanly below GlassAppBar) ───────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 44 + 8, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161726),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2E3048),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Style description header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0096C7)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF0096C7)
                                    .withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _styleBadgeText(_style),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5AC8FA),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _styleCaption(_style),
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 1. Edge Style Selector
                      _SectionHeader('Edge Style'),
                      const SizedBox(height: 8),
                      GlassSegmentedControl(
                        segments: _segments,
                        selectedIndex: _styleIndex,
                        onSegmentSelected: (i) =>
                            setState(() => _styleIndex = i),
                      ),

                      const SizedBox(height: 18),

                      // 2. Extent Controls
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(
                                    'Top Extent (${_topExtent.round()} px)'),
                                const SizedBox(height: 4),
                                GlassSlider(
                                  value: _topExtent,
                                  min: -40,
                                  max: 60,
                                  onChanged: (v) =>
                                      setState(() => _topExtent = v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(
                                    'Bottom Extent (${_bottomExtent.round()} px)'),
                                const SizedBox(height: 4),
                                GlassSlider(
                                  value: _bottomExtent,
                                  min: -40,
                                  max: 60,
                                  onChanged: (v) =>
                                      setState(() => _bottomExtent = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 3. maxSigma slider (Blur only)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: _style == GlassScrollEdgeStyle.blur
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _SectionHeader(
                                      'maxSigma (${_maxSigma.round()} px)'),
                                  const SizedBox(height: 4),
                                  GlassSlider(
                                    value: _maxSigma,
                                    min: 0,
                                    max: 30,
                                    onChanged: (v) =>
                                        setState(() => _maxSigma = v),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Controls blur intensity at the apex of the transition zone.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: CupertinoColors.secondaryLabel
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 16),

                      // 4. Edge Toggles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Top Fade',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlassSwitch(
                                value: _fadeTop,
                                onChanged: (v) => setState(() => _fadeTop = v),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Bottom Fade',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlassSwitch(
                                value: _fadeBottom,
                                onChanged: (v) =>
                                    setState(() => _fadeBottom = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scroll Content Section Header ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  _SectionHeader('Live Scroll Stream'),
                  const Spacer(),
                  Text(
                    'Scroll under bars to test',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Solid Content Cards (No GlassCard anti-pattern) ─────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SolidContentCard(
                    emoji: item.$1,
                    title: item.$2,
                    body: item.$3,
                    accentColor: item.$4,
                  ),
                );
              },
              childCount: _items.length,
            ),
          ),

          // Bottom padding to clear bottom tab bar & allow clean scroll-through
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
    );
  }

  String _styleBadgeText(GlassScrollEdgeStyle style) => switch (style) {
        GlassScrollEdgeStyle.soft => 'Soft · iOS 26 Default',
        GlassScrollEdgeStyle.hard => 'Hard · Crisp Cutoff',
        GlassScrollEdgeStyle.blur => 'Blur · GPU Progressive Frost',
      };

  String _styleCaption(GlassScrollEdgeStyle style) => switch (style) {
        GlassScrollEdgeStyle.soft => 'Diffused fade (Zero GPU cost)',
        GlassScrollEdgeStyle.hard => '50% tighter transition band',
        GlassScrollEdgeStyle.blur => 'Live ImageFilter.shader pass',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }
}

/// Solid, crisp content card.
///
/// We intentionally do NOT use [GlassCard] inside the scroll list:
/// 1. Conforms to Apple HIG (reserve glass for navigation chrome).
/// 2. Solid, high-contrast borders and fills make edge fades/blurs starkly obvious.
class _SolidContentCard extends StatelessWidget {
  const _SolidContentCard({
    required this.emoji,
    required this.title,
    required this.body,
    required this.accentColor,
  });

  final String emoji;
  final String title;
  final String body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181928),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2B2D42),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
