/// Apple Music iOS 26 — High-Fidelity Demo
///
/// Animation architecture:
///   • `GlassTabBar.searchable` uses `isSearchActive: _isMiniMode || _isSearching`
///     so the tabs spring-collapse whenever scrolled OR searching — matching the
///     iOS 26 morphing animation exactly.
///
///   • `bottomAccessory` handles the mini-player pill automatically:
///       - When expanded (`!_isMiniMode`), the accessory sits centered directly
///         above the navigation bar pill.
///       - When inline (`_isMiniMode`), the accessory slides down and right,
///         sandwiching itself exactly between the collapsed tab indicator and
///         the collapsed search capsule.
///
///     The entire transition is handled internally by a single unified
///     TweenAnimationBuilder, perfectly synchronizing height, position, and width
///     to match the iOS 26 `tabViewBottomAccessory(.inline)` behavior.
///
/// Run standalone:
///   flutter run -d macos -t lib/apple_music/apple_music_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const _kMusicRed = Color(0xFFFF2D55);
const _kBackground = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F2F7), darkColor: Color(0xFF000000));
const _kCardGray = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF), darkColor: Color(0xFF2C2C2E));

const _kBarH = 64.0;
const _kPaddingH = 20.0;
const _kPaddingV = 16.0;
const _kSpacing = 8.0;

/// Glass shared by every pill (play bar, home icon, search icon).
LiquidGlassSettings _kPillGlass(BuildContext context) => LiquidGlassSettings(
    glassColor: CupertinoTheme.of(context).brightness == Brightness.dark
        ? const Color(0xCC1C1C1E)
        : const Color(0xCCF2F2F7),
    thickness: 30,
    blur: 2,
    lightIntensity: 0.18,
    chromaticAberration: .01,
    saturation: 1.2,
    fresnelStrength: 0.0);

//  thickness: 30,
//     blur: 2,
//     chromaticAberration: .01,
//     lightAngle: GlassDefaults.lightAngle,
//     lightIntensity: 0.15,
//     ambientStrength: 0,
//     refractiveIndex: 1.2,
//     fresnelStrength: 1.0,
//     saturation: 1.2,
//     specularSharpness: GlassSpecularSharpness.medium,

// ─────────────────────────────────────────────────────────────────────────────
// APP
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    child: const AppleMusicDemoApp(),
    adaptiveQuality: true,
    // ignore: experimental_member_use
    adaptiveConfig: const GlassAdaptiveScopeConfig(
      // Left on intentionally for 0.9.1 — helps gather diagnostics
      // if the adaptive threshold fix doesn't hold on all hardware.
      debugLogDiagnostics: true,
    ),
  ));
}

class AppleMusicDemoApp extends StatelessWidget {
  const AppleMusicDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Apple Music',
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: const AppleMusicHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AppleMusicHomeScreen extends StatefulWidget {
  const AppleMusicHomeScreen({super.key});

  @override
  State<AppleMusicHomeScreen> createState() => _AppleMusicHomeScreenState();
}

class _AppleMusicHomeScreenState extends State<AppleMusicHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _radioScrollController = ScrollController();
  final ScrollController _libraryScrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isMiniMode = false;
  bool _isSearching = false;
  bool _searchFieldFocused = false;
  int _selectedTab = 0;

  static const _kTabs = [
    GlassTab(
      label: 'Home',
      icon: Icon(CupertinoIcons.house),
      activeIcon: Icon(CupertinoIcons.house_fill),
    ),
    GlassTab(
      label: 'Radio',
      icon: Icon(CupertinoIcons.antenna_radiowaves_left_right),
    ),
    GlassTab(
      label: 'Library',
      icon: Icon(CupertinoIcons.music_albums),
      activeIcon: Icon(CupertinoIcons.music_albums_fill),
    ),
  ];

  ScrollController get _activeScrollController => switch (_selectedTab) {
        1 => _radioScrollController,
        2 => _libraryScrollController,
        _ => _scrollController,
      };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _radioScrollController.addListener(_onScroll);
    _libraryScrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onScroll() {
    final ctrl = _activeScrollController;
    final mini = ctrl.hasClients && ctrl.offset > 50;
    if (mini == _isMiniMode) return;
    setState(() => _isMiniMode = mini);
  }

