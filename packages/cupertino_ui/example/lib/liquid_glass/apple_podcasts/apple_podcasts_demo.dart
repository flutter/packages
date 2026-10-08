/// Apple Podcasts iOS 26 — High-Fidelity Demo
///
/// Demonstrates the official "accessory shelf" pattern using Liquid Glass widgets,
/// including a mini-player pill that expands into a full `GlassSheet` Now Playing screen.
/// This uses the new `bottomAccessory` API in `GlassTabBar` to seamlessly handle
/// the expanded/inline geometric transitions without manual Stack math.
///
/// Run standalone:
///   flutter run -d macos -t lib/apple_podcasts/apple_podcasts_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

const _kPodcastsPurple = Color(0xFFB877FF);
const _kBackground = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F2F7), darkColor: Color(0xFF000000));
const _kBarH = 64.0;
const _kPaddingH = 20.0;
const _kPaddingV = 16.0;
const _kSpacing = 8.0;

// Cupertino-compatible rainbow palette — replaces Colors.primaries
const _kPalette = [
  Color(0xFFFF3B30),
  Color(0xFFFF9500),
  Color(0xFFFFCC00),
  Color(0xFF34C759),
  Color(0xFF00C7BE),
  Color(0xFF32ADE6),
  Color(0xFF007AFF),
  Color(0xFF5856D6),
  Color(0xFFAF52DE),
  Color(0xFFFF2D55),
  Color(0xFFFF6B00),
  Color(0xFF30B0C7),
];

// ─── Podcast data models ────────────────────────────────────────────────────

class _PodcastItem {
  const _PodcastItem({
    required this.title,
    required this.author,
    required this.duration,
    required this.color,
    required this.icon,
    this.progress = 0.0,
    this.itunesId,
  });
  final String title;
  final String author;
  final String duration;
  final Color color;
  final IconData icon;
  final double progress;

  /// iTunes Store podcast ID — artwork is fetched live via the iTunes lookup API.
  final int? itunesId;
}

// ─── Podcast episode / show data ─────────────────────────────────────────────
// itunesId values are the Apple Podcasts Store IDs for each show.

const _kUpNext = [
  _PodcastItem(
    title: 'The Ricky Gervais Podcast',
    author: 'Ricky Gervais',
    duration: '1h 7m',
    color: Color(0xFF1A1A2E),
    icon: CupertinoIcons.mic,
    progress: 0.15,
    itunesId: 135789411,
  ),
  _PodcastItem(
    title: 'The Daily',
    author: 'The New York Times',
    duration: '22m',
    color: Color(0xFF0C0C0E),
    icon: CupertinoIcons.book,
    progress: 0.45,
    itunesId: 1200361736,
  ),
  _PodcastItem(
    title: 'Hard Fork',
    author: 'The New York Times',
    duration: '48m',
    color: Color(0xFF1C2340),
    icon: CupertinoIcons.antenna_radiowaves_left_right,
    itunesId: 1528594034,
  ),
  _PodcastItem(
    title: 'Lex Fridman Podcast #421',
    author: 'Lex Fridman',
    duration: '2h 14m',
    color: Color(0xFF0D0D0D),
    icon: CupertinoIcons.videocam_fill,
    itunesId: 1434243584,
  ),
];

const _kNowWithVideo = [
  _PodcastItem(
    title: 'Huberman Lab',
    author: 'Dr. Andrew Huberman',
    duration: '2h 3m',
    color: Color(0xFF1B3A4B),
    icon: CupertinoIcons.flame_fill,
    itunesId: 1545953110,
  ),
  _PodcastItem(
    title: 'SmartLess',
    author: 'Jason Bateman, Sean Hayes, Will Arnett',
    duration: '54m',
    color: Color(0xFF2B2B2B),
    icon: CupertinoIcons.star_fill,
    itunesId: 1521578868,
  ),
  _PodcastItem(
    title: "Conan O'Brien Needs A Friend",
    author: 'Team Coco & Earwolf',
    duration: '1h 12m',
    color: Color(0xFF3D1A00),
    icon: CupertinoIcons.person_2_fill,
    itunesId: 1438054347,
  ),
  _PodcastItem(
    title: 'Crime Junkie',
    author: 'audiochuck',
    duration: '40m',
    color: Color(0xFF2D0000),
    icon: CupertinoIcons.exclamationmark_triangle_fill,
    itunesId: 1322200189,
  ),
];

