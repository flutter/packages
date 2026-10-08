/// GlassModalSheet showcase — demonstrates all sheet modes, peek geometry,
/// smart silence, and the Apple Maps-style floating sheet experience.
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_modal_sheet_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
      child: const ShowcaseApp(), adaptiveQuality: false));
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  GlassQuality _quality = GlassQuality.standard;

  void _setQuality(GlassQuality quality) {
    setState(() => _quality = quality);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Glass Showcase',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: CupertinoColors.activeBlue,
        ),
        child: child!,
      ),
      home: ShowcaseHomeScreen(
        onQualityChanged: _setQuality,
        currentQuality: _quality,
      ),
    );
  }
}

class ShowcaseHomeScreen extends StatefulWidget {
  final ValueChanged<GlassQuality> onQualityChanged;
  final GlassQuality currentQuality;

  const ShowcaseHomeScreen({
    super.key,
    required this.onQualityChanged,
    required this.currentQuality,
  });

  @override
  State<ShowcaseHomeScreen> createState() => _ShowcaseHomeScreenState();
}

class _ShowcaseHomeScreenState extends State<ShowcaseHomeScreen> {
  bool _isSearching = false;
  bool _searchFieldFocused = false;
  int _selectedTab = 0; // 0=Standard, 1=Peek, 2=Apple Maps

