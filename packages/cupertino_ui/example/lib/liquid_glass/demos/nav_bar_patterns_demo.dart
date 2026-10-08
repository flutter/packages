/// GlassAppBar Navigation Patterns Demo
///
/// Showcases all iOS 26 navigation bar patterns side-by-side:
///
///   1. Transparent + inline title (right of back button)
///   2. Transparent + large title below bar (collapsing on scroll)
///   3. Solid background color (WhatsApp-style)
///   4. Transparent fade-only (no title in bar)
///   5. Tab bar with bottom fade
///   6. Fade header (no app bar) — Apple Music / Podcasts style
///   7. Large title + Search Bar — two-phase iOS 26 collapse
///   8. Nested navigation — pinned actions morph in place across pushes
///   9. Bar item types — icon, pull-down menu and custom widget in one capsule
///  10. Leading items — a custom leading that replaces, supplements, or drops
///      the glass behind itself entirely
///  11. Custom bar pinning — a plain Material AppBar pinned via GlassPinnedBarChrome
///  12. Header actions morph — trailing capsule bounces and blurs between
///      clusters across pushes
///  13. Presented sheets — a dialog, action sheet, modal sheet or fullscreen
///      dialog covering the pinned chrome the way it covers the page (#259)
///  14. Tinted bar items — GlassBarItem.tintColor floods the capsule with a
///      design-token colour (iOS 26 prominent action pattern, issue #312)
///
/// Run standalone:
///   flutter run -t lib/demos/nav_bar_patterns_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../constants/glass_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    child: CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: GlassNavigationShell(child: child!),
      ),
      home: const NavBarPatternsDemo(),
    ),
  ));
}

// =============================================================================
// Demo Launcher
// =============================================================================