const _kYouMightLike = [
  _PodcastItem(
    title: 'Hidden Brain',
    author: 'Shankar Vedantam',
    duration: '45m',
    color: Color(0xFF2E1A00),
    icon: CupertinoIcons.infinite,
    itunesId: 1028908750,
  ),
  _PodcastItem(
    title: 'Stuff You Should Know',
    author: 'iHeart Podcasts',
    duration: 'Bi-weekly',
    color: Color(0xFF001A33),
    icon: CupertinoIcons.book_fill,
    itunesId: 278981407,
  ),
  _PodcastItem(
    title: 'No Such Thing as a Fish',
    author: 'QI Elves',
    duration: '30m',
    color: Color(0xFF1A2D3D),
    icon: CupertinoIcons.sparkles,
    itunesId: 840986946,
  ),
  _PodcastItem(
    title: 'Planet Money',
    author: 'NPR',
    duration: 'Bi-weekly',
    color: Color(0xFF1A1200),
    icon: CupertinoIcons.chart_bar_fill,
    itunesId: 290783428,
  ),
  _PodcastItem(
    title: 'Darknet Diaries',
    author: 'Jack Rhysider',
    duration: '1h',
    color: Color(0xFF1C0A1A),
    icon: CupertinoIcons.lock_fill,
    itunesId: 1296350485,
  ),
];

const _kPopularShows = [
  _PodcastItem(
    title: 'TED Talks Daily',
    author: 'TED',
    duration: 'Daily',
    color: Color(0xFF001A1A),
    icon: CupertinoIcons.waveform,
    itunesId: 160904630,
  ),
  _PodcastItem(
    title: 'My Favorite Murder',
    author: 'Exactly Right',
    duration: 'Weekly',
    color: Color(0xFF1A001A),
    icon: CupertinoIcons.star_fill,
    itunesId: 1074507850,
  ),
  _PodcastItem(
    title: 'Serial',
    author: 'Serial Productions & The New York Times',
    duration: 'Varies',
    color: Color(0xFF1A2E1A),
    icon: CupertinoIcons.headphones,
    itunesId: 917918570,
  ),
  _PodcastItem(
    title: '99% Invisible',
    author: 'Roman Mars',
    duration: 'Bi-weekly',
    color: Color(0xFF2A1A00),
    icon: CupertinoIcons.building_2_fill,
    itunesId: 394775318,
  ),
  _PodcastItem(
    title: 'Freakonomics Radio',
    author: 'Freakonomics Radio + Stitcher',
    duration: 'Weekly',
    color: Color(0xFF00141A),
    icon: CupertinoIcons.chart_bar_square_fill,
    itunesId: 354668519,
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const ApplePodcastsDemoApp()));
}

class ApplePodcastsDemoApp extends StatelessWidget {
  const ApplePodcastsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Apple Podcasts',
      theme: const CupertinoThemeData(),
      home: const ApplePodcastsHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ApplePodcastsHomeScreen extends StatefulWidget {
  const ApplePodcastsHomeScreen({super.key});

  @override
  State<ApplePodcastsHomeScreen> createState() =>
      _ApplePodcastsHomeScreenState();
}

class _ApplePodcastsHomeScreenState extends State<ApplePodcastsHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isMiniMode = false;
  bool _isSearching = false;
  bool _searchFieldFocused = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onScroll() {
    final mini = _scrollController.offset > 50;
    if (mini == _isMiniMode) return;
    setState(() => _isMiniMode = mini);
  }