  @override
  Widget build(BuildContext context) {
    final sysBottom = MediaQuery.viewPaddingOf(context).bottom;
    return GlassScaffold(
      backgroundColor: CupertinoColors.black,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          if (_searchFieldFocused) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF000000), Color(0xFF1C1C1E)],
                  ),
                ),
              ),
            ),

            // Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomBar: Padding(
        padding: EdgeInsets.only(bottom: sysBottom > 25 ? sysBottom - 25 : 0),
        child: GlassTabBar.searchable(
          selectedIndex: _selectedTab,
          interactionBehavior: GlassInteractionBehavior.scaleOnly,
          isSearchActive: _isSearching,
          onTabSelected: (index) => setState(() {
            _selectedTab = index;
            _isSearching = false;
          }),
          selectedIconColor: CupertinoColors.activeBlue,
          unselectedIconColor: CupertinoColors.white.withValues(alpha: 0.60),
          quality: GlassQuality.premium,
          settings: const LiquidGlassSettings(
            glassColor: Color(0xAA1C1C1E),
            blur: 25,
          ),
          searchConfig: GlassSearchBarConfig(
            hintText: 'Search Scenarios',
            onSearchToggle: (active) => setState(() {
              _isSearching = active;
              if (!active) _searchFieldFocused = false;
            }),
            onSearchFocusChanged: (focused) =>
                setState(() => _searchFieldFocused = focused),
          ),
          tabs: [
            GlassTab(
              label: 'Standard',
              icon: Icon(CupertinoIcons.layers_alt),
              activeIcon: Icon(CupertinoIcons.layers_alt_fill),
            ),
            GlassTab(
              label: 'Peek',
              icon: Icon(CupertinoIcons.chevron_up_chevron_down),
            ),
            GlassTab(
              label: 'Apple Maps',
              icon: Icon(CupertinoIcons.map),
              activeIcon: Icon(CupertinoIcons.map_fill),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return _buildSearchState();
    }

    return Column(
      children: [
        SizedBox(height: MediaQuery.paddingOf(context).top + 12),
        _buildHeader(),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showcase',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _getTabName(),
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildQualityToggle(),
        ],
      ),
    );
  }

  String _getTabName() {
    switch (_selectedTab) {
      case 0:
        return 'Standard Modal';
      case 1:
        return 'Standard Peek';
      case 2:
        return 'Apple Maps Style';
      default:
        return '';
    }
  }

  Widget _buildQualityToggle() {
    final qualities = GlassQuality.values;
    final currentIndex = qualities.indexOf(widget.currentQuality);

    return SizedBox(
      width: 160,
      child: GlassSegmentedControl(
        segments: [
          GlassSegment(label: 'Standard'),
          GlassSegment(label: 'Premium'),
          GlassSegment(label: 'Minimal')
        ],
        selectedIndex: currentIndex >= 0 ? currentIndex : 1,
        onSegmentSelected: (index) {
          widget.onQualityChanged(qualities[index]);
        },
        useOwnLayer: true,
        height: 28,
        borderRadius: 8,
        selectedTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
        ),
        unselectedTextStyle: TextStyle(
          fontSize: 10,
          color: CupertinoColors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Scenario Tile
          _buildScenarioTile(
            title: _getTabName(),
            description: _getTabDescription(),
            icon: _getTabIconData(),
            onTap: () {
              switch (_selectedTab) {
                case 0:
                  _showStandardExperience(context);
                  break;
                case 1:
                  _showStandardPeek(context);
                  break;
                case 2:
                  _showMapsExperience(context);
                  break;
              }
            },
          ),
          SizedBox(height: 16),

          // Additional Scenarios for Standard Tab
          if (_selectedTab == 0) ...[
            _buildMorphTriggerTile(),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Static Modal',
              description: 'Disabled glow and window scaling',
              icon: CupertinoIcons.square,
              onTap: () => _showStaticModal(context),
              color: CupertinoColors.activeOrange,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Smart Silence',
              description: 'Ignore sheet feedback on child touch',
              icon: CupertinoIcons.speaker_slash,
              onTap: () => _showSmartSilence(context),
              color: CupertinoColors.systemPurple,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Gradual Transition',
              description: 'Smooth glass to color fade',
              icon: CupertinoIcons.circle,
              onTap: () => _showGradualTransition(context),
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Top Fade',
              description: 'Gradient fade at the top edge',
              icon: CupertinoIcons.chevron_up,
              onTap: () => _showTopFade(context),
              color: Colors.pink,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Transparent Barrier',
              description: 'No dimming behind the sheet',
              icon: CupertinoIcons.eye_slash,
              onTap: () => _showTransparentBarrier(context),
              color: Colors.indigo,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Solid Half State',
              description: 'Opaque brown in Half state',
              icon: CupertinoIcons.paintbrush,
              onTap: () => _showSolidHalfState(context),
              color: Colors.brown,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Dual Glass Setup',
              description: 'Different glass for Half vs Full',
              icon: CupertinoIcons.circle_lefthalf_fill,
              onTap: () => _showDualGlassSetup(context),
              color: Colors.cyan,
            ),
            SizedBox(height: 16),
            _buildScenarioTile(
              title: 'Custom Dimensions',
              description: 'Unique Peek/Half/Full sizes',
              icon: CupertinoIcons.pencil,
              onTap: () => _showCustomDimensions(context),
              color: CupertinoColors.activeOrange,
            ),
          ],

          // Peek Scenarios
          if (_selectedTab == 1) ...[
            _buildScenarioTile(
              title: 'Glass Card',
              description: 'Standalone GlassCard component demo',
              icon: CupertinoIcons.macwindow,
              onTap: () => _showGlassCard(context),
              color: CupertinoColors.activeGreen,
            ),
            SizedBox(height: 24),
            const GlassMenuLabel(title: 'MENU CONFIGURATIONS'),
            SizedBox(height: 12),
            Row(
              children: [
                // 1. Basic configuration (User's original)
                GlassMenu(
                  menuWidth: 240,
                  quality: widget.currentQuality,
                  settings: LiquidGlassSettings(
                    glassColor: const Color(0x00000000),
                    thickness: 30,
                    blur: 2,
                    chromaticAberration: .01,
                    lightAngle: GlassDefaults.lightAngle,
                    lightIntensity: .5,
                    ambientStrength: 0,
                    refractiveIndex: 1.2,
                    saturation: 1.2,
                  ),
                  enableInteractionGlow: true,
                  glowRadius: 0.6,
                  interactionScale: 1.00,
                  triggerBuilder: (context, toggleMenu) => GlassButton(
                    icon: Icon(CupertinoIcons.line_horizontal_3),
                    onTap: toggleMenu,
                  ),
                  items: [
                    GlassMenuItem(
                        title: 'Upgrade plan',
                        icon: Icon(CupertinoIcons.arrow_up_circle),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Settings',
                        icon: Icon(CupertinoIcons.settings),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Offline Pages',
                        icon: Icon(CupertinoIcons.arrow_down_circle),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Members',
                        icon: Icon(CupertinoIcons.person_2),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Trash',
                        icon: Icon(CupertinoIcons.trash),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Help & support',
                        icon: Icon(CupertinoIcons.question_circle),
                        onTap: () {}),
                  ],
                ),
                SizedBox(width: 16),

                // 2. Pro configuration (Advanced features)
                GlassMenu(
                  menuWidth: 260,
                  menuHeight: 250, // Test scrolling
                  quality: widget.currentQuality,
                  selectionColor:
                      CupertinoColors.activeBlue.withValues(alpha: 0.3),
                  triggerBuilder: (context, toggle) => GlassButton.custom(
                    onTap: toggle,
                    width: 56,
                    height: 56,
                    shape: const LiquidOval(),
                    child: Icon(CupertinoIcons.layers_alt,
                        color: CupertinoColors.white),
                  ),
                  items: [
                    const GlassMenuLabel(title: 'PRIMARY ACTIONS'),
                    GlassMenuItem(
                      title: 'New Project',
                      subtitle: 'Create from template',
                      icon: Icon(CupertinoIcons.add),
                      onTap: () {},
                    ),
                    GlassMenuItem(
                      title: 'Share Workspace',
                      icon: Icon(CupertinoIcons.share),
                      iconColor:
                          CupertinoColors.activeBlue, // Smart inheritance
                      onTap: () {},
                    ),
                    const GlassMenuDivider(),
                    const GlassMenuLabel(title: 'MANAGEMENT'),
                    GlassMenuItem(
                      title: 'Settings',
                      icon: Icon(CupertinoIcons.settings),
                      onTap: () {},
                    ),
                    const GlassMenuDivider(),
                    const GlassMenuLabel(title: 'DANGER ZONE'),
                    GlassMenuItem(
                      title: 'Delete Forever',
                      isDestructive: true,
                      icon: Icon(CupertinoIcons.trash),
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(width: 16),

                // 3. Photo configuration (Custom Widgets instead of Icons)
                GlassMenu(
                  menuWidth: 220,
                  quality: widget.currentQuality,
                  stretch: 0.0, // Disable liquid stretch physics
                  settings: LiquidGlassSettings(
                    glassColor: const Color(0x00000000),
                    thickness: 30,
                    blur: 2,
                    chromaticAberration: .01,
                    lightAngle: GlassDefaults.lightAngle,
                    lightIntensity: .5,
                    ambientStrength: 0,
                    refractiveIndex: 1.2,
                    saturation: 1.2,
                  ),
                  enableInteractionGlow: true,
                  glowRadius: 0.6,
                  interactionScale: 1.00,
                  triggerBuilder: (context, toggleMenu) => GlassButton(
                    icon: Icon(CupertinoIcons.camera),
                    onTap: toggleMenu,
                  ),
                  items: [
                    GlassMenuItem(
                        title: 'Alice',
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/100?img=1'),
                        ),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Bob',
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/100?img=2'),
                        ),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Charlie',
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/100?img=3'),
                        ),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Diana',
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/100?img=4'),
                        ),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Ethan',
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/100?img=5'),
                        ),
                        onTap: () {}),
                    GlassMenuItem(
                        title: 'Fiona',
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/100?img=9'),
                        ),
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ],

          // Apple Maps Style Tab
          if (_selectedTab == 2) ...[
            _buildScenarioTile(
              title: 'Maps Experience',
              description: 'Interactive map with floating sheet',
              icon: CupertinoIcons.map,
              onTap: () => _showMapsExperience(context),
              color: CupertinoColors.activeBlue,
            ),
          ],

          SizedBox(height: 120), // Padding for bottom bar
        ],
      ),
    );
  }

  /// The morph scenario: a compact trigger the sheet grows out of, rather than
  /// a row that opens one. The button itself is the thing that morphs, so it
  /// carries [_morphTriggerKey] and sits apart from the other scenario tiles.
  Widget _buildMorphTriggerTile() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Morph from trigger',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'The button empties, a glass droplet inflates into the sheet, '
                'and dismissing pours it back.',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.white.withValues(alpha: 0.54),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        // The wrapper owns the button's identity AND its opacity, so the
        // button can empty itself while the droplet stands in for it.
        GlassMorphTrigger(
          builder: (context, anchor) => GlassButton.custom(
            width: 64,
            height: 64,
            useOwnLayer: true,
            quality: GlassQuality.standard,
            shape: const LiquidRoundedSuperellipse(borderRadius: 32),
            onTap: () => _showMorphFromTrigger(context, anchor),
            child: Icon(
              CupertinoIcons.add,
              size: 28,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioTile({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color color = CupertinoColors.activeBlue,
  }) {
    return GlassButton.custom(
      width: double.infinity,
      height: 80,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      shape: const LiquidRoundedSuperellipse(borderRadius: 20),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.white.withValues(alpha: 0.54)),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey, size: 20),
          ],
        ),
      ),
    );
  }

  String _getTabDescription() {
    switch (_selectedTab) {
      case 0:
        return 'Standard interactive glass experience';
      case 1:
        return 'Starts as a small bar at the bottom';
      case 2:
        return 'Floating pill style like Apple Maps';
      default:
        return 'Explore glass effects';
    }
  }

  IconData _getTabIconData() {
    switch (_selectedTab) {
      case 0:
        return CupertinoIcons.layers_alt_fill;
      case 1:
        return CupertinoIcons.chevron_up_chevron_down;
      case 2:
        return CupertinoIcons.map_fill;
      default:
        return CupertinoIcons.play_fill;
    }
  }

  // ===========================================================================
  // Scenario Launch Methods (example2 pattern)
  // ===========================================================================

  void _showStandardExperience(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      builder: (context) => const BaseScenario(
        title: 'Standard Experience',
        subtitle:
            'Explore how interactive glass elements behave inside a glass sheet.',
      ),
    );
  }

  /// Presents the sheet by morphing it out of the "+" button, using the same
  /// Liquid Morph Engine that drives GlassMenu. Everything else — detents,
  /// drag, snap — behaves exactly as it does in the scenarios above; only the
  /// presentation changes.
  void _showMorphFromTrigger(BuildContext context, GlassMorphAnchor anchor) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      morphFrom: anchor,
      builder: (context) => const BaseScenario(
        title: 'Morph from trigger',
        subtitle:
            'Presented straight out of the button, the way iOS 26 morphs glass '
            'with glassEffectID. Tap outside to pour it back in.',
      ),
    );
  }

  void _showStandardPeek(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      initialState: GlassSheetState.peek,
      // Peek is a detent now — `small` alongside the two resting heights.
      detents: const {
        GlassSheetDetent.small,
        GlassSheetDetent.medium,
        GlassSheetDetent.large,
      },
      peekTopBorderRadius: 46,
      builder: (context) => const BaseScenario(
        title: 'Standard Peek',
        subtitle: 'A full-width persistent bar at the bottom.',
      ),
    );
  }

  void _showGlassCard(BuildContext context) {
    GlassSheet.show(
      context: context,
      quality: widget.currentQuality,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: GlassCard(
              useOwnLayer: true,
              padding: EdgeInsets.all(24),
              child: SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Glass Card',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Standalone GlassCard component demo.',
            style:
                TextStyle(color: CupertinoColors.white.withValues(alpha: 0.54)),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showStaticModal(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      interactionScale: 1.0,
      enableInteractionGlow: false,
      enableSaturationGlow: false,
      builder: (context) => const BaseScenario(
        title: 'Static Experience',
        subtitle:
            'This scenario has all tactile feedback disabled (no scaling, no glow).',
      ),
    );
  }

  void _showSmartSilence(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      suppressInteractionOnChildren: true,
      builder: (context) => const BaseScenario(
        title: 'Smart Silence',
        subtitle:
            'In this mode, children dispatch an InteractionNotification. The sheet stays stable.',
        silenceInteractions: true,
      ),
    );
  }

  void _showGradualTransition(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      fillTransition: GlassFillTransition.gradual,
      fillThreshold: 0.8,
      builder: (context) => const BaseScenario(
        title: 'Gradual Experience',
        subtitle:
            'Watch as the glass smoothly transitions into a solid color during expansion.',
      ),
    );
  }

  void _showTopFade(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      enableTopFade: true,
      builder: (context) => const BaseScenario(
        title: 'Top Fade Experience',
        subtitle:
            'A subtle gradient fade at the top of the sheet helps content blend smoothly.',
      ),
    );
  }

  void _showTransparentBarrier(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      barrierColor: const Color(0x00000000),
      builder: (context) => const BaseScenario(
        title: 'Transparent Barrier',
        subtitle:
            'The background remains fully visible and interactive without any dimming layer.',
      ),
    );
  }

  void _showSolidHalfState(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      halfSettings: const LiquidGlassSettings(
        glassColor: Colors.brown,
        blur: 0,
        refractiveIndex: 1.0,
        thickness: 0,
      ),
      builder: (context) => const BaseScenario(
        title: 'Solid Brown Half',
        subtitle:
            'Demonstrates overriding glass settings for a specific state (Half = Solid Brown).',
      ),
    );
  }

  void _showDualGlassSetup(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      halfSettings: const LiquidGlassSettings(thickness: 10, blur: 2),
      fullSettings: const LiquidGlassSettings(thickness: 40, blur: 15),
      builder: (context) => const BaseScenario(
        title: 'Dynamic Glass Morphing',
        subtitle:
            'The material itself changes during expansion: Half (Thin) → Full (Thick Frosted).',
      ),
    );
  }

  void _showCustomDimensions(BuildContext context) {
    GlassModalSheet.show(
      context: context,
      quality: widget.currentQuality,
      peekSize: 150,
      halfSize: 0.35,
      fullSize: 0.8,
      builder: (context) => const BaseScenario(
        title: 'Custom Layout',
        subtitle:
            'Peek is taller (150px), Half is lower (35%), and Full only reaches 80% height.',
      ),
    );
  }

  void _showMapsExperience(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MapsExperienceScreen(currentQuality: widget.currentQuality),
      ),
    );
  }

  Widget _buildSearchState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 64,
            color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
          ),
          SizedBox(height: 16),
          Text(
            'Search active',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class MapsExperienceScreen extends StatelessWidget {
  final GlassQuality currentQuality;

  const MapsExperienceScreen({super.key, required this.currentQuality});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: GlassModalSheetScaffold(
        mode: GlassSheetMode.persistent,
        detents: const {
          GlassSheetDetent.small,
          GlassSheetDetent.medium,
          GlassSheetDetent.large,
        },
        initialState: GlassSheetState.peek,
        peekSize: 90,
        halfSize: 0.445,
        horizontalMargin: 5,
        bottomMargin: 6,
        peekWidth: 340,
        peekHorizontalMargin: 20,
        peekBottomMargin: 32,
        peekTopBorderRadius: 28,
        peekBottomRadius: 28,
        topBorderRadius: 40,
        bottomBorderRadius: 54,
        fullTopBorderRadius: 36,
        fillTransition: GlassFillTransition.instant,
        halfSettings: LiquidGlassSettings(
          blur: 5,
          glassColor: CupertinoColors.systemGrey.withValues(alpha: 0.8),
        ),
        quality: currentQuality,
        body: Stack(
          children: [
            InteractiveViewer(
              maxScale: 5.0,
              minScale: 0.1,
              boundaryMargin: EdgeInsets.all(1000),
              child: Image.asset(
                'assets/modal_sheet_showcase/map_bg.png',
                fit: BoxFit.cover,
                width: 2000,
                height: 2000,
              ),
            ),
            // Floating Back Button
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      Icon(CupertinoIcons.back, color: CupertinoColors.black),
                ),
              ),
            ),
          ],
        ),
        sheet: BaseScenario(
          title: 'San Francisco',
          subtitle: 'Explore locations and transit in the bay area.',
        ),
      ),
    );
  }
}