class NavBarPatternsDemo extends StatelessWidget {
  const NavBarPatternsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: const GlassAppBar.pinned(),
      body: CustomScrollView(
        slivers: [
          // Top spacer for app bar area
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).top + 44 + 8,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  'Navigation\nPatterns',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: CupertinoColors.label.resolveFrom(context),
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'All iOS 26 GlassAppBar modes — tap to preview.',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                SizedBox(height: 32),
                _PatternTile(
                  title: 'Inline Title',
                  subtitle: 'Title right of back button — standard compact bar',
                  icon: CupertinoIcons.textformat,
                  onTap: () => _push(context, const _InlineTitleDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Large Title → Collapse',
                  subtitle:
                      'Large title below bar, collapses to center on scroll',
                  icon: CupertinoIcons.text_alignleft,
                  onTap: () => _push(context, const _LargeTitleCollapseDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Solid Background',
                  subtitle: 'Opaque colour bar — WhatsApp conversation style',
                  icon: CupertinoIcons.paintbrush,
                  onTap: () => _push(context, const _SolidBackgroundDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Fade Only (No Bar Title)',
                  subtitle:
                      'Floating back button, content fades under status area',
                  icon: CupertinoIcons.arrow_up_circle,
                  onTap: () => _push(context, const _FadeOnlyDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Tab Bar + Bottom Fade',
                  subtitle:
                      'Bottom bar with dual edge fade — iOS Settings style',
                  icon: CupertinoIcons.square_grid_2x2,
                  onTap: () => _push(context, const _TabBarBottomFadeDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Fade Header (No App Bar)',
                  subtitle: 'Fixed title fades on scroll — Apple Music style',
                  icon: CupertinoIcons.music_note_2,
                  onTap: () => _push(context, const _FadeHeaderDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Large Title + Search Bar',
                  subtitle:
                      'Two-phase collapse: title then search — iOS 26 Messages/Mail style',
                  icon: CupertinoIcons.search,
                  onTap: () => _push(context, const _LargeTitleSearchDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Nested Navigation',
                  subtitle:
                      'Pinned back button and actions morph in place across pushes',
                  icon: CupertinoIcons.square_stack_3d_up,
                  onTap: () => _push(context, const _NestedNavDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Bar Item Types',
                  subtitle:
                      'Icon, pull-down menu and custom widget — and how a custom one resizes the capsule',
                  icon: CupertinoIcons.square_on_circle,
                  onTap: () => _push(context, const _BarItemTypesDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Header Actions Morph',
                  subtitle:
                      'Trailing capsule contracts, bounces and blurs across pushes — iOS 26 drill-down style',
                  icon: CupertinoIcons.wand_stars,
                  onTap: () => _push(context, const _HeaderMorphDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Leading Items',
                  subtitle:
                      'A custom leading that replaces the back button — or sits '
                      'beside it, or carries no glass at all',
                  icon: CupertinoIcons.person_crop_circle,
                  onTap: () => _push(context, const _LeadingItemsDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Custom Bar Pinning',
                  subtitle:
                      'A plain Material AppBar that still pins — GlassPinnedBarChrome',
                  icon: CupertinoIcons.rectangle_stack_badge_plus,
                  onTap: () => _push(context, const _CustomBarPinningDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Presented Sheets',
                  subtitle: 'A sheet, dialog or fullscreen dialog covering the '
                      'pinned chrome the way it covers the page',
                  icon: CupertinoIcons.rectangle_stack,
                  onTap: () => _push(context, const _PresentedSheetsDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Sheet From The Capsule',
                  subtitle: 'GlassBarItem.sheet — the capsule empties and '
                      'stretches into the sheet, hoisted or in-route',
                  icon: CupertinoIcons.arrow_up_left_square,
                  onTap: () => _push(context, const _SheetItemDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Title Centering',
                  subtitle:
                      'Verifies title is centred on full bar width with asymmetric leading/trailing (fix #198)',
                  icon: CupertinoIcons.text_aligncenter,
                  onTap: () => _push(context, const _TitleCenteringDemo()),
                ),
                SizedBox(height: 16),
                _PatternTile(
                  title: 'Tinted Bar Items',
                  subtitle:
                      'tintColor floods the whole capsule — iOS 26 prominent action (issue #312)',
                  icon: CupertinoIcons.circle_fill,
                  onTap: () => _push(context, const _TintedBarItemDemo()),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      // CupertinoPageRoute gives the native slide and interactive back-swipe
      // that the pinned nav-bar chrome scrubs against.
      CupertinoPageRoute<void>(builder: (_) => page),
    );
  }
}

// =============================================================================
// Pattern Tile
// =============================================================================

class _PatternTile extends StatelessWidget {
  const _PatternTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      width: double.infinity,
      height: 80,
      shape: const LiquidRoundedSuperellipse(borderRadius: 16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                size: 16),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Shared — dummy scrollable content
// =============================================================================

Widget _buildDummyContent({int count = 25, double topPadding = 0}) {
  // Content rows use plain styled Containers — glass belongs in navigation
  // chrome (bars, menus, sheets), not in scrollable content lists.
  final hues = [
    const Color(0xFF3D5AFE),
    const Color(0xFF00BFA5),
    const Color(0xFFFF6D00),
    const Color(0xFFD500F9),
    const Color(0xFFFFD600),
  ];
  return SliverList.separated(
    itemCount: count,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final hue = hues[index % hues.length];
      return Padding(
        padding: EdgeInsets.only(
          top: index == 0 ? topPadding : 0,
          left: 24,
          right: 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                hue.withValues(alpha: 0.55),
                hue.withValues(alpha: 0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scrollable content to test navigation bar behaviour',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// =============================================================================
// 1. Inline Title (title right of back button)
// =============================================================================

class _InlineTitleDemo extends StatelessWidget {
  const _InlineTitleDemo();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          'Inline Title',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: [
          GlassBarItem.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'More',
            menuItems: [
              GlassMenuItem(
                title: 'Share',
                icon: const Icon(CupertinoIcons.share),
                onTap: () {},
              ),
              GlassMenuItem(
                title: 'Duplicate',
                icon: const Icon(CupertinoIcons.doc_on_doc),
                onTap: () {},
              ),
              GlassMenuDivider(),
              GlassMenuItem(
                title: 'Delete',
                icon: const Icon(CupertinoIcons.delete),
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. Large Title → Collapse to Center
// =============================================================================

class _LargeTitleCollapseDemo extends StatefulWidget {
  const _LargeTitleCollapseDemo();

  @override
  State<_LargeTitleCollapseDemo> createState() =>
      _LargeTitleCollapseDemoState();
}

class _LargeTitleCollapseDemoState extends State<_LargeTitleCollapseDemo> {
  final _titleController = GlassLargeTitleController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        // Bar title fades in automatically as the large title scrolls away.
        title: Text(
          'Chats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        largeTitleController: _titleController,
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.camera),
            label: 'Camera',
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.plus),
            id: 'add',
            label: 'New chat',
            onTap: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _titleController.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44),
          ),
          // Large title fades out as user scrolls — zero boilerplate.
          GlassLargeTitle(
            text: 'Chats',
            controller: _titleController,
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. Solid Background Colour
// =============================================================================

class _SolidBackgroundDemo extends StatelessWidget {
  const _SolidBackgroundDemo();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      edgeFade: false,
      appBar: GlassAppBar.pinned(
        backgroundColor:
            isDark ? const Color(0xFF1F2C34) : const Color(0xFFE8EDF0),
        title: Text(
          'Solid Background',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        centerTitle: false,
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.videocam),
            label: 'Video call',
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.phone),
            label: 'Call',
            onTap: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// 4. Fade Only — No Title in Bar
// =============================================================================

class _FadeOnlyDemo extends StatelessWidget {
  const _FadeOnlyDemo();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: const GlassAppBar.pinned(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44),
          ),
          // Large title as part of content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Browse',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// 5. Tab Bar + Bottom Fade
// =============================================================================

class _TabBarBottomFadeDemo extends StatefulWidget {
  const _TabBarBottomFadeDemo();

  @override
  State<_TabBarBottomFadeDemo> createState() => _TabBarBottomFadeDemoState();
}

class _TabBarBottomFadeDemoState extends State<_TabBarBottomFadeDemo> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      bottomBar: GlassTabBar.bottom(
        selectedIndex: _selectedTab,
        onTabSelected: (index) => setState(() => _selectedTab = index),
        settings:
            RecommendedGlassSettings.standard.copyWith(thickness: 20, blur: 3),
        tabs: const [
          GlassTab(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.bell_fill),
            label: 'Alerts',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
      ),
      appBar: GlassAppBar.pinned(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// =============================================================================
// Pattern 6 — Fade Header (No App Bar)
//
// Fixed large title positioned below the status bar that fades out as the
// user scrolls. Uses GlassScaffold.header + headerScrollController.
// This is the pattern Apple Music and Podcasts use for their home screens.
// =============================================================================

class _FadeHeaderDemo extends StatefulWidget {
  const _FadeHeaderDemo();

  @override
  State<_FadeHeaderDemo> createState() => _FadeHeaderDemoState();
}

class _FadeHeaderDemoState extends State<_FadeHeaderDemo> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      topEdgeFade: true,
      bottomEdgeFade: true,

      // ── Fixed header — fades out on scroll ──────────────────────────────
      header: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Listen Now',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'SD',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      headerScrollController: _scrollController,
      headerFadeDistance: 30,

      // ── Bottom bar (no app bar in this pattern) ─────────────────────────
      bottomBar: GlassTabBar.bottom(
        selectedIndex: 0,
        onTabSelected: (_) {},
        settings:
            RecommendedGlassSettings.standard.copyWith(thickness: 20, blur: 3),
        tabs: const [
          GlassTab(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.antenna_radiowaves_left_right),
            label: 'Radio',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.music_albums),
            label: 'Library',
          ),
        ],
      ),

      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Extra top space for the fixed header overlay.
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 90),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// =============================================================================
// 7. Large Title + Search Bar — Two-Phase iOS 26 Collapse
// =============================================================================
//
// iOS 26 Messages / Mail pattern:
//   Phase 1 (0 → ~52pt): Large title fades out.
//   Phase 2 (~52pt → ~96pt): Search bar collapses under the nav bar.
//
// GlassLargeTitleController drives both phases from a single ScrollController.

class _LargeTitleSearchDemo extends StatefulWidget {
  const _LargeTitleSearchDemo();

  @override
  State<_LargeTitleSearchDemo> createState() => _LargeTitleSearchDemoState();
}

class _LargeTitleSearchDemoState extends State<_LargeTitleSearchDemo> {
  final _titleController = GlassLargeTitleController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        // Bar title fades in automatically in Phase 1.
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        largeTitleController: _titleController,
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.pencil),
            label: 'Compose',
            onTap: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _titleController.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44),
          ),
          // Phase 1: large title fades out.
          // Phase 2: search bar collapses under nav bar.
          // Both driven automatically by GlassLargeTitleController.
          GlassLargeTitle(
            text: 'Messages',
            controller: _titleController,
            searchBar: GlassSearchBar(
              placeholder: 'Search',
              useOwnLayer: true,
              onChanged: (_) {},
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// Title Centering Demo — visual verification for bug #198
// =============================================================================

/// Renders three GlassAppBar variants with a centre-guideline overlay.
///
/// A segmented control at the top toggles [centerTitle] across all three bars
/// simultaneously so the difference between centred and left-aligned is
/// immediately obvious.
// =============================================================================
// Bar Item Types — icon, menu and custom
// =============================================================================

/// An unread count, the kind of thing UIKit reaches for `customView:` to do.
///
/// Deliberately not glass: items inside the capsule sit on the shared shell,
/// and its width is whatever they measure to.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: CupertinoColors.systemRed.resolveFrom(context),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItemTypesDemo extends StatelessWidget {
  const _BarItemTypesDemo({this.detail = false});

  /// Second level, reached by a push — the same badge with a much wider count.
  final bool detail;

  List<GlassBarItem> get _actions => [
        GlassBarItem.custom(
          child: _UnreadBadge(detail ? 128 : 3),
          id: 'unread',
          label: 'Unread',
        ),
        if (!detail)
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.add),
            label: 'Add',
            onTap: () {},
          ),
        GlassBarItem.menu(
          icon: const Icon(CupertinoIcons.ellipsis),
          id: 'more',
          label: 'More',
          menuItems: [
            GlassMenuItem(
              title: detail ? 'Mark all read' : 'Sort by date',
              icon: Icon(
                detail
                    ? CupertinoIcons.checkmark_circle
                    : CupertinoIcons.sort_down,
              ),
              onTap: () {},
            ),
            GlassMenuItem(
              title: detail ? 'Mute' : 'Select…',
              icon: Icon(
                detail
                    ? CupertinoIcons.bell_slash
                    : CupertinoIcons.checkmark_square,
              ),
              onTap: () {},
            ),
            GlassMenuDivider(),
            GlassMenuItem(
              title: 'Delete',
              icon: const Icon(CupertinoIcons.delete),
              isDestructive: true,
              onTap: () {},
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          detail ? 'Detail' : 'Bar Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: _actions,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  detail
                      ? 'The badge held its position — same id on both screens — '
                          'while the capsule widened around it to fit 128, and '
                          'the add icon left. Nothing here is hardcoded: the '
                          'capsule measures the badge, exactly as UIKit measures '
                          'a customView. Swipe from the left edge to scrub it.'
                      : 'Three item kinds in one capsule: a custom widget (the '
                          'red unread badge), a plain icon, and a pull-down '
                          'menu. Tap the ellipsis to morph the whole capsule '
                          'into the menu — the iOS 26 GlassEffectContainer '
                          'behaviour, not a slot-sized popover.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
                if (!detail)
                  _PatternTile(
                    title: 'Open Detail',
                    subtitle: 'Badge grows 3 → 128, add icon leaves',
                    icon: CupertinoIcons.arrow_right_circle,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => const _BarItemTypesDemo(detail: true),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// Leading Items
// =============================================================================

/// Which leading configuration a [_LeadingItemsDemo] screen is showing.
enum _LeadingStage {
  /// Root: a bare avatar, no glass behind it — where iOS 26 puts a profile
  /// photo rather than a bar button.
  profile,

  /// Pushed: no leading of its own, so the automatic back button returns.
  issues,

  /// A custom leading, which replaces the back button.
  cancel,

  /// A custom leading alongside the back button.
  both,

  /// Two shared items, so the lone circular shell grows into a capsule.
  grouped,
}

/// The leading half of a pinned bar, in each of its four configurations.
///
/// Push through them to watch the leading cluster morph the same way the
/// trailing one does: the avatar and the back button swap at the transition
/// midpoint (glass cannot cross-fade into something that isn't glass), while
/// the trailing capsule holds its identifier-matched items throughout.
class _LeadingItemsDemo extends StatelessWidget {
  const _LeadingItemsDemo({this.stage = _LeadingStage.profile});

  final _LeadingStage stage;

  /// Unchanged across all four screens, so the trailing capsule is a constant
  /// while the leading side is the thing that moves.
  List<GlassBarItem> get _actions => [
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.add),
          id: 'add',
          label: 'Add',
          onTap: () {},
        ),
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.search),
          id: 'search',
          label: 'Search',
          onTap: () {},
        ),
      ];

  List<GlassBarItem> _leading(BuildContext context) => switch (stage) {
        _LeadingStage.profile => [
            // No shell at all: the photo is already a circle, and a capsule
            // behind it would read as a second, competing surface.
            const GlassBarItem.custom(
              child: _Avatar(),
              label: 'Account',
              background: GlassBarItemBackground.none,
            ),
          ],
        _LeadingStage.issues => const [],
        _LeadingStage.grouped => [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.sidebar_left),
              id: 'sidebar',
              label: 'Sidebar',
              onTap: () {},
            ),
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.slider_horizontal_3),
              id: 'filter',
              label: 'Filter',
              onTap: () {},
            ),
          ],
        _LeadingStage.cancel || _LeadingStage.both => [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.xmark),
              id: 'cancel',
              label: 'Cancel',
              // Its own shell, so it matches the circular back button it
              // stands in for rather than the taller shared capsule.
              background: GlassBarItemBackground.separate,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
      };

  String get _title => switch (stage) {
        _LeadingStage.profile => 'Profile',
        _LeadingStage.issues => 'Issues',
        _LeadingStage.cancel => 'New Issue',
        _LeadingStage.both => 'Filters',
        _LeadingStage.grouped => 'Library',
      };

  String get _blurb => switch (stage) {
        _LeadingStage.profile =>
          'The leading slot holds a bare avatar — GlassBarItemBackground.none, '
              'the analogue of UIBarButtonItem.hidesSharedBackground. Push to '
              'Issues and it swaps for the back button at the midpoint: one is '
              'glass and the other is not, and glass opacity is never animated, '
              'so the switch is deliberate rather than a fade.',
        _LeadingStage.issues =>
          'No leading of its own, so the automatic back button is implied — '
              'exactly as before this API existed. The trailing capsule has not '
              'moved once: both its items carry the same ids on every screen '
              'here.',
        _LeadingStage.cancel =>
          'A non-empty leading replaces the back button, matching UIKit\'s '
              'leftBarButtonItems and Flutter\'s own AppBar.leading. This one '
              'uses GlassBarItemBackground.separate, so it gets the same '
              'circular shell the back button had.',
        _LeadingStage.both =>
          'leadingItemsSupplementBackButton: true shows both, mirroring '
              'UINavigationItem.leftItemsSupplementBackButton. Two shells, '
              'because neither item shares a background with the other.',
        _LeadingStage.grouped =>
          'Two shared items, so one capsule — and the back button it replaced '
              'shared with nothing, so the shell arriving here grew out of a '
              '44pt circle into a 46pt capsule twice as wide. Both dimensions '
              'interpolate: the same morph the trailing capsule has always '
              'done, now on the leading side. Swipe from the left edge to '
              'scrub it.',
      };

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          _title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        leading: _leading(context),
        leadingItemsSupplementBackButton: stage == _LeadingStage.both,
        actions: _actions,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topPad + 44 + 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  _blurb,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
                if (stage == _LeadingStage.profile)
                  _PatternTile(
                    title: 'Open Issues',
                    subtitle: 'Avatar swaps for the back button',
                    icon: CupertinoIcons.arrow_right_circle,
                    onTap: () => _pushStage(context, _LeadingStage.issues),
                  ),
                if (stage == _LeadingStage.issues) ...[
                  _PatternTile(
                    title: 'Cancel Replaces Back',
                    subtitle: 'A custom leading takes the back button\'s place',
                    icon: CupertinoIcons.xmark_circle,
                    onTap: () => _pushStage(context, _LeadingStage.cancel),
                  ),
                  const SizedBox(height: 16),
                  _PatternTile(
                    title: 'Cancel Beside Back',
                    subtitle: 'leadingItemsSupplementBackButton: true',
                    icon: CupertinoIcons.rectangle_grid_1x2,
                    onTap: () => _pushStage(context, _LeadingStage.both),
                  ),
                  const SizedBox(height: 16),
                  _PatternTile(
                    title: 'Circle Grows Into Capsule',
                    subtitle:
                        'One shell, 44pt round to 46pt wide — width and height '
                        'both interpolate',
                    icon: CupertinoIcons.rectangle_expand_vertical,
                    onTap: () => _pushStage(context, _LeadingStage.grouped),
                  ),
                ],
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _pushStage(BuildContext context, _LeadingStage next) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => _LeadingItemsDemo(stage: next)),
    );
  }
}

/// A stand-in profile photo, sized to the circular bar-button diameter.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5AC8FA), Color(0xFF007AFF)],
        ),
      ),
      child: const Center(
        child: Text(
          'JT',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class _TitleCenteringDemo extends StatefulWidget {
  const _TitleCenteringDemo();

  @override
  State<_TitleCenteringDemo> createState() => _TitleCenteringDemoState();
}

class _TitleCenteringDemoState extends State<_TitleCenteringDemo> {
  bool _centered = true;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      // Deliberately the widget-based constructor: this demo verifies
      // asymmetric leading/trailing layout (#198), which needs real widgets.
      appBar: GlassAppBar(
        centerTitle: _centered,
        title: const Text('Title Centering'),
        leading: GlassButton(
          icon: const Icon(CupertinoIcons.back),
          width: 40,
          height: 40,
          iconSize: 20,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).top + 44 + 24,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                const Text(
                  'Title Centering',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toggle between centred and left-aligned to see the '
                  'difference live. The red line marks the bar\'s midpoint.',
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle — drives centerTitle on all three bars at once.
                GlassSegmentedControl(
                  segments: const [
                    GlassSegment(label: 'Centred'),
                    GlassSegment(label: 'Left-aligned'),
                  ],
                  selectedIndex: _centered ? 0 : 1,
                  onSegmentSelected: (i) => setState(() => _centered = i == 0),
                  useOwnLayer: true,
                ),
                const SizedBox(height: 32),

                // Case 1 — back button only (the exact reporter setup)
                _CenteringCase(
                  label: '1 · Back button only',
                  description: _centered
                      ? 'Title should bisect the guideline even with no trailing action.'
                      : 'Title left-aligns after the leading widget.',
                  centerTitle: _centered,
                  leading: GlassButton(
                    icon: const Icon(CupertinoIcons.back),
                    width: 40,
                    height: 40,
                    iconSize: 20,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 32),

                // Case 2 — asymmetric: narrow back + wide trailing
                _CenteringCase(
                  label: '2 · Asymmetric leading + trailing',
                  description: _centered
                      ? 'Leading ≈ 40 px, trailing ≈ 96 px — title still on the guideline.'
                      : 'Left-aligned, well clear of the guideline.',
                  centerTitle: _centered,
                  leading: GlassButton(
                    icon: const Icon(CupertinoIcons.back),
                    width: 40,
                    height: 40,
                    iconSize: 20,
                    onTap: () {},
                  ),
                  actions: [
                    GlassButton(
                      icon: const Icon(CupertinoIcons.share),
                      width: 40,
                      height: 40,
                      iconSize: 20,
                      onTap: () {},
                    ),
                    GlassButton(
                      icon: const Icon(CupertinoIcons.ellipsis_circle),
                      width: 40,
                      height: 40,
                      iconSize: 20,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Case 3 — no leading, no trailing (baseline)
                _CenteringCase(
                  label: '3 · No leading, no trailing',
                  description: _centered
                      ? 'Trivial case — title always lands on the guideline.'
                      : 'Left-aligns to the bar\'s padding edge.',
                  centerTitle: _centered,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a labelled bar preview with a translucent red centre guideline.
///
/// Builds the [GlassAppBar] internally so [centerTitle] can be toggled live
/// from the parent without rebuilding the entire widget tree.
class _CenteringCase extends StatelessWidget {
  const _CenteringCase({
    required this.label,
    required this.description,
    required this.centerTitle,
    this.leading,
    this.actions,
  });

  final String label;
  final String description;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Align(
            key: ValueKey(description),
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Inline bar preview clipped inside a glass card.
        GlassCard(
          settings: RecommendedGlassSettings.overlay,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 52,
              child: Stack(
                children: [
                  // Bar — built here so centerTitle can be toggled live.
                  // MediaQuery zeros the padding so that GlassAppBar's
                  // internal SafeArea doesn't add the status-bar inset and
                  // push all content out of this 52 px inline preview.
                  Positioned.fill(
                    child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(padding: EdgeInsets.zero),
                      child: GlassIsolationScope(
                        isolated: true,
                        defaultQuality: GlassQuality.premium,
                        child: GlassAppBar(
                          centerTitle: centerTitle,
                          title: const Text('Page Title'),
                          leading: leading,
                          actions: actions,
                        ),
                      ),
                    ),
                  ),

                  // Red centre guideline — 1 px wide, semi-transparent.
                  // Align(center) positions relative to the full Stack width,
                  // so no LayoutBuilder/Positioned is needed.
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 1,
                      child: ColoredBox(
                        color: CupertinoColors.systemRed
                            .resolveFrom(context)
                            .withValues(alpha: 0.6),
                      ),
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
}

// =============================================================================
// 8. Nested Navigation — pinned actions across pushes
// =============================================================================

/// A three-level drill-down showing the GlassNavigationShell behaviour: the
/// back button and actions capsule stay pinned while pages slide, and the
/// capsule morphs in place into each level's actions.
///
/// The compose action carries `id: 'compose'` on the first two levels, so it
/// is treated as the same item across the push (the
/// `UIBarButtonItem.identifier` behaviour) and holds its position while the
/// item beside it cross-fades. The deepest level has no actions at all, so
/// the capsule switches off while the back button stays.
class _NestedNavDemo extends StatelessWidget {
  const _NestedNavDemo({this.depth = 0});

  final int depth;

  static const _titles = ['Inbox', 'Thread', 'Attachment'];

  List<GlassBarItem> _actionsFor(int depth) {
    switch (depth) {
      case 0:
        return [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.pencil),
            id: 'compose',
            label: 'Compose',
            onTap: () {},
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.search),
            label: 'Search',
            onTap: () {},
          ),
        ];
      case 1:
        return [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.pencil),
            id: 'compose',
            label: 'Compose',
            onTap: () {},
          ),
          GlassBarItem.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'More',
            menuItems: [
              GlassMenuItem(
                title: 'Mark unread',
                icon: const Icon(CupertinoIcons.envelope_badge),
                onTap: () {},
              ),
              GlassMenuItem(
                title: 'Move to…',
                icon: const Icon(CupertinoIcons.folder),
                onTap: () {},
              ),
              GlassMenuDivider(),
              GlassMenuItem(
                title: 'Delete',
                icon: const Icon(CupertinoIcons.delete),
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          _titles[depth],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: _actionsFor(depth),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  switch (depth) {
                    0 => 'Watch the bar while navigating: the compose action '
                        'is identifier-matched and holds its position, the '
                        'search action cross-fades into more, and the whole '
                        'cluster stays pinned while the page slides.',
                    1 => 'Compose stayed put — same id on both levels. The '
                        'next level has no actions, so the capsule switches '
                        'off while the back button stays pinned.',
                    _ => 'No actions here: the capsule is gone, the back '
                        'button remains. Swipe from the left edge to scrub '
                        'the morph back in.',
                  },
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
                if (depth < 2)
                  _PatternTile(
                    title: 'Open ${_titles[depth + 1]}',
                    subtitle: depth == 0
                        ? 'Compose holds, search becomes more'
                        : 'All actions leave, back button stays',
                    icon: CupertinoIcons.arrow_right_circle,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => _NestedNavDemo(depth: depth + 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// 10. Custom Bar Pinning — a bar that is not a GlassAppBar
// =============================================================================

/// A two-level drill-down whose bar is a plain Flutter [AppBar].
///
/// This is the [GlassPinnedBarChrome] path: an app that already owns its bar —
/// its own backdrop, its own title treatment — declares that bar's items as
/// data and lets the shell pin them, without giving up the bar itself. The
/// chrome morphs across the push exactly as it does for `GlassAppBar.pinned`,
/// and the `AppBar` slides with the page underneath it.
///
/// `hoisted` is what keeps the hand-over invisible: until the shell has had a
/// frame to render its copy, the `AppBar` draws its own back button and icons;
/// after, it draws same-sized placeholders so the title never shifts.
class _CustomBarPinningDemo extends StatelessWidget {
  const _CustomBarPinningDemo({this.depth = 0});

  final int depth;

  static const _titles = ['Documents', 'Folder'];

  /// The trailing items for a level. The plus carries an id on both levels, so
  /// it is identifier-matched and holds its position across the push.
  List<GlassBarItem> _actionsFor(int depth) => [
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.plus),
          id: 'add',
          label: 'New',
          onTap: () {},
        ),
        GlassBarItem.icon(
          icon: Icon(
            depth == 0 ? CupertinoIcons.search : CupertinoIcons.ellipsis,
          ),
          label: depth == 0 ? 'Search' : 'More',
          onTap: () {},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return GlassPinnedBarChrome(
      actions: _actionsFor(depth),
      // A Material `AppBar` needs `MaterialLocalizations`, which this demo's
      // `CupertinoApp` does not provide — an app built on `MaterialApp` gets
      // them for free and can drop this wrapper.
      builder: (context, chrome) => Localizations.override(
        context: context,
        delegates: const [DefaultMaterialLocalizations.delegate],
        child: Stack(
          children: [
            const Positioned.fill(child: ShowcaseBackground()),
            Scaffold(
              backgroundColor: const Color(0x00000000),
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: const Color(0x00000000),
                // The items were declared once, as data. These slots hold the
                // real glass buttons until the shell takes them and hold their
                // space after, so the bar never has to build a second copy.
                automaticallyImplyLeading: false,
                leading: chrome.leading,
                actions: chrome.actions,
                title: Text(_titles[depth]),
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.paddingOf(context).top + 44 + 16,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList.list(
                      children: [
                        Text(
                          depth == 0
                              ? 'This bar is a Material AppBar, not a '
                                  'GlassAppBar. Its items are declared once as '
                                  'data and pinned by the shell; the bar itself '
                                  'still slides with the page.'
                              : 'The new action was identifier-matched and held '
                                  'its position; search cross-faded into more. '
                                  'Swipe from the left edge to scrub the morph '
                                  'back.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (depth == 0)
                          _PatternTile(
                            title: 'Open ${_titles[1]}',
                            subtitle: 'New holds, search becomes more',
                            icon: CupertinoIcons.arrow_right_circle,
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) =>
                                    const _CustomBarPinningDemo(depth: 1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildDummyContent(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 12. Header Actions Morph — trailing capsule across a drill-down
// =============================================================================

/// A repository-style drill-down for exercising trailing-cluster morphs.
///
/// The root repository screen carries the classic `[+ ⋯]` capsule and every
/// row pushes a screen with a different trailing cluster, so each shape the
/// capsule has to morph through can be watched in isolation:
///
///   * Workflows — a single share action. Nothing is identifier-matched, so
///     the trailing slot cross-fades while the two-icon capsule contracts
///     around it — the classic two-icons-to-share transition.
///   * Discussions — the add action carries `id: 'add'` on both levels, so it
///     holds its position while the menu beside it becomes search.
///   * Pull Requests — the same two actions as the root. Nothing changes,
///     so nothing moves: an unchanged cluster sits perfectly still, exactly
///     as the native bar keeps it.
///   * Watchers — no actions at all. The capsule dematerializes — the glass
///     dissolves through the shader — while the back button stays pinned.
///   * Insights — three actions. The capsule widens around the cluster.
///
/// Swipe from the left edge to scrub any of the morphs interactively.
class _HeaderMorphDemo extends StatelessWidget {
  const _HeaderMorphDemo();

  List<GlassBarItem> get _actions => [
        GlassBarItem.icon(
          icon: const Icon(CupertinoIcons.add),
          id: 'add',
          label: 'Add',
          onTap: () {},
        ),
        GlassBarItem.menu(
          icon: const Icon(CupertinoIcons.ellipsis),
          label: 'More',
          menuItems: [
            GlassMenuItem(
              title: 'Share repository',
              icon: const Icon(CupertinoIcons.share),
              onTap: () {},
            ),
            GlassMenuItem(
              title: 'Favourite',
              icon: const Icon(CupertinoIcons.star),
              onTap: () {},
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          'Repository',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: _actions,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  'Watch the trailing capsule while navigating: each row '
                  'pushes a screen with a different action cluster, and the '
                  'capsule morphs between them the way the native iOS 26 '
                  'bar does.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
                _PatternTile(
                  title: 'Workflows',
                  subtitle: 'Two icons contract to a single share action',
                  icon: CupertinoIcons.arrow_2_circlepath,
                  onTap: () => _pushDestination(
                    context,
                    title: 'Workflows',
                    blurb: 'Nothing here matches the previous cluster: the '
                        'trailing slot cross-fades into share while the '
                        'capsule contracts to one icon, and add leaves with '
                        'it. Swipe back to scrub the morph in reverse.',
                    actions: [
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.share),
                        label: 'Share',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _PatternTile(
                  title: 'Discussions',
                  subtitle: 'Add holds its position, the menu becomes search',
                  icon: CupertinoIcons.bubble_left_bubble_right,
                  onTap: () => _pushDestination(
                    context,
                    title: 'Discussions',
                    blurb: 'The add action carries the same id on both '
                        'levels, so it is treated as the same item and holds '
                        'its position while the menu cross-fades into '
                        'search.',
                    actions: [
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.add),
                        id: 'add',
                        label: 'Add',
                        onTap: () {},
                      ),
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.search),
                        label: 'Search',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _PatternTile(
                  title: 'Pull Requests',
                  subtitle:
                      'Identical actions — the capsule sits perfectly still',
                  icon: CupertinoIcons.arrow_branch,
                  onTap: () => _pushDestination(
                    context,
                    title: 'Pull Requests',
                    blurb: 'The same two actions as the previous screen: '
                        'nothing enters, leaves or changes, so the capsule '
                        'does not move at all while the page slides under '
                        'it.',
                    actions: [
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.add),
                        id: 'add',
                        label: 'Add',
                        onTap: () {},
                      ),
                      GlassBarItem.menu(
                        icon: const Icon(CupertinoIcons.ellipsis),
                        label: 'More',
                        menuItems: [
                          GlassMenuItem(
                            title: 'Share repository',
                            icon: const Icon(CupertinoIcons.share),
                            onTap: () {},
                          ),
                          GlassMenuItem(
                            title: 'Favourite',
                            icon: const Icon(CupertinoIcons.star),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _PatternTile(
                  title: 'Watchers',
                  subtitle: 'All actions leave — the capsule dematerializes',
                  icon: CupertinoIcons.eye,
                  onTap: () => _pushDestination(
                    context,
                    title: 'Watchers',
                    blurb: 'No actions here: the capsule dissolves away '
                        'while the back button stays pinned, and '
                        'materializes back in on the pop.',
                    actions: const [],
                  ),
                ),
                const SizedBox(height: 12),
                _PatternTile(
                  title: 'Insights',
                  subtitle: 'The capsule widens around three actions',
                  icon: CupertinoIcons.chart_bar,
                  onTap: () => _pushDestination(
                    context,
                    title: 'Insights',
                    blurb: 'Three actions where there were two: the capsule '
                        'widens around the incoming cluster while add, '
                        'identifier-matched again, holds its place.',
                    actions: [
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.add),
                        id: 'add',
                        label: 'Add',
                        onTap: () {},
                      ),
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.calendar),
                        label: 'Period',
                        onTap: () {},
                      ),
                      GlassBarItem.icon(
                        icon: const Icon(CupertinoIcons.share),
                        label: 'Share',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _pushDestination(
    BuildContext context, {
    required String title,
    required String blurb,
    required List<GlassBarItem> actions,
  }) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => _HeaderMorphDestination(
          title: title,
          blurb: blurb,
          actions: actions,
        ),
      ),
    );
  }
}

/// One destination in the header-morph drill-down.
///
/// Nothing here beyond a pinned bar with the destination's action cluster —
/// the screen exists so the morph to and from its cluster can be watched.
class _HeaderMorphDestination extends StatelessWidget {
  const _HeaderMorphDestination({
    required this.title,
    required this.blurb,
    required this.actions,
  });

  final String title;
  final String blurb;
  final List<GlassBarItem> actions;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: actions,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: topPad + 44 + 16),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  blurb,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// =============================================================================
// 13. Presented Sheets — what a modal presentation covers, and what it doesn't
// =============================================================================

/// A pinned screen that presents each kind of modal route over itself.
///
/// Pushing and presenting need opposite treatment, and this is the presenting
/// half. A pushed route slides the covered bar away with its page, so the
/// chrome retreats with it; a presented one comes up over the whole navigation
/// stack with the bar inside it, so the chrome has to be *under* it — still on
/// screen behind a sheet, dimming with the barrier like the rest of the page.
///
/// The shell cannot draw it there, because it draws above the `Navigator` the
/// presentation was pushed into, so each of these hands the chrome back to the
/// route for as long as it is up (#259).
///
/// The full-height sheet reads clearest: it goes opaque at the `large` detent,
/// so a back button still drawn on top would be left floating on a solid
/// surface with nothing behind it to refract.
class _PresentedSheetsDemo extends StatelessWidget {
  const _PresentedSheetsDemo();

  void _showSheet(BuildContext context) {
    GlassModalSheet.show<void>(
      context: context,
      initialState: GlassSheetState.full,
      builder: (_) => const _PresentedSheetBody(
        title: 'Full-height sheet',
        body: 'This surface is opaque at the large detent, and nothing is '
            'drawn on top of it — the back button and actions capsule are '
            'behind it, with the rest of the page.',
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Share'),
        message: const Text(
          'The barrier dims the page behind this sheet, the pinned back '
          'button and actions capsule included.',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Copy Link'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Add to Reading List'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Discard draft?'),
        content: const Text(
          'An alert dims the whole screen. Look at the bar: the back button '
          'and the capsule dim with everything else.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showFullscreenDialog(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const _ComposeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          'Presented Sheets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.share),
            label: 'Share',
            onTap: () => _showActionSheet(context),
          ),
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'More',
            onTap: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topPad + 44 + 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  'Each of these is presented over this screen, and each '
                  'covers the pinned chrome along with the rest of the page. '
                  'Watch the back button and the capsule dim with the barrier: '
                  'presenting hands them back to the route, where a '
                  'presentation can reach them.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
                _PatternTile(
                  title: 'Full-Height Sheet',
                  subtitle: 'Opaque at the large detent — the clearest read',
                  icon: CupertinoIcons.rectangle_expand_vertical,
                  onTap: () => _showSheet(context),
                ),
                const SizedBox(height: 16),
                _PatternTile(
                  title: 'Action Sheet',
                  subtitle:
                      'showCupertinoModalPopup — barrier dims the bar too',
                  icon: CupertinoIcons.share,
                  onTap: () => _showActionSheet(context),
                ),
                const SizedBox(height: 16),
                _PatternTile(
                  title: 'Alert Dialog',
                  subtitle:
                      'showCupertinoDialog — full-screen dim, bar included',
                  icon: CupertinoIcons.exclamationmark_bubble,
                  onTap: () => _showDialog(context),
                ),
                const SizedBox(height: 16),
                _PatternTile(
                  title: 'Fullscreen Dialog',
                  subtitle: 'An opaque page, presented rather than pushed',
                  icon: CupertinoIcons.square_arrow_up,
                  onTap: () => _showFullscreenDialog(context),
                ),
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// A trailing cluster whose first item morphs into a sheet.
///
/// The counterpart to [_PresentedSheetsDemo]: presenting hands the chrome back
/// to the route, all but the capsule the droplet came out of — the shell
/// keeps that one, emptied, which is why nothing is drawn where it was until
/// the droplet is caught.
/// Push into the second screen to see the same item morph across a route
/// change as ordinary data.
class _SheetItemDemo extends StatelessWidget {
  const _SheetItemDemo({this.detail = false});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => page),
    );
  }

  /// Whether this is the pushed screen, which carries a second action.
  final bool detail;

  void _present(BuildContext context, GlassMorphAnchor? anchor) {
    GlassModalSheet.show<void>(
      context: context,
      morphFrom: anchor,
      initialState: GlassSheetState.half,
      builder: (_) => const _PresentedSheetBody(
        title: 'Out of the capsule',
        body: 'The capsule emptied, a droplet stretched out of it and became '
            'this sheet. Dismiss it and the droplet is poured back into the '
            'bar it came from.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          detail ? 'Detail' : 'Sheet Item',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        actions: [
          GlassBarItem.sheet(
            icon: const Icon(CupertinoIcons.add),
            label: 'Add',
            id: 'add',
            onPresent: (anchor) => _present(context, anchor),
          ),
          if (detail)
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.share),
              label: 'Share',
              id: 'share',
              onTap: () {},
            ),
          GlassBarItem.menu(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: 'More',
            id: 'more',
            menuItems: [
              GlassMenuItem(
                title: 'Rename',
                icon: const Icon(CupertinoIcons.pencil),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topPad + 44 + 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                Text(
                  'Tap (+). The whole capsule empties — the ellipsis with it, '
                  'because on screen the cluster is one control — and the '
                  'droplet stretches out of its frame rather than out of the '
                  'glyph. Nothing is drawn where the capsule was until the '
                  'sheet is dismissed.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),
                if (!detail)
                  _PatternTile(
                    title: 'Push To A Second Screen',
                    subtitle: 'The item is ordinary data, so the capsule '
                        'morphs across the push and (+) holds its place',
                    icon: CupertinoIcons.arrow_right,
                    onTap: () =>
                        _push(context, const _SheetItemDemo(detail: true)),
                  ),
              ],
            ),
          ),
          _buildDummyContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Content for the presented sheet — deliberately plain, so the only glass in
/// frame is the pinned chrome sitting on top of it.
class _PresentedSheetBody extends StatelessWidget {
  const _PresentedSheetBody({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// The destination behind [_PresentedSheetsDemo]'s fullscreen dialog.
class _ComposeScreen extends StatelessWidget {
  const _ComposeScreen();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Message'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'A fullscreen dialog covers the page completely — the pinned back '
            'button and capsule from the screen behind included, with nothing '
            'left showing through.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 14. Tinted Bar Items  (#312)
// =============================================================================

/// Demonstrates [GlassBarItem.tintColor] — the iOS 26 prominent-action pattern.
///
/// The screen mirrors a real "New Event" form:
///   • Leading  → Cancel (untinted, shared background, no capsule tint)
///   • Trailing → Add    (blue, separate background, capsule flood-filled)
///
/// The body includes a side-by-side comparison strip that shows the visual
/// difference between the old approach (Icon colour only, grey glass rim still
/// visible) and the new tintColor (entire capsule floods with the design token,
/// auto-flips icon to white).
class _TintedBarItemDemo extends StatefulWidget {
  const _TintedBarItemDemo();

  @override
  State<_TintedBarItemDemo> createState() => _TintedBarItemDemoState();
}

class _TintedBarItemDemoState extends State<_TintedBarItemDemo> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.auto,
      appBar: GlassAppBar.pinned(
        title: Text(
          'New Event',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        // ── Leading: Cancel ─────────────────────────────────────────────────
        // Untinted, shared background — plain glass capsule, standard label.
        leading: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.xmark),
            label: 'Cancel',
            background: GlassBarItemBackground.separate,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
        // ── Trailing: Add ───────────────────────────────────────────────────
        // tintColor floods the entire glass capsule with activeBlue.
        // The checkmark flips to white automatically — no Icon(color:) needed.
        actions: [
          GlassBarItem.icon(
            icon: const Icon(CupertinoIcons.checkmark),
            label: 'Save',
            background: GlassBarItemBackground.separate,
            tintColor: _saved
                ? CupertinoColors.systemGreen
                : CupertinoColors.activeBlue,
            onTap: () => setState(() => _saved = !_saved),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topPad + 44 + 24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                // ── Call-out ─────────────────────────────────────────────────
                Text(
                  _saved
                      ? '✓ Saved! Tap the button again to toggle back to blue.'
                      : 'Tap the blue checkmark in the top-right to save.\n'
                          'The capsule floods with the tintColor — not just the '
                          'glyph — and the icon auto-flips to white.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Side-by-side comparison ───────────────────────────────────
                Text(
                  'Before vs After',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All four capsules use the same activeBlue. '
                  '"Before" colours only the glyph — the glass capsule stays neutral. '
                  '"After" floods the entire capsule via tintColor on both quality tiers.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Row 1 — Before (Standard | Premium)
                Row(
                  children: [
                    Expanded(
                      child: _TintComparisonCard(
                        label: 'Before',
                        qualityTag: 'Standard',
                        labelColor: CupertinoColors.systemRed,
                        description: 'Icon(color:)\nGrey rim visible',
                        child: GlassButton.custom(
                          onTap: () {},
                          shape: const LiquidRoundedRectangle(
                            borderRadius: 22,
                          ),
                          width: 44,
                          height: 44,
                          child: const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.activeBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TintComparisonCard(
                        label: 'Before',
                        qualityTag: 'Premium',
                        labelColor: CupertinoColors.systemRed,
                        description: 'Icon(color:)\nGrey rim visible',
                        child: GlassButton.custom(
                          onTap: () {},
                          quality: GlassQuality.premium,
                          useOwnLayer: true,
                          shape: const LiquidRoundedRectangle(
                            borderRadius: 22,
                          ),
                          width: 44,
                          height: 44,
                          child: const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.activeBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2 — After (Standard | Premium)
                Row(
                  children: [
                    Expanded(
                      child: _TintComparisonCard(
                        label: 'After',
                        qualityTag: 'Standard',
                        labelColor: CupertinoColors.systemGreen,
                        description: 'tintColor:\nCapsule floods',
                        child: GlassButtonGroup.icons(
                          settings: LiquidGlassSettings(
                            glassColor: CupertinoColors.activeBlue,
                            bodyMode: GlassBodyMode.clear,
                          ),
                          items: [
                            GlassButtonGroupItem(
                              icon: const Icon(CupertinoIcons.checkmark),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TintComparisonCard(
                        label: 'After',
                        qualityTag: 'Premium',
                        labelColor: CupertinoColors.systemGreen,
                        description: 'tintColor:\nCapsule floods',
                        child: GlassButtonGroup.icons(
                          settings: LiquidGlassSettings(
                            glassColor: CupertinoColors.activeBlue,
                            bodyMode: GlassBodyMode.clear,
                          ),
                          useOwnLayer: true,
                          items: [
                            GlassButtonGroupItem(
                              icon: const Icon(CupertinoIcons.checkmark),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Colour palette showcase ───────────────────────────────────
                Text(
                  'Colour Range',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Any Color works. The specular rim adapts; foreground '
                  'flips automatically based on luminance.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _TintPill(
                      icon: CupertinoIcons.checkmark,
                      tintColor: CupertinoColors.activeBlue,
                      name: 'activeBlue',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.trash,
                      tintColor: CupertinoColors.systemRed,
                      name: 'systemRed',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.heart_fill,
                      tintColor: CupertinoColors.systemPink,
                      name: 'systemPink',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.star_fill,
                      tintColor: CupertinoColors.systemOrange,
                      name: 'systemOrange',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.checkmark_seal_fill,
                      tintColor: CupertinoColors.systemGreen,
                      name: 'systemGreen',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.bolt_fill,
                      tintColor: CupertinoColors.systemYellow,
                      name: 'systemYellow',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.eye,
                      tintColor: CupertinoColors.systemPurple,
                      name: 'systemPurple',
                    ),
                    _TintPill(
                      icon: CupertinoIcons.snow,
                      tintColor: CupertinoColors.systemTeal,
                      name: 'systemTeal',
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Code snippet ──────────────────────────────────────────────
                Text(
                  'Usage',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemFill.resolveFrom(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'GlassBarItem.icon(\n'
                    '  icon: const Icon(CupertinoIcons.checkmark),\n'
                    '  onTap: _save,\n'
                    '  background: GlassBarItemBackground.separate,\n'
                    '  tintColor: CupertinoColors.activeBlue,\n'
                    ');',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.6,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled card framing a glass button for the before/after comparison.
class _TintComparisonCard extends StatelessWidget {
  const _TintComparisonCard({
    required this.label,
    required this.labelColor,
    required this.description,
    required this.child,
    this.qualityTag,
  });

  final String label;
  final CupertinoDynamicColor labelColor;
  final String description;
  final Widget child;

  /// Optional quality tier label shown as a small badge (e.g. 'Standard', 'Premium').
  final String? qualityTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.systemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: labelColor.resolveFrom(context),
                ),
              ),
              if (qualityTag != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        CupertinoColors.tertiarySystemFill.resolveFrom(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    qualityTag!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Center(child: child),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single tinted pill in the colour-palette showcase row.
class _TintPill extends StatelessWidget {
  const _TintPill({
    required this.icon,
    required this.tintColor,
    required this.name,
  });

  final IconData icon;
  final CupertinoDynamicColor tintColor;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassButtonGroup.icons(
          settings: LiquidGlassSettings(
            glassColor: tintColor.resolveFrom(context),
            bodyMode: GlassBodyMode.clear,
          ),
          useOwnLayer: true,
          items: [
            GlassButtonGroupItem(
              icon: Icon(icon),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    );
  }
}
