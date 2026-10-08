// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT

/// Tab Bar Menus Showcase (Issue #275).
///
/// Demonstrates native iOS 26 Liquid Glass pull-down menus anchored inside tab bars:
///   1. [GlassTabBarExtraButton.menu] on [GlassTabBar.bottom] (left & right placement).
///   2. [GlassTabBarTrailingButton.menu] on [GlassTabBar.minimizable] (springs from trailing pill).
///   3. [GlassTabBarExtraButton.menu] on [GlassTabBar.searchable] (alongside search pill).
///
/// Run standalone:
///   flutter run -t example/lib/demos/tab_bar_menu_demo.dart
library;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const TabBarMenuDemoApp()));
}

class TabBarMenuDemoApp extends StatelessWidget {
  const TabBarMenuDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Tab Bar Menus Demo',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const TabBarMenuDemoPage(),
    );
  }
}

enum _TabBarVariant {
  bottom('Bottom Bar'),
  minimizable('Minimizable'),
  searchable('Searchable');

  const _TabBarVariant(this.label);
  final String label;
}

class TabBarMenuDemoPage extends StatefulWidget {
  const TabBarMenuDemoPage({super.key});

  @override
  State<TabBarMenuDemoPage> createState() => _TabBarMenuDemoPageState();
}

class _TabBarMenuDemoPageState extends State<TabBarMenuDemoPage> {
  _TabBarVariant _variant = _TabBarVariant.bottom;
  int _selectedTab = 0;
  bool _menuEnabled = true;
  bool _isSearchActive = false;
  String _searchQuery = '';
  GlassExtraButtonPlacement _placement = GlassExtraButtonPlacement.right;
  double _menuWidth = 220;
  String? _lastAction;
  Timer? _actionTimer;
  bool _controlsExpanded = true;