  void _onFocusChange() {
    setState(() => _searchFieldFocused = _searchFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _radioScrollController
      ..removeListener(_onScroll)
      ..dispose();
    _libraryScrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchFocusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  LiquidGlassSettings get _barGlassSettings => LiquidGlassSettings(
        glassColor: CupertinoTheme.of(context).brightness == Brightness.dark
            ? const Color(0xAA1C1C1E)
            : const Color(0xAAF2F2F7),
        thickness: 30,
        blur: 2,
        chromaticAberration: .01,
        lightAngle: GlassDefaults.lightAngle,
        lightIntensity: 0.2,
        ambientStrength: 0,
        refractiveIndex: 1.2,
        fresnelStrength: 0.0,
        saturation: 1.2,
        specularSharpness: GlassSpecularSharpness.medium,
      );

  // ── Public actions ────────────────────────────────────────────────────────

  /// Called when user taps the collapsed home-tab pill in mini mode.
  void _dismissMiniMode() {
    // Scroll whichever tab is currently active back to top.
    // Previously this hardcoded _scrollController (home tab), so tapping
    // Radio/Library in mini mode animated the wrong controller and _onScroll
    // never saw offset drop below 50 → mini mode stayed stuck.
    final ctrl = _activeScrollController;
    if (ctrl.hasClients) {
      ctrl.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
      );
    }
    setState(() {
      _isMiniMode =
          false; // reset immediately; _onScroll confirms on next frame
      _isSearching = false;
      _searchFieldFocused = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // iOS native design floats the pill over the home indicator (ignoring safe area).
    // Android 3-button nav requires us to clear the opaque system buttons.
    // On gesture-nav devices safeBottom is 0, so no offset is applied.
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final sysBottom = isIOS ? 0.0 : MediaQuery.viewPaddingOf(context).bottom;

    // Content bottom padding: bar (64) + vertical padding (16*2) + accessory (50)
    // + spacing (8) + extra clearance (8).
    final double contentPad =
        _kBarH + 2 * _kPaddingV + 50.0 + _kSpacing + 8.0 + sysBottom;

    return GlassScaffold(
      background: ColoredBox(color: _kBackground.resolveFrom(context)),
      settings: _kPillGlass(context),
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      topEdgeFade: true,
      bottomEdgeFade: true,
      topEdgeFadeExtent: 0, // no app bar — just status bar fade
      bottomEdgeFadeExtent: 0, // glass bar is transparent — no extra fade
      resizeToAvoidBottomInset: false,

      // ── Fixed header — fades on scroll (iOS large title pattern) ──────────
      header:
          (_selectedTab == 0 && !_isSearching) ? _buildListenNowHeader() : null,
      headerScrollController: _scrollController,
      headerFadeDistance: 30, // fast fade — matches real Apple Music

      // ── Body ────────────────────────────────────────────────────────────────
      body: GestureDetector(
        onTap: () {
          if (_searchFieldFocused) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: !_isSearching
              ? switch (_selectedTab) {
                  1 => _buildRadioView(
                      key: const ValueKey('radio'), contentPad: contentPad),
                  2 => _buildLibraryView(
                      key: const ValueKey('library'), contentPad: contentPad),
                  _ => _buildHomeView(
                      key: const ValueKey('home'), contentPad: contentPad),
                }
              : _searchFieldFocused
                  ? _buildNoRecentSearches(key: const ValueKey('no-recent'))
                  : _buildSearchBrowseView(
                      key: const ValueKey('search-browse'),
                      contentPad: contentPad),
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
            final ctrl = switch (index) {
              1 => _radioScrollController,
              2 => _libraryScrollController,
              _ => _scrollController,
            };
            final newMini = ctrl.hasClients && ctrl.offset > 50;
            setState(() {
              _selectedTab = index;
              _isSearching = false;
              _isMiniMode = newMini;
            });
          }
        },
        barHeight: _kBarH,
        searchBarHeight: 50.0,
        horizontalPadding: _kPaddingH,
        verticalPadding: _kPaddingV,
        spacing: _kSpacing,
        // ── tabViewBottomAccessory (iOS 26) ─────────────────────────────────
        // The play pill sits above the tab bar in expanded mode and animates
        // inline beside the collapsed search capsule in mini mode — matching
        // Apple's tabViewBottomAccessory(.inline) behaviour exactly.
        bottomAccessory: _PlayBarPill(onTap: _dismissMiniMode),
        bottomAccessoryHeight: 50.0,
        bottomAccessoryEnabled: !_searchFieldFocused,
        selectedIconColor: _kMusicRed,
        unselectedIconColor:
            CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.9),
        indicatorColor:
            CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.20),
        labelFontSize: 10,
        iconSize: 28,
        iconLabelSpacing: 0,
        quality: GlassQuality.premium,
        interactionBehavior: GlassInteractionBehavior.full,
        settings: _barGlassSettings,
        searchConfig: GlassSearchBarConfig(
          focusNode: _searchFocusNode,
          autoFocusOnExpand: false,
          showsCancelButton: true,
          expandWhenActive: !_isMiniMode || _isSearching,
          hintText: 'Apple Music',
          onSearchToggle: (active) {
            if (active) {
              setState(() => _isSearching = true);
            } else {
              setState(() {
                _isSearching = false;
                _searchFieldFocused = false;
              });
              if (_isMiniMode) _dismissMiniMode();
            }
          },
          onSearchFocusChanged: (focused) =>
              setState(() => _searchFieldFocused = focused),
          searchIconColor:
              CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.9),
          textInputAction: TextInputAction.search,
          collapsedLogoBuilder: (context) {
            final tab = _kTabs[_selectedTab];
            final iconColor = _isMiniMode && !_isSearching
                ? _kMusicRed
                : CupertinoColors.label
                    .resolveFrom(context)
                    .withValues(alpha: 0.9);
            final icon = tab.activeIcon ?? tab.icon;
            if (icon is Icon) {
              return Center(
                child: Icon(icon.icon, color: iconColor, size: 28),
              );
            }
            return icon ?? const SizedBox.shrink();
          },
        ),
        tabs: _kTabs,
      ),
    );
  }

  // ── Page views ────────────────────────────────────────────────────────────

  Widget _buildHomeView({Key? key, required double contentPad}) {
    return CustomScrollView(
      key: key,
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + 8 + 50),
        ),
        SliverToBoxAdapter(
          child: _HeroCard(
            title: 'Music just for you.\n2 months free.',
            subtitle: 'Accept Free Trial',
            subtext: '2 months free, then \$12.99/month',
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF83E4F), // Vibrant Apple Music pinkish-red
                Color(0xFFE2072C), // Deeper red at the bottom
              ],
            ),
            textColor: CupertinoColors.white,
            child: const _AppleMusicLogo(),
          ),
        ),
        SliverToBoxAdapter(
          child: _HeroCard(
            title: 'Music for the whole\nfamily. 2 months free.',
            subtitle: 'Accept Free Trial',
            subtext: '2 months free, then \$19.99/month',
            // gradient: const LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Color(0xFF2C2C2E), // dark charcoal top
            //     Color(0xFF1C1C1E), // near-black bottom
            //   ],
            // ),
            color: Color(0xFF1D1B1E),
            showBorder: true,
            textColor: CupertinoColors.white,
            child: Icon(
              CupertinoIcons.person_3_fill,
              color: _kMusicRed,
              size: 220,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: contentPad)),
      ],
    );
  }

  Widget _buildRadioView({Key? key, required double contentPad}) {
    final stations = [
      ('Apple Music 1', 'Global Pop', CupertinoIcons.dot_radiowaves_left_right),
      ('Apple Music Country', 'Country Hits', CupertinoIcons.music_note_2),
      ('Apple Music Hits', 'All-Time Favourites', CupertinoIcons.star_fill),
      ('Beats 1 Classics', 'Throwbacks', CupertinoIcons.clock_fill),
      ('Chill Mix', 'Lo-fi & Ambient', CupertinoIcons.moon_fill),
      ('Workout Mix', 'High Energy', CupertinoIcons.bolt_fill),
      ('Late Night', 'R&B & Soul', CupertinoIcons.moon_stars_fill),
      ('Discover', 'New Artists', CupertinoIcons.wand_stars),
    ];
    return CustomScrollView(
      key: key,
      controller: _radioScrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + 8),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 16, 20),
            child: Text(
              'Radio',
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, contentPad),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final s = stations[i % stations.length];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  height: 72,
                  decoration: BoxDecoration(
                    color: _kCardGray.resolveFrom(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _kMusicRed.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(14)),
                        ),
                        child: Icon(s.$3,
                            color: CupertinoColors.label.resolveFrom(context),
                            size: 28),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s.$1,
                                style: TextStyle(
                                    color: CupertinoColors.label
                                        .resolveFrom(context),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            Text(s.$2,
                                style: TextStyle(
                                    color: CupertinoColors.secondaryLabel
                                        .resolveFrom(context),
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: stations.length * 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryView({Key? key, required double contentPad}) {
    const sections = [
      'Recently Added',
      'Artists',
      'Albums',
      'Songs',
      'Playlists',
      'Music Videos',
      'Compilations',
      'Downloaded',
    ];
    return CustomScrollView(
      key: key,
      controller: _libraryScrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + 8),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 16, 8),
            child: Text(
              'Library',
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, contentPad),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.music_albums_fill,
                          color: _kMusicRed,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            sections[i % sections.length],
                            style: TextStyle(
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                                fontSize: 17),
                          ),
                        ),
                        Icon(CupertinoIcons.chevron_forward,
                            color: CupertinoColors.tertiaryLabel
                                .resolveFrom(context),
                            size: 16),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.33,
                    margin: const EdgeInsets.only(left: 56),
                    color: CupertinoColors.label
                        .resolveFrom(context)
                        .withValues(alpha: 0.1),
                  ),
                ],
              ),
              childCount: sections.length * 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListenNowHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Listen Now',
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFF4C4556),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'SD',
              style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBrowseView({Key? key, required double contentPad}) {
    return CustomScrollView(
      key: key,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + 8),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.star,
                        color: CupertinoColors.label.resolveFrom(context),
                        size: 22),
                    SizedBox(width: 4),
                    Text(
                      'Music',
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Search',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, contentPad),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _BrowseCategory(
                name: _kBrowseCategories[index].name,
                color: _kBrowseCategories[index].color,
              ),
              childCount: _kBrowseCategories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoRecentSearches({Key? key}) {
    final keyboardH = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      key: key,
      color: _kBackground.resolveFrom(context),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardH + 50),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.search,
                    size: 64,
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context)),
                SizedBox(height: 16),
                Text(
                  'No Recent Searches',
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your recent searches will appear here.',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 15,
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

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────

class _Category {
  const _Category({required this.name, required this.color});
  final String name;
  final Color color;
}

const _kBrowseCategories = [
  _Category(name: 'Pop', color: Color(0xFFFF2D55)),
  _Category(name: 'Hip-Hop', color: Color(0xFF5856D6)),
  _Category(name: 'Rock', color: Color(0xFF636366)),
  _Category(name: 'Electronic', color: Color(0xFF007AFF)),
  _Category(name: 'R&B / Soul', color: Color(0xFFAF52DE)),
  _Category(name: 'Country', color: Color(0xFFFF9500)),
  _Category(name: 'Jazz', color: Color(0xFF30B0C7)),
  _Category(name: 'Classical', color: Color(0xFF34C759)),
  _Category(name: 'Latin', color: Color(0xFFFF3B30)),
  _Category(name: 'Alternative', color: Color(0xFF1C1C1E)),
];

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Play bar pill — shared by the floating body pill and the mini NavBar pill.
class _PlayBarPill extends StatelessWidget {
  const _PlayBarPill({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap ?? () {},
      quality: GlassQuality.premium,
      useOwnLayer: true,
      width: double.infinity,
      height: _kBarH,
      shape: const LiquidRoundedRectangle(borderRadius: _kBarH / 2),
      settings: _kPillGlass(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Album art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB22222), Color(0xFF4A0000)],
                  ),
                ),
                child: Icon(CupertinoIcons.music_note,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    size: 20),
              ),
            ),
            SizedBox(width: 10),
            // Title + artist
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best of You',
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Foo Fighters',
                    style: TextStyle(
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.play_fill,
                color: CupertinoColors.label.resolveFrom(context), size: 24),
            SizedBox(width: 12),
            Icon(CupertinoIcons.forward_end_fill,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                size: 20),
            SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

class _AppleMusicLogo extends StatelessWidget {
  const _AppleMusicLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.star,
            color: CupertinoColors.label.resolveFrom(context), size: 56),
        Text(
          'Music',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 52,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String subtext;
  final Color? color;
  final Gradient? gradient;
  final Color? textColor;
  final Widget child;
  final bool showBorder;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.subtext,
    required this.child,
    this.color,
    this.gradient,
    this.textColor,
    this.showBorder = false,
  }) : assert(color != null || gradient != null, 'Provide color or gradient');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 400,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: showBorder
            ? Border.all(
                color: CupertinoColors.label
                    .resolveFrom(context)
                    .withValues(alpha: 0.15),
                width: 1.0,
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor ?? CupertinoColors.label.resolveFrom(context),
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Expanded(child: child),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor ?? CupertinoColors.label.resolveFrom(context),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              color: (textColor ?? CupertinoColors.label.resolveFrom(context))
                  .withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseCategory extends StatelessWidget {
  const _BrowseCategory({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: color,
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.all(12),
        child: Text(
          name,
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
