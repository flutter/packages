import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/cupertino.dart';

class SurfacesPage extends StatelessWidget {
  const SurfacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      child: GlassScaffold(
        appBar: const GlassAppBar.pinned(),
        body: GlassScrollEdgeEffect(
          topFadeHeight: MediaQuery.paddingOf(context).top + 44 + 40,
          fadeBottom: false,
          child: CustomScrollView(
            slivers: [
              // Space for the app bar + safe area
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).top + 44,
                ),
              ),
              // ── Large page title (iOS 26 inline style) ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Surfaces',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── GlassAppBar ──────────────────────────────────
                      const _SectionTitle(title: 'GlassAppBar'),
                      SizedBox(height: 8),
                      Text(
                        'The navigation bar at the top of this page is a live GlassAppBar with leading and title support.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.7),
                        ),
                      ),

                      SizedBox(height: 40),

                      // ── GlassBottomBar ───────────────────────────────
                      const _SectionTitle(title: 'GlassBottomBar'),
                      SizedBox(height: 8),
                      Text(
                        'Draggable jelly-physics tab bar with velocity snapping and per-tab glow colors.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 16),
                      _DemoLauncher(
                        title: 'Launch Bottom Bar Demo',
                        subtitle: 'Full-screen interactive experience',
                        icon: CupertinoIcons.rectangle_dock,
                        glowColor: CupertinoColors.activeBlue,
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const _BottomBarDemoPage(),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // ── GlassSearchableBottomBar ─────────────────────
                      const _SectionTitle(title: 'GlassSearchableBottomBar'),
                      SizedBox(height: 8),
                      Text(
                        'Bottom bar with integrated search — tabs spring-collapse into pills when search activates.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 16),
                      _DemoLauncher(
                        title: 'Launch Searchable Bar Demo',
                        subtitle: 'Full-screen with search interaction',
                        icon: CupertinoIcons.search,
                        glowColor: CupertinoColors.systemPurple,
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const _SearchableBarDemoPage(),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // ── GlassSegmentedControl / GlassTabBar (Inline) ────────
                      const _SectionTitle(
                          title:
                              'GlassTabBar (Inline) / GlassSegmentedControl'),
                      SizedBox(height: 16),
                      const _TabBarDemo(),

                      SizedBox(height: 24),

                      Text(
                        'Labels Only',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: 8),
                      const _TabBarLabelExample(),
                      SizedBox(height: 24),

                      Text(
                        'Icons Only',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: 8),
                      const _TabBarIconExample(),
                      SizedBox(height: 24),

                      Text(
                        'Scrollable (Many Tabs)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: 8),
                      const _TabBarScrollableExample(),

                      SizedBox(height: 40),

                      // ── GlassToolbar ─────────────────────────────────
                      const _SectionTitle(title: 'GlassToolbar'),
                      SizedBox(height: 16),
                      GlassToolbar(
                        height: 60,
                        children: [
                          GlassButton(
                            icon: Icon(CupertinoIcons.share),
                            onTap: () {},
                            label: 'Share',
                            width: 44,
                            height: 44,
                          ),
                          const Spacer(),
                          GlassButton(
                            icon: Icon(CupertinoIcons.add),
                            onTap: () {},
                            label: 'Add',
                            width: 44,
                            height: 44,
                          ),
                          const Spacer(),
                          GlassButton(
                            icon: Icon(CupertinoIcons.trash),
                            onTap: () {},
                            label: 'Delete',
                            width: 44,
                            height: 44,
                          ),
                        ],
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Full-Screen Demo Pages
// =============================================================================

/// Polished full-screen GlassBottomBar demo.
class _BottomBarDemoPage extends StatefulWidget {
  const _BottomBarDemoPage();

  @override
  State<_BottomBarDemoPage> createState() => _BottomBarDemoPageState();
}

class _BottomBarDemoPageState extends State<_BottomBarDemoPage> {
  int _selectedIndex = 0;

  static const _tabs = <GlassTab>[
    GlassTab(
      label: 'Home',
      icon: Icon(CupertinoIcons.house),
      activeIcon: Icon(CupertinoIcons.house_fill),
    ),
    GlassTab(
      label: 'Browse',
      icon: Icon(CupertinoIcons.compass),
      activeIcon: Icon(CupertinoIcons.compass_fill),
    ),
    GlassTab(
      label: 'Favorites',
      icon: Icon(CupertinoIcons.heart),
      activeIcon: Icon(CupertinoIcons.heart_fill),
    ),
    GlassTab(
      label: 'Profile',
      icon: Icon(CupertinoIcons.person),
      activeIcon: Icon(CupertinoIcons.person_fill),
    ),
  ];

  static const _tabTitles = ['Home', 'Browse', 'Favorites', 'Profile'];
  static const _tabColors = [
    Color(0xFF007AFF),
    Color(0xFF30D158),
    Color(0xFFFF2D55),
    Color(0xFFAF52DE),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: _buildDemoBackground(context),
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      child: GlassScaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GlassButton(
                            icon: Icon(CupertinoIcons.back),
                            onTap: () => Navigator.of(context).pop(),
                            width: 40,
                            height: 40,
                            iconSize: 20,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _tabTitles[_selectedIndex],
                              style: TextStyle(
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ContentRow(
                      index: index,
                      color: _tabColors[_selectedIndex],
                    ),
                    childCount: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _selectedIndex,
          onTabSelected: (i) => setState(() => _selectedIndex = i),
          quality: GlassQuality.premium,
          selectedIconColor: _tabColors[_selectedIndex],
          tabs: _tabs,
        ),
      ),
    );
  }
}

/// Polished full-screen GlassSearchableBottomBar demo.
class _SearchableBarDemoPage extends StatefulWidget {
  const _SearchableBarDemoPage();

  @override
  State<_SearchableBarDemoPage> createState() => _SearchableBarDemoPageState();
}

class _SearchableBarDemoPageState extends State<_SearchableBarDemoPage> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();
  bool _isMiniMode = false;

  static const _tabs = <GlassTab>[
    GlassTab(
      label: 'Home',
      icon: Icon(CupertinoIcons.house),
      activeIcon: Icon(CupertinoIcons.house_fill),
    ),
    GlassTab(
      label: 'Browse',
      icon: Icon(CupertinoIcons.compass),
      activeIcon: Icon(CupertinoIcons.compass_fill),
    ),
    GlassTab(
      label: 'Profile',
      icon: Icon(CupertinoIcons.person),
      activeIcon: Icon(CupertinoIcons.person_fill),
    ),
  ];

  static const _tabTitles = ['Home', 'Browse', 'Profile'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final mini = _scrollController.hasClients && _scrollController.offset > 50;
    if (mini != _isMiniMode) setState(() => _isMiniMode = mini);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: _buildDemoBackground(context),
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      child: GlassScaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: _isSearching
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.search,
                              color: CupertinoColors.label
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.3),
                              size: 64),
                          SizedBox(height: 16),
                          Text(
                            'Search',
                            style: TextStyle(
                              color: CupertinoColors.label.resolveFrom(context),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Type to search for anything.',
                            style: TextStyle(
                              color: CupertinoColors.label
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.45),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: Row(
                              children: [
                                GlassButton(
                                  icon: Icon(CupertinoIcons.back),
                                  onTap: () => Navigator.of(context).pop(),
                                  width: 40,
                                  height: 40,
                                  iconSize: 20,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _tabTitles[_selectedIndex],
                                    style: TextStyle(
                                      color: CupertinoColors.label
                                          .resolveFrom(context),
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 140),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _ContentRow(
                                index: index,
                                color: const Color(0xFFAF52DE),
                              ),
                              childCount: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassTabBar.searchable(
                selectedIndex: _selectedIndex,
                isSearchActive: _isMiniMode || _isSearching,
                onTabSelected: (i) {
                  if (i == _selectedIndex && _isMiniMode) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuart,
                      );
                    }
                    setState(() {
                      _isMiniMode = false;
                      _isSearching = false;
                    });
                  } else {
                    setState(() {
                      _selectedIndex = i;
                      _isSearching = false;
                    });
                  }
                },
                quality: GlassQuality.premium,
                searchConfig: GlassSearchBarConfig(
                  hintText: 'Search...',
                  showsCancelButton: true,
                  expandWhenActive: !_isMiniMode || _isSearching,
                  onSearchToggle: (active) {
                    if (active) {
                      setState(() => _isSearching = true);
                    } else {
                      setState(() => _isSearching = false);
                      if (_isMiniMode) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutQuart,
                          );
                        }
                        setState(() => _isMiniMode = false);
                      }
                    }
                  },
                ),
                tabs: _tabs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Shared demo content
// =============================================================================

Widget _buildDemoBackground(BuildContext context) {
  final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
                Color(0xFF533483),
              ]
            : const [
                Color(0xFFF0F4FF),
                Color(0xFFE6F0FF),
                Color(0xFFD9E6FF),
                Color(0xFFC0D6FF),
              ],
      ),
    ),
  );
}

/// Simulated content row for demo pages.
class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.index, required this.color});
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      height: 64,
      decoration: BoxDecoration(
        color:
            CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Scroll to see the bar behavior',
                  style: TextStyle(
                    color: CupertinoColors.label
                        .resolveFrom(context)
                        .withValues(alpha: 0.5),
                    fontSize: 13,
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

// =============================================================================
// Demo Launcher Tile
// =============================================================================

class _DemoLauncher extends StatelessWidget {
  const _DemoLauncher({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: glowColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: glowColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.label
                          .resolveFrom(context)
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.label
                  .resolveFrom(context)
                  .withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Tab Bar Demo Widgets
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label.resolveFrom(context),
      ),
    );
  }
}

class _TabBarDemo extends StatefulWidget {
  const _TabBarDemo();

  @override
  State<_TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<_TabBarDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassSegmentedControl(
          segments: [
            GlassSegment(label: 'Photos'),
            GlassSegment(label: 'Albums'),
            GlassSegment(label: 'Shared'),
          ],
          selectedIndex: _selectedIndex,
          onSegmentSelected: (index) => setState(() => _selectedIndex = index),
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CupertinoColors.label
                .resolveFrom(context)
                .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedIndex == 0
                    ? CupertinoIcons.photo
                    : _selectedIndex == 1
                        ? CupertinoIcons.folder
                        : CupertinoIcons.person_2,
                size: 32,
                color: CupertinoColors.label
                    .resolveFrom(context)
                    .withValues(alpha: 0.8),
              ),
              SizedBox(height: 8),
              Text(
                _selectedIndex == 0
                    ? 'Photos View'
                    : _selectedIndex == 1
                        ? 'Albums View'
                        : 'Shared View',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabBarLabelExample extends StatefulWidget {
  const _TabBarLabelExample();

  @override
  State<_TabBarLabelExample> createState() => _TabBarLabelExampleState();
}

class _TabBarLabelExampleState extends State<_TabBarLabelExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl(
      segments: [
        GlassSegment(label: 'Timeline'),
        GlassSegment(label: 'Mentions'),
        GlassSegment(label: 'Messages'),
      ],
      selectedIndex: _selectedIndex,
      onSegmentSelected: (index) => setState(() => _selectedIndex = index),
    );
  }
}

class _TabBarIconExample extends StatefulWidget {
  const _TabBarIconExample();

  @override
  State<_TabBarIconExample> createState() => _TabBarIconExampleState();
}

class _TabBarIconExampleState extends State<_TabBarIconExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl(
      segments: [
        GlassSegment(icon: Icon(CupertinoIcons.home)),
        GlassSegment(icon: Icon(CupertinoIcons.search)),
        GlassSegment(icon: Icon(CupertinoIcons.bell)),
        GlassSegment(icon: Icon(CupertinoIcons.settings)),
      ],
      selectedIndex: _selectedIndex,
      onSegmentSelected: (index) => setState(() => _selectedIndex = index),
    );
  }
}

class _TabBarScrollableExample extends StatefulWidget {
  const _TabBarScrollableExample();

  @override
  State<_TabBarScrollableExample> createState() =>
      _TabBarScrollableExampleState();
}

class _TabBarScrollableExampleState extends State<_TabBarScrollableExample> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl.scrollable(
      segments: List.generate(
        10,
        (i) => GlassSegment(label: 'Category ${i + 1}'),
      ),
      selectedIndex: _selectedIndex,
      onSegmentSelected: (index) => setState(() => _selectedIndex = index),
    );
  }
}