// =============================================================================
// Scenario Widgets
// =============================================================================

/// A unified helper to build scenarios without boilerplate.
class BaseScenario extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool silenceInteractions;

  const BaseScenario({
    super.key,
    required this.title,
    required this.subtitle,
    this.silenceInteractions = false,
  });

  @override
  State<BaseScenario> createState() => _BaseScenarioState();
}

class _BaseScenarioState extends State<BaseScenario> {
  bool _switchValue = true;

  Widget _wrapIfSilenced({required Widget child}) {
    if (!widget.silenceInteractions) return child;
    return Listener(
      onPointerDown: (event) {
        InteractionNotification(event).dispatch(context);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollData = ScrollControllerProvider.of(context);

    return ListView.builder(
      controller: scrollData?.controller,
      physics: scrollData?.physics,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: 30,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 24, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                      fontSize: 15, color: CupertinoColors.systemGrey),
                ),
                SizedBox(height: 25),

                // INTERACTIVE SECTION
                Row(
                  children: [
                    Expanded(
                      child: _wrapIfSilenced(
                        child: GlassButton.custom(
                          height: 50,
                          useOwnLayer: false,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 14,
                          ),
                          onTap: () {},
                          child: Center(child: Text('Action A')),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _wrapIfSilenced(
                        child: GlassButton.custom(
                          height: 50,
                          useOwnLayer: false,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 14,
                          ),
                          onTap: () {},
                          child: Center(child: Text('Action B')),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    _wrapIfSilenced(
                      child: GlassSwitch(
                        value: _switchValue,
                        onChanged: (val) => setState(() => _switchValue = val),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Divider(height: 1),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: GlassCard(
            useOwnLayer: false,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(CupertinoIcons.star,
                      color: CupertinoColors.activeBlue),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item #$index',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Secondary information or description text goes here.',
                        style: TextStyle(
                            color: CupertinoColors.systemGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey),
              ],
            ),
          ),
        );
      },
    );
  }
}