  void _onFocusChange() {
    setState(() => _searchFieldFocused = _searchFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showNowPlayingSheet(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    GlassModalSheet.show(
      context: context,
      initialState: GlassSheetState.full,
      halfSize: 0,
      settings: LiquidGlassSettings(
        glassColor: isDark ? const Color(0xAA1C1C1E) : const Color(0xAAF2F2F7),
        thickness: 40,
        blur: 15,
        lightIntensity: 0.6,
      ),
      builder: (context) => const NowPlayingView(),
    );
  }

  void _dismissMiniMode() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart);
    }
    setState(() {
      _isSearching = false;
      _searchFieldFocused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Match Apple Music demo: iOS floats over home indicator, Android clears nav bar.
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final sysBottom = isIOS ? 0.0 : MediaQuery.viewPaddingOf(context).bottom;

    // Content bottom padding: bar (64) + vertical padding (16*2) + accessory (50)
    // + spacing (8) + extra clearance (8).
    final double contentPad =
        _kBarH + 2 * _kPaddingV + 50.0 + _kSpacing + 8.0 + sysBottom;

    return GlassScaffold(
      background: ColoredBox(color: _kBackground.resolveFrom(context)),
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      topEdgeFade: true,
      bottomEdgeFade: true,
      topEdgeFadeExtent: 0, // no app bar — just status bar fade
      bottomEdgeFadeExtent: 0, // glass bar is transparent
      resizeToAvoidBottomInset: false,

      // ── Fixed header — fades on scroll ──────────────────────────────────────
      header: (_selectedTab == 0 && !_isSearching) ? _buildHomeHeader() : null,
      headerScrollController: _scrollController,
      headerFadeDistance: 30,

      // ── Body ────────────────────────────────────────────────────────────────
      body: GestureDetector(
        onTap: () {
          if (_searchFieldFocused) FocusScope.of(context).unfocus();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !_isSearching
              ? _buildHomeView(
                  key: const ValueKey('home'), contentPad: contentPad)
              : _searchFieldFocused
                  ? _buildEmptySearch(key: const ValueKey('empty'))
                  : _buildBrowseView(
                      key: const ValueKey('browse'), contentPad: contentPad),
        ),
      ),

      // ── Bottom navigation bar ──────────────────────────────────────────────
      bottomBar: GlassTabBar.searchable(
        isSearchActive: _isMiniMode || _isSearching,
        bottomAccessoryPlacement: (_isMiniMode && !_isSearching)
            ? GlassTabBarAccessoryPlacement.inline
            : GlassTabBarAccessoryPlacement.expanded,
        selectedIndex: _selectedTab,
        onTabSelected: (index) {
          if (index == _selectedTab && _isMiniMode) {
            _dismissMiniMode();
          } else {
            setState(() {
              _selectedTab = index;
              _isSearching = false;
            });
          }
        },
        barHeight: _kBarH,
        searchBarHeight: 50.0,
        horizontalPadding: _kPaddingH,
        verticalPadding: _kPaddingV,
        spacing: _kSpacing,
        // ── tabViewBottomAccessory (iOS 26) ─────────────────────────────────
        // Play pill sits above the bar in expanded mode; in mini-mode it
        // slides inline beside the collapsed search capsule.
        bottomAccessory: GlassButton.custom(
          onTap: () => _showNowPlayingSheet(context),
          quality: GlassQuality.premium,
          useOwnLayer: true,
          width: double.infinity,
          height: 50,
          shape: const LiquidRoundedRectangle(borderRadius: 25),
          settings: LiquidGlassSettings(
            glassColor: CupertinoTheme.brightnessOf(context) == Brightness.dark
                ? const Color(0xCC1C1C1E)
                : const Color(0xCCF2F2F7),
            thickness: 30,
            blur: 2,
            lightIntensity: 0.18,
            chromaticAberration: .01,
            saturation: 1.2,
            fresnelStrength: 0.0,
          ),
          child: const _MiniPlayerContent(),
        ),
        bottomAccessoryHeight: 50.0,
        bottomAccessoryEnabled: !_searchFieldFocused,
        selectedIconColor: _kPodcastsPurple,
        unselectedIconColor: CupertinoColors.label.resolveFrom(context),
        indicatorColor: CupertinoTheme.brightnessOf(context) == Brightness.dark
            ? CupertinoColors.white.withValues(alpha: 0.15)
            : CupertinoColors.black.withValues(alpha: 0.10),
        labelFontSize: 10,
        iconSize: 28,
        iconLabelSpacing: 0,
        quality: GlassQuality.premium,
        interactionBehavior: GlassInteractionBehavior.full,
        settings: LiquidGlassSettings(
          glassColor: CupertinoTheme.brightnessOf(context) == Brightness.dark
              ? const Color(0xAA1C1C1E)
              : const Color(0xAAF2F2F7),
          thickness: 24,
          blur: 3,
          chromaticAberration: .01,
          lightAngle: GlassDefaults.lightAngle,
          lightIntensity: 0.2,
          ambientStrength: 0,
          refractiveIndex: 1.2,
          fresnelStrength: 0.0,
          saturation: 1.2,
          specularSharpness: GlassSpecularSharpness.medium,
        ),
        searchConfig: GlassSearchBarConfig(
          focusNode: _searchFocusNode,
          autoFocusOnExpand: false,
          showsCancelButton: true,
          expandWhenActive: !_isMiniMode || _isSearching,
          hintText: 'Search Podcasts',
          collapsedLogoBuilder: (context) {
            final isHome = _selectedTab == 0;
            IconData iconData = CupertinoIcons.play_circle_fill;
            if (_selectedTab == 1) {
              iconData = CupertinoIcons.square_grid_2x2_fill;
            } else if (_selectedTab == 2) {
              iconData = CupertinoIcons.square_stack_3d_up_fill;
            }
            return Center(
              child: Icon(
                iconData,
                color: isHome
                    ? _kPodcastsPurple
                    : CupertinoColors.label.resolveFrom(context),
                size: 28,
              ),
            );
          },
          onSearchToggle: (active) {
            if (active) {
              setState(() => _isSearching = true);
            } else {
              final wasSearching = _isSearching;
              setState(() {
                _isSearching = false;
                _searchFieldFocused = false;
              });
              if (!wasSearching && _isMiniMode) _dismissMiniMode();
            }
          },
          onSearchFocusChanged: (f) => setState(() => _searchFieldFocused = f),
          searchIconColor: CupertinoColors.label.resolveFrom(context),
          textInputAction: TextInputAction.search,
        ),
        tabs: [
          GlassTab(
              label: 'Home',
              icon: Icon(CupertinoIcons.play_circle),
              activeIcon: Icon(CupertinoIcons.play_circle_fill)),
          GlassTab(
              label: 'New',
              icon: Icon(CupertinoIcons.square_grid_2x2),
              activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill)),
          GlassTab(
              label: 'Library',
              icon: Icon(CupertinoIcons.square_stack_3d_up),
              activeIcon: Icon(CupertinoIcons.square_stack_3d_up_fill)),
        ],
      ),
    );
  }