  late final GlassTabBarMinimizeController _minimizeController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _minimizeController = GlassTabBarMinimizeController(
      behavior: GlassBarMinimizeBehavior.onScrollDown,
    );
  }

  @override
  void dispose() {
    _actionTimer?.cancel();
    _minimizeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onAction(String action) {
    _actionTimer?.cancel();
    setState(() => _lastAction = action);
    _actionTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _lastAction = null);
    });
  }

  List<Widget> _buildMenuItems() {
    return [
      const GlassMenuLabel(title: 'Quick Actions'),
      GlassMenuItem(
        icon: const Icon(CupertinoIcons.square_pencil),
        title: 'New Note',
        onTap: () => _onAction('New Note'),
      ),
      GlassMenuItem(
        icon: const Icon(CupertinoIcons.folder_badge_plus),
        title: 'New Folder',
        onTap: () => _onAction('New Folder'),
      ),
      GlassMenuItem(
        icon: const Icon(CupertinoIcons.share),
        title: 'Share Feed',
        onTap: () => _onAction('Share Feed'),
      ),
      const GlassMenuDivider(),
      GlassMenuItem(
        icon: const Icon(CupertinoIcons.slider_horizontal_3),
        title: 'Preferences',
        onTap: () => _onAction('Preferences'),
      ),
      GlassMenuItem(
        icon: const Icon(CupertinoIcons.trash),
        title: 'Clear History',
        isDestructive: true,
        onTap: () => _onAction('Clear History'),
      ),
    ];
  }

  Widget _buildControlPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CupertinoColors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.16),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.3),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with collapsible toggle
              GestureDetector(
                onTap: () =>
                    setState(() => _controlsExpanded = !_controlsExpanded),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: CupertinoColors.activeBlue
                                .withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            CupertinoIcons.slider_horizontal_3,
                            size: 15,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'TAB BAR VARIANT',
                          style: TextStyle(
                            color:
                                CupertinoColors.white.withValues(alpha: 0.70),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _controlsExpanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 14,
                      color: CupertinoColors.white.withValues(alpha: 0.70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bar Variant Selector
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<_TabBarVariant>(
                  groupValue: _variant,
                  children: {
                    for (final v in _TabBarVariant.values)
                      v: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          v.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  },
                  onValueChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _variant = v;
                        _isSearchActive = false;
                        _searchQuery = '';
                        _minimizeController.expand();
                      });
                    }
                  },
                ),
              ),

              if (_controlsExpanded) ...[
                const SizedBox(height: 16),
                Container(
                  height: 0.5,
                  color: CupertinoColors.white.withValues(alpha: 0.10),
                ),
                const SizedBox(height: 14),

                // Menu Enabled Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menu Enabled',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CupertinoSwitch(
                      value: _menuEnabled,
                      activeTrackColor: CupertinoColors.activeBlue,
                      onChanged: (val) => setState(() => _menuEnabled = val),
                    ),
                  ],
                ),

                if (_variant == _TabBarVariant.bottom) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Button Placement',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CupertinoSlidingSegmentedControl<
                          GlassExtraButtonPlacement>(
                        groupValue: _placement,
                        children: const {
                          GlassExtraButtonPlacement.left: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Text('Left', style: TextStyle(fontSize: 12)),
                          ),
                          GlassExtraButtonPlacement.right: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child:
                                Text('Right', style: TextStyle(fontSize: 12)),
                          ),
                        },
                        onValueChanged: (p) {
                          if (p != null) setState(() => _placement = p);
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menu Width',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CupertinoSlidingSegmentedControl<double>(
                      groupValue: _menuWidth,
                      children: {
                        180.0: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('180', style: TextStyle(fontSize: 12)),
                        ),
                        220.0: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('220', style: TextStyle(fontSize: 12)),
                        ),
                        260.0: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('260', style: TextStyle(fontSize: 12)),
                        ),
                      },
                      onValueChanged: (w) {
                        if (w != null) setState(() => _menuWidth = w);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_DemoFeedItem> _getAllFeedItems() {
    return const [
      _DemoFeedItem(
        category: 'SPATIAL REFRACTION',
        title: 'Impeller Liquid Shaders',
        subtitle: 'Real-time backdrop refraction with chromatic aberration.',
        icon: CupertinoIcons.sparkles,
        gradient: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        tag: 'Metal 3D',
      ),
      _DemoFeedItem(
        category: 'METABALL MORPHING',
        title: 'Dual-Blob Teardrop Physics',
        subtitle: 'Button morphs smoothly into the pull-down menu shape.',
        icon: CupertinoIcons.arrow_2_circlepath_circle,
        gradient: [Color(0xFFF857A6), Color(0xFFFF5858)],
        tag: 'Spring J-Curve',
      ),
      _DemoFeedItem(
        category: 'MINIMIZABLE BAR',
        title: 'Scroll-Driven Compact Pill',
        subtitle: 'Bar shrinks to a compact trailing pill on scroll down.',
        icon: CupertinoIcons.arrow_down_right_arrow_up_left,
        gradient: [Color(0xFF00C6FF), Color(0xFF0072FF)],
        tag: 'Interactive',
      ),
      _DemoFeedItem(
        category: 'SEARCH INTEGRATION',
        title: 'Elastic Search Pill',
        subtitle: 'Extra action button stays pinned alongside the search bar.',
        icon: CupertinoIcons.search,
        gradient: [Color(0xFFFF9900), Color(0xFFFF5E62)],
        tag: 'Auto-Collapse',
      ),
      _DemoFeedItem(
        category: 'ADAPTIVE BRIGHTNESS',
        title: 'Dynamic Lighting & Glow',
        subtitle: 'Subtle specular glow illuminates borders on tap & drag.',
        icon: CupertinoIcons.lightbulb_fill,
        gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)],
        tag: 'Color Fidelity',
      ),
      _DemoFeedItem(
        category: 'GESTURE ARENA',
        title: 'Haptic Friction & Snap',
        subtitle: 'Spring physics dynamically adjust to swipe velocity.',
        icon: CupertinoIcons.hand_draw_fill,
        gradient: [Color(0xFFFA709A), Color(0xFFFEE140)],
        tag: '60/120 Hz',
      ),
      _DemoFeedItem(
        category: 'PERFORMANCE',
        title: 'Zero-Overhead Compositing',
        subtitle: 'Stationary surfaces skip full GPU raster passes.',
        icon: CupertinoIcons.gauge,
        gradient: [Color(0xFF30CFD0), Color(0xFF330867)],
        tag: 'Optimized',
      ),
    ];
  }

  Widget _buildContent() {
    final allItems = _getAllFeedItems();
    final items = _searchQuery.isEmpty
        ? allItems
        : allItems.where((it) {
            final q = _searchQuery.toLowerCase();
            return it.title.toLowerCase().contains(q) ||
                it.subtitle.toLowerCase().contains(q) ||
                it.category.toLowerCase().contains(q);
          }).toList();

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        0,
        MediaQuery.paddingOf(context).top + 58,
        0,
        140,
      ),
      children: [
        // Hero Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.activeBlue.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      size: 12,
                      color: CupertinoColors.activeBlue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'iOS 26 LIQUID GLASS',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tab Bar Menus',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _variant == _TabBarVariant.minimizable
                    ? 'Scroll down to test the pull-down menu while minimized into the trailing pill.'
                    : _variant == _TabBarVariant.searchable
                        ? 'Tap search to expand the input, or tap the ellipsis menu button.'
                        : 'Tap the ellipsis button on the bar to morph into the liquid menu.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: CupertinoColors.white.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Controls
        _buildControlPanel(),
        const SizedBox(height: 20),

        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedTab == 0
                    ? 'EXPLORE FEED'
                    : _selectedTab == 1
                        ? 'SAVED LIBRARY'
                        : 'PROFILE ITEMS',
                style: TextStyle(
                  color: CupertinoColors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${items.length} items',
                style: TextStyle(
                  color: CupertinoColors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Rich Content Feed Cards
        for (var i = 0; i < items.length; i++)
          _FeedCardWidget(
            item: items[i],
            index: i + 1,
            onTap: () => _onAction(items[i].title),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    final menuItems = _buildMenuItems();

    switch (_variant) {
      case _TabBarVariant.bottom:
        return GlassTabBar.bottom(
          selectedIndex: _selectedTab,
          onTabSelected: (i) => setState(() => _selectedTab = i),
          extraButton: GlassTabBarExtraButton.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'More Actions',
            enabled: _menuEnabled,
            placement: _placement,
            menuWidth: _menuWidth,
            menuItems: menuItems,
          ),
          tabs: const [
            GlassTab(
              label: 'Explore',
              icon: Icon(CupertinoIcons.compass),
              activeIcon: Icon(CupertinoIcons.compass_fill),
            ),
            GlassTab(
              label: 'Library',
              icon: Icon(CupertinoIcons.book),
              activeIcon: Icon(CupertinoIcons.book_fill),
            ),
            GlassTab(
              label: 'Account',
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
            ),
          ],
        );

      case _TabBarVariant.minimizable:
        return GlassTabBar.minimizable(
          selectedIndex: _selectedTab,
          onTabSelected: (i) => setState(() => _selectedTab = i),
          minimizeController: _minimizeController,
          scrollController: _scrollController,
          trailingButton: GlassTabBarTrailingButton.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'Trailing Actions',
            enabled: _menuEnabled,
            menuWidth: _menuWidth,
            menuItems: menuItems,
          ),
          tabs: const [
            GlassTab(
              label: 'Explore',
              icon: Icon(CupertinoIcons.compass),
              activeIcon: Icon(CupertinoIcons.compass_fill),
            ),
            GlassTab(
              label: 'Library',
              icon: Icon(CupertinoIcons.book),
              activeIcon: Icon(CupertinoIcons.book_fill),
            ),
            GlassTab(
              label: 'Profile',
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
            ),
          ],
        );

      case _TabBarVariant.searchable:
        return GlassTabBar.searchable(
          selectedIndex: _selectedTab,
          onTabSelected: (i) => setState(() => _selectedTab = i),
          isSearchActive: _isSearchActive,
          searchConfig: GlassSearchBarConfig(
            onSearchToggle: (active) =>
                setState(() => _isSearchActive = active),
            onChanged: (q) => setState(() => _searchQuery = q),
            hintText: 'Search feed...',
          ),
          extraButton: GlassTabBarExtraButton.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'Search Actions',
            enabled: _menuEnabled,
            menuWidth: _menuWidth,
            menuItems: menuItems,
          ),
          tabs: const [
            GlassTab(
              label: 'Explore',
              icon: Icon(CupertinoIcons.compass),
              activeIcon: Icon(CupertinoIcons.compass_fill),
            ),
            GlassTab(
              label: 'Library',
              icon: Icon(CupertinoIcons.book),
              activeIcon: Icon(CupertinoIcons.book_fill),
            ),
          ],
        );
    }
  }

  Widget _buildActionToast() {
    final action = _lastAction;
    final isShowing = action != null;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      top: isShowing ? MediaQuery.paddingOf(context).top + 56 : -80,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isShowing ? 1.0 : 0.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: CupertinoColors.activeBlue.withValues(alpha: 0.45),
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_alt,
                      color: CupertinoColors.activeBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ACTION EXECUTED',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          action ?? '',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background wallpaper - full edge to edge from (0,0)
          Image.asset(
            'assets/wallpaper.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B1B2F), Color(0xFF162447)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Content List
          _buildContent(),

          // Frosted Glass Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: CupertinoColors.black.withValues(alpha: 0.22),
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 4,
                    left: 6,
                    right: 16,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(
                          CupertinoIcons.chevron_back,
                          color: CupertinoColors.white,
                          size: 24,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Tab Bar Menus',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Action Toast
          _buildActionToast(),

          // Pinned Tab Bar at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTabBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoFeedItem {
  final String category;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String tag;

  const _DemoFeedItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.tag,
  });
}

class _FeedCardWidget extends StatelessWidget {
  final _DemoFeedItem item;
  final int index;
  final VoidCallback onTap;

  const _FeedCardWidget({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient Icon Squircle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: item.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: item.gradient.first.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.category,
                              style: TextStyle(
                                color: item.gradient.first,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.tag,
                                style: TextStyle(
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.65),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color:
                                CupertinoColors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ],
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
