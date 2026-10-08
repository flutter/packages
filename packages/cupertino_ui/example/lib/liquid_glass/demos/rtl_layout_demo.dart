/// RTL Layout Demo
///
/// Visually demonstrates every widget that was updated in the RTL audit
/// (v0.28.0). Use the "Switch to RTL" button in the app bar to toggle
/// between LTR and RTL at runtime and verify that layout, drag physics,
/// and fill directions all mirror correctly.
///
/// Hero widgets covered:
///   - GlassTabBar.bottom   (tab ordering + jelly drag physics)
///   - GlassLargeTitle      (scale anchor + leading-edge collapse)
///   - GlassSegmentedControl (jelly indicator + drag direction)
///   - GlassSlider          (thumb position + active fill + drag)
///   - GlassProgressIndicator.linear (canvas fill direction)
///   - GlassAppBar          (title alignment)
///   - GlassSearchBar       (cancel gap)
///   - GlassDivider         (indent → leading edge)
///   - GlassGroupedSection  (header/footer edge)
///   - GlassListTile        (icon + chevron)
///
/// Run standalone:
///   flutter run -t lib/demos/rtl_layout_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../constants/glass_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(
    LiquidGlassWidgets.wrap(
      child: const CupertinoApp(
        theme: CupertinoThemeData(brightness: Brightness.dark),
        home: RtlLayoutDemo(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

// =============================================================================
// Root Widget
// =============================================================================

class RtlLayoutDemo extends StatefulWidget {
  const RtlLayoutDemo({super.key});

  @override
  State<RtlLayoutDemo> createState() => _RtlLayoutDemoState();
}

class _RtlLayoutDemoState extends State<RtlLayoutDemo> {
  TextDirection _dir = TextDirection.ltr;
  bool get _isRtl => _dir == TextDirection.rtl;

  double _sliderValue = 0.3;
  int _segmentIndex = 1;
  int _tabIndex = 0;
  double _progressValue = 0.65;

  final GlassLargeTitleController _titleController =
      GlassLargeTitleController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleDirection() {
    setState(() {
      _dir = _isRtl ? TextDirection.ltr : TextDirection.rtl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: _dir,
      child: GlassScaffold(
        background: const ShowcaseBackground(),
        settings: RecommendedGlassSettings.standard,
        topEdgeFade: true,
        appBar: GlassAppBar(
          title: Text(_isRtl ? 'تخطيط ي.م.' : 'RTL Layout Demo'),
          centerTitle: false,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Icon(CupertinoIcons.back),
          ),
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onPressed: _toggleDirection,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _isRtl ? 'LTR ←' : '→ RTL',
                  key: ValueKey(_isRtl),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _tabIndex,
          onTabSelected: (i) => setState(() => _tabIndex = i),
          tabs: const [
            GlassTab(
              label: 'Home',
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
            ),
            GlassTab(
              label: 'Search',
              icon: Icon(CupertinoIcons.search),
            ),
            GlassTab(
              label: 'Settings',
              icon: Icon(CupertinoIcons.settings),
              activeIcon: Icon(CupertinoIcons.settings_solid),
            ),
          ],
        ),
        body: CustomScrollView(
          controller: _titleController.scrollController,
          slivers: [
            // ------------------------------------------------------------------
            // Hero: GlassLargeTitle — scale anchor is AlignmentDirectional.bottomStart
            // In RTL the rubber-band overscroll stretches from the physical right.
            // ------------------------------------------------------------------
            SliverToBoxAdapter(
              child: SizedBox(height: topPad + 44),
            ),
            GlassLargeTitle(
              text: _isRtl ? 'تخطيط ي.م.' : 'RTL Widgets',
              controller: _titleController,
            ),

            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Direction badge
                      _DirectionBadge(isRtl: _isRtl),
                      const SizedBox(height: 24),

                      // --------------------------------------------------------
                      // Hero: GlassTabBar — note the order of tab labels in the
                      // bottom bar flips when you toggle RTL. Home moves to the
                      // physical right; Settings moves to the physical left.
                      // --------------------------------------------------------
                      _SectionHeader(
                        title: 'GlassTabBar.bottom',
                        subtitle:
                            'Tab order reverses · Jelly physics stay correct',
                        icon: CupertinoIcons.square_grid_2x2,
                      ),
                      _DemoCard(
                        child: Text(
                          _isRtl
                              ? '← Tap "Settings" (physical left) → reports index 2\n'
                                  '← Tap "Home" (physical right) → reports index 0'
                              : '"Home" is on the left → index 0\n'
                                  '"Settings" is on the right → index 2',
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --------------------------------------------------------
                      // Hero: GlassSegmentedControl
                      // --------------------------------------------------------
                      _SectionHeader(
                        title: 'GlassSegmentedControl',
                        subtitle:
                            'Drag direction + jelly indicator mirrors in RTL',
                        icon: CupertinoIcons.rectangle_split_3x1,
                      ),
                      GlassSegmentedControl(
                        selectedIndex: _segmentIndex,
                        onSegmentSelected: (i) =>
                            setState(() => _segmentIndex = i),
                        segments: _isRtl
                            ? const [
                                GlassSegment(label: 'شهر'),
                                GlassSegment(label: 'أسبوع'),
                                GlassSegment(label: 'يوم'),
                              ]
                            : const [
                                GlassSegment(label: 'Day'),
                                GlassSegment(label: 'Week'),
                                GlassSegment(label: 'Month'),
                              ],
                      ),

                      const SizedBox(height: 28),

                      // --------------------------------------------------------
                      // Hero: GlassSlider — drag physics + fill + thumb mirror
                      // --------------------------------------------------------
                      _SectionHeader(
                        title: 'GlassSlider',
                        subtitle:
                            'Drag left = increase in RTL · Track fill mirrors',
                        icon: CupertinoIcons.slider_horizontal_3,
                      ),
                      GlassSlider(
                        value: _sliderValue,
                        onChanged: (v) => setState(() => _sliderValue = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Value: ${(_sliderValue * 100).round()}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --------------------------------------------------------
                      // Hero: GlassProgressIndicator.linear — canvas fill direction
                      // --------------------------------------------------------
                      _SectionHeader(
                        title: 'GlassProgressIndicator.linear',
                        subtitle:
                            'Fill starts from physical right (logical start) in RTL',
                        icon: CupertinoIcons.chart_bar_fill,
                      ),
                      _DemoCard(
                        child: Column(
                          children: [
                            GlassProgressIndicator.linear(
                              value: _progressValue,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Indeterminate:',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const GlassProgressIndicator.linear(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => setState(
                                    () => _progressValue =
                                        (_progressValue - 0.1).clamp(0.0, 1.0),
                                  ),
                                  child:
                                      const Icon(CupertinoIcons.minus_circle),
                                ),
                                Text(
                                  '${(_progressValue * 100).round()}%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => setState(
                                    () => _progressValue =
                                        (_progressValue + 0.1).clamp(0.0, 1.0),
                                  ),
                                  child: const Icon(CupertinoIcons.plus_circle),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --------------------------------------------------------
                      // GlassSearchBar — cancel gap mirrors
                      // --------------------------------------------------------
                      _SectionHeader(
                        title: 'GlassSearchBar',
                        subtitle:
                            'Cancel button gap uses EdgeInsetsDirectional',
                        icon: CupertinoIcons.search,
                      ),
                      GlassSearchBar(
                        placeholder: _isRtl ? 'بحث...' : 'Search items...',
                      ),

                      const SizedBox(height: 28),

                      // --------------------------------------------------------
                      // GlassDivider + GlassGroupedSection + GlassListTile
                      // --------------------------------------------------------
                      _SectionHeader(
                        title: 'GlassDivider (indent: 56)',
                        subtitle:
                            'Leading indent always on the logical leading side',
                        icon: CupertinoIcons.minus,
                      ),
                      const GlassDivider(indent: 56),

                      const SizedBox(height: 28),

                      _SectionHeader(
                        title: 'GlassGroupedSection',
                        subtitle:
                            'Header / footer + tile chevrons mirror in RTL',
                        icon: CupertinoIcons.list_bullet,
                      ),
                      GlassGroupedSection(
                        header:
                            Text(_isRtl ? 'قسم الإعدادات' : 'Settings Section'),
                        footer: Text(
                          _isRtl
                              ? 'نص التذييل يتوافق مع الحافة البادئة'
                              : 'Footer text aligns to the logical leading edge.',
                        ),
                        children: [
                          GlassListTile(
                            leading: const Icon(CupertinoIcons.person_fill),
                            title: Text(_isRtl ? 'الحساب' : 'Account'),
                            trailing:
                                const Icon(CupertinoIcons.chevron_forward),
                            onTap: () {},
                          ),
                          GlassListTile(
                            leading: const Icon(CupertinoIcons.bell_fill),
                            title: Text(_isRtl ? 'الإشعارات' : 'Notifications'),
                            trailing:
                                const Icon(CupertinoIcons.chevron_forward),
                            onTap: () {},
                          ),
                          GlassListTile(
                            leading: const Icon(CupertinoIcons.lock_fill),
                            title: Text(_isRtl ? 'الخصوصية' : 'Privacy'),
                            trailing:
                                const Icon(CupertinoIcons.chevron_forward),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Supporting widgets
// =============================================================================

/// Pill badge showing the current text direction.
class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({required this.isRtl});
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isRtl
            ? const Color(0xFF9333EA).withValues(alpha: 0.25)
            : const Color(0xFF1E3A8A).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRtl
              ? const Color(0xFF9333EA).withValues(alpha: 0.6)
              : const Color(0xFF3B82F6).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRtl ? CupertinoIcons.arrow_left : CupertinoIcons.arrow_right,
            size: 14,
            color: isRtl ? const Color(0xFFC084FC) : const Color(0xFF60A5FA),
          ),
          const SizedBox(width: 8),
          Text(
            isRtl
                ? 'Active: RTL (Right-to-Left) — Arabic / Hebrew mode'
                : 'Active: LTR (Left-to-Right) — Default mode',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isRtl ? const Color(0xFFC084FC) : const Color(0xFF60A5FA),
            ),
          ),
        ],
      ),
    );
  }
}

/// Consistent section header matching the rest of the example app.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: CupertinoColors.systemBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
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

/// Glass-tinted card container used for grouped content.
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }
}