  Widget _buildHomeView({Key? key, required double contentPad}) {
    return CustomScrollView(
      key: key,
      controller: _scrollController,
      slivers: [
        // Extra top pad to account for fixed header overlay
        SliverToBoxAdapter(
            child:
                SizedBox(height: MediaQuery.paddingOf(context).top + 12 + 50)),

        // ── Up Next ──────────────────────────────────────────────────────────
        _buildSectionHeader('Up Next'),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 330,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: _kPaddingH),
              itemCount: _kUpNext.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, i) => _UpNextCard(item: _kUpNext[i]),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Now with Video ───────────────────────────────────────────────────
        _buildSectionHeader('Now with Video'),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: _kPaddingH),
              itemCount: _kNowWithVideo.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, i) => _VideoCard(item: _kNowWithVideo[i]),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── You Might Like ───────────────────────────────────────────────────
        _buildSectionHeader('You Might Like'),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: _kPaddingH),
              itemCount: _kYouMightLike.length,
              separatorBuilder: (_, __) => SizedBox(width: 14),
              itemBuilder: (context, i) =>
                  _SmallPodcastCard(item: _kYouMightLike[i]),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Popular Shows ────────────────────────────────────────────────────
        _buildSectionHeader('Popular Shows'),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: _kPaddingH),
              itemCount: _kPopularShows.length,
              separatorBuilder: (_, __) => SizedBox(width: 14),
              itemBuilder: (context, i) =>
                  _SmallPodcastCard(item: _kPopularShows[i]),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Recently Played list ─────────────────────────────────────────────
        _buildSectionHeader('Recently Played'),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList.separated(
          itemCount: 4,
          separatorBuilder: (_, __) => Container(
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              height: 0.33,
              margin: const EdgeInsets.only(left: 76)),
          itemBuilder: (context, i) {
            final item = _kYouMightLike[i];
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: _kPaddingH, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.icon,
                        color: CupertinoColors.label.resolveFrom(context),
                        size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(item.author,
                            style: TextStyle(
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                                fontSize: 13)),
                        SizedBox(height: 6),
                        GlassProgressIndicator.linear(
                          value: 0.1 + i * 0.18,
                          height: 3,
                          color: _kPodcastsPurple,
                          backgroundColor: CupertinoColors.tertiaryLabel
                              .resolveFrom(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(CupertinoIcons.ellipsis,
                      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                      size: 20),
                ],
              ),
            );
          },
        ),

        SliverToBoxAdapter(child: SizedBox(height: contentPad)),
      ],
    );
  }

  Widget _buildHomeHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('Home',
                style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 34,
                    fontWeight: FontWeight.bold)),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kPodcastsPurple, width: 2),
              color: _kPodcastsPurple.withValues(alpha: 0.15),
            ),
            child: Icon(CupertinoIcons.person_fill,
                color: _kPodcastsPurple, size: 20),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _kPaddingH),
        child: Row(
          children: [
            Text(title,
                style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            SizedBox(width: 6),
            Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseView({Key? key, required double contentPad}) {
    return CustomScrollView(
      key: key,
      slivers: [
        SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).top + 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Search',
                style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 34,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, contentPad),
          sliver: SliverGrid.builder(
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5),
            itemBuilder: (context, i) => Container(
              decoration: BoxDecoration(
                  color: _kPalette[i % _kPalette.length],
                  borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(12),
              child: Text('Category ${i + 1}',
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearch({Key? key}) {
    final kHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      key: key,
      color: _kBackground.resolveFrom(context).resolveFrom(context),
      padding: EdgeInsets.only(bottom: kHeight + 50),
      child: Center(
        child: Text('No Recent Searches',
            style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─── Card Widgets ────────────────────────────────────────────────────────────

/// Shared artwork tile.
/// Uses locally cached cover art from assets using [itunesId] and shows it
/// full-bleed. Falls back to [_Fallback] on error.
class _PodcastArtwork extends StatelessWidget {
  const _PodcastArtwork({
    required this.item,
    required this.size,
    this.borderRadius = 14.0,
    this.child,
  });

  final _PodcastItem item;
  final double size;
  final double borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.itunesId == null)
              _Fallback(item: item, size: size)
            else
              Image.asset(
                'assets/podcast_images/${item.itunesId}.jpg',
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Fallback(item: item, size: size),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.item, required this.size});
  final _PodcastItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: item.color,
      child: Center(
          child: Icon(item.icon,
              size: size * 0.42,
              color: CupertinoColors.secondaryLabel.resolveFrom(context))),
    );
  }
}

/// Large vertical card used in the "Up Next" horizontal scroll strip.
class _UpNextCard extends StatelessWidget {
  const _UpNextCard({required this.item});
  final _PodcastItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: CupertinoColors.label
                .resolveFrom(context)
                .withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artwork top half
          _PodcastArtwork(
            item: item,
            size: 220,
            borderRadius: 0,
            child: Column(
              children: [
                const Spacer(),
                if (item.progress > 0)
                  GlassProgressIndicator.linear(
                    value: item.progress,
                    height: 3,
                    color: _kPodcastsPurple,
                    backgroundColor:
                        CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
              ],
            ),
          ),
          // Meta
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.play_fill,
                                size: 10,
                                color:
                                    CupertinoColors.label.resolveFrom(context)),
                            SizedBox(width: 4),
                            Text(item.duration,
                                style: TextStyle(
                                    color: CupertinoColors.label
                                        .resolveFrom(context),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(CupertinoIcons.ellipsis,
                          color: CupertinoColors.tertiaryLabel
                              .resolveFrom(context),
                          size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wide landscape card for the "Now with Video" section.
class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.item});
  final _PodcastItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: CupertinoColors.label
                .resolveFrom(context)
                .withValues(alpha: 0.08)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _PodcastArtwork(item: item, size: 240, borderRadius: 14),
          // darkening overlay for legibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x00000000),
                  CupertinoColors.black.withValues(alpha: 0.65)
                ],
              ),
            ),
          ),
          // Video badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: CupertinoColors.systemFill.resolveFrom(context),
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  Icon(CupertinoIcons.video_camera,
                      size: 11,
                      color: CupertinoColors.label.resolveFrom(context)),
                  SizedBox(width: 4),
                  Text('Video',
                      style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontSize: 10)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(item.author,
                      style: TextStyle(
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                          fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small square tile for "You Might Like" / "Popular Shows" rows.
class _SmallPodcastCard extends StatelessWidget {
  const _SmallPodcastCard({required this.item});
  final _PodcastItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PodcastArtwork(item: item, size: 108, borderRadius: 14),
          SizedBox(height: 6),
          Text(item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          Text(item.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 11)),
        ],
      ),
    );
  }
}

class _MiniPlayerContent extends StatelessWidget {
  const _MiniPlayerContent();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Hero(
            tag: 'now-playing-artwork',
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: _kPodcastsPurple,
                  borderRadius: BorderRadius.circular(6)),
              child: Icon(CupertinoIcons.mic,
                  color: CupertinoColors.label.resolveFrom(context), size: 18),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Daily',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text('The New York Times',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(CupertinoIcons.play_fill,
              color: CupertinoColors.label.resolveFrom(context), size: 24),
          SizedBox(width: 16),
          Icon(CupertinoIcons.goforward_30,
              color: CupertinoColors.label.resolveFrom(context), size: 22),
        ],
      ),
    );
  }
}

class NowPlayingView extends StatefulWidget {
  const NowPlayingView({super.key});
  @override
  State<NowPlayingView> createState() => _NowPlayingViewState();
}

class _NowPlayingViewState extends State<NowPlayingView> {
  double _progress = 0.3;
  double _volume = 0.7;
  int _speedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Hero(
            tag: 'now-playing-artwork',
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: _kPodcastsPurple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: _kPodcastsPurple.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Icon(CupertinoIcons.mic,
                  size: 100, color: CupertinoColors.label.resolveFrom(context)),
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('The Daily',
                        style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context),
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('The New York Times',
                        style:
                            TextStyle(color: _kPodcastsPurple, fontSize: 18)),
                  ],
                ),
              ),
              Icon(CupertinoIcons.ellipsis_circle,
                  color: CupertinoColors.label.resolveFrom(context), size: 28),
            ],
          ),
          SizedBox(height: 30),
          GlassSlider(
            value: _progress,
            onChanged: (v) => setState(() => _progress = v),
            activeColor: CupertinoColors.label.resolveFrom(context),
            inactiveColor: CupertinoColors.tertiaryLabel.resolveFrom(context),
            useOwnLayer: true,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15:30',
                  style: TextStyle(
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12)),
              Text('-34:10',
                  style: TextStyle(
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(CupertinoIcons.gobackward_15,
                  color: CupertinoColors.label.resolveFrom(context), size: 36),
              GlassButton(
                onTap: () {},
                useOwnLayer: true,
                shape: const LiquidRoundedRectangle(borderRadius: 40),
                settings: LiquidGlassSettings(
                    thickness: 20,
                    blur: 2,
                    glassColor:
                        CupertinoTheme.brightnessOf(context) == Brightness.dark
                            ? const Color(0x33FFFFFF)
                            : const Color(0x1A000000)),
                icon: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Icon(CupertinoIcons.play_fill,
                      color: CupertinoColors.label.resolveFrom(context),
                      size: 48),
                ),
              ),
              Icon(CupertinoIcons.goforward_30,
                  color: CupertinoColors.label.resolveFrom(context), size: 36),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Icon(CupertinoIcons.speaker_fill,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  size: 16),
              SizedBox(width: 12),
              Expanded(
                child: GlassSlider(
                  value: _volume,
                  onChanged: (v) => setState(() => _volume = v),
                  activeColor: CupertinoColors.label.resolveFrom(context),
                  useOwnLayer: true,
                  thumbRadius: 12,
                ),
              ),
              SizedBox(width: 12),
              Icon(CupertinoIcons.speaker_3_fill,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  size: 16),
            ],
          ),
          SizedBox(height: 30),
          GlassSegmentedControl(
            segments: [
              GlassSegment(label: '0.5x'),
              GlassSegment(label: '1x'),
              GlassSegment(label: '1.5x'),
              GlassSegment(label: '2x')
            ],
            selectedIndex: _speedIndex,
            onSegmentSelected: (i) => setState(() => _speedIndex = i),
            useOwnLayer: true,
          ),
        ],
      ),
    );
  }
}
