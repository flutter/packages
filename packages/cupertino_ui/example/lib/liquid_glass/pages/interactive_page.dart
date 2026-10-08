import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

class InteractivePage extends StatefulWidget {
  const InteractivePage({super.key});

  @override
  State<InteractivePage> createState() => _InteractivePageState();
}

class _InteractivePageState extends State<InteractivePage> {
  // Switch state
  bool _switch1 = false;
  bool _switch2 = true;
  bool _switch3 = false;

  // Segmented control state
  int _segment1 = 0;
  int _segment2 = 1;
  int _verticalSegment = 0;

  // Slider state
  double _slider1 = 0.5;
  double _slider2 = 0.7;

  // Chip state
  final Set<String> _selectedFilters = {'Flutter', 'iOS'};

  // Page control state
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      child: GlassScaffold(
        backgroundColor: const Color(0x00000000),
        appBar: const GlassAppBar.pinned(),
        body: GlassScrollEdgeEffect(
          topFadeHeight: MediaQuery.paddingOf(context).top + 44 + 40,
          fadeBottom: false,
          fadeColor: const Color(0xFF020715),
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
                    'Interactive',
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
                      // ── GlassButton ──────────────────────────────────────
                      const _SectionTitle(title: 'GlassButton'),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton.custom(
                              shape: const LiquidRoundedRectangle(
                                  borderRadius: 28),
                              onTap: () {},
                              width: double.infinity,
                              height: 56,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.arrow_down_circle_fill,
                                      color: CupertinoColors.label
                                          .resolveFrom(context),
                                      size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Download',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassButton(
                            icon: Icon(CupertinoIcons.heart),
                            onTap: () {},
                            label: 'Favorite',
                            glowColor: CupertinoColors.systemRed
                                .withValues(alpha: 0.3),
                          ),
                          GlassButton(
                            icon: Icon(CupertinoIcons.star),
                            onTap: () {},
                            label: 'Star',
                            glowColor: CupertinoColors.activeOrange
                                .withValues(alpha: 0.3),
                          ),
                          GlassButton(
                            icon: Icon(CupertinoIcons.share),
                            onTap: () {},
                            label: 'Share',
                            glowColor: CupertinoColors.activeBlue
                                .withValues(alpha: 0.3),
                          ),
                          GlassButton(
                            icon: Icon(CupertinoIcons.bookmark),
                            onTap: () {},
                            label: 'Save',
                            glowColor: CupertinoColors.activeGreen
                                .withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Shapes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassButton(
                            icon: Icon(CupertinoIcons.play_fill),
                            onTap: () {},
                            shape: const LiquidOval(),
                            glowColor: CupertinoColors.systemPurple
                                .withValues(alpha: 0.3),
                          ),
                          GlassButton(
                            icon: Icon(CupertinoIcons.pause_fill),
                            onTap: () {},
                            shape:
                                const LiquidRoundedRectangle(borderRadius: 16),
                            glowColor: CupertinoColors.activeBlue
                                .withValues(alpha: 0.3),
                          ),
                          GlassButton(
                            icon: Icon(CupertinoIcons.stop_fill),
                            onTap: () {},
                            shape: const LiquidRoundedSuperellipse(
                                borderRadius: 16),
                            glowColor: CupertinoColors.systemRed
                                .withValues(alpha: 0.3),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Prominent style
                      Text(
                        'GlassButtonStyle.prominent — primary CTA',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton.custom(
                              shape: const LiquidRoundedRectangle(
                                  borderRadius: 26),
                              style: GlassButtonStyle.prominent,
                              onTap: () {},
                              height: 52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.plus_circle_fill,
                                      color: CupertinoColors.label
                                          .resolveFrom(context),
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add to Library',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassButton(
                            style: GlassButtonStyle.prominent,
                            icon: Icon(CupertinoIcons.cart_fill),
                            onTap: () {},
                            label: 'Buy',
                          ),
                          GlassButton(
                            style: GlassButtonStyle.filled,
                            icon: Icon(CupertinoIcons.cart),
                            onTap: () {},
                            label: 'Browse',
                          ),
                          GlassButton(
                            style: GlassButtonStyle.transparent,
                            icon: Icon(CupertinoIcons.info),
                            onTap: () {},
                            label: 'Info',
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── GlassIconButton ──────────────────────────────────
                      const _SectionTitle(title: 'GlassIconButton'),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          GlassIconButton(
                            icon: Icon(CupertinoIcons.heart),
                            onPressed: () {},
                            glowColor: CupertinoColors.systemRed
                                .withValues(alpha: 0.3),
                          ),
                          GlassIconButton(
                            icon: Icon(CupertinoIcons.star),
                            onPressed: () {},
                            glowColor: Colors.yellow.withValues(alpha: 0.3),
                          ),
                          GlassIconButton(
                            icon: Icon(CupertinoIcons.bell),
                            onPressed: () {},
                            glowColor: CupertinoColors.activeBlue
                                .withValues(alpha: 0.3),
                          ),
                          GlassIconButton(
                            icon: Icon(CupertinoIcons.share),
                            onPressed: () {},
                            shape: GlassIconButtonShape.roundedSquare,
                            glowColor: CupertinoColors.activeGreen
                                .withValues(alpha: 0.3),
                          ),
                          GlassIconButton(
                            icon: Icon(CupertinoIcons.settings),
                            onPressed: () {},
                            shape: GlassIconButtonShape.roundedSquare,
                            glowColor: CupertinoColors.systemPurple
                                .withValues(alpha: 0.3),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── GlassSegmentedControl ────────────────────────────
                      const _SectionTitle(title: 'GlassSegmentedControl'),
                      SizedBox(height: 4),
                      _QualityLabel(label: 'Premium vs Standard'),
                      SizedBox(height: 16),
                      _QualityRow(
                        premiumLabel: 'Premium',
                        standardLabel: 'Standard',
                      ),
                      SizedBox(height: 12),
                      GlassSegmentedControl(
                        segments: [
                          GlassSegment(label: 'Daily'),
                          GlassSegment(label: 'Weekly'),
                          GlassSegment(label: 'Monthly')
                        ],
                        selectedIndex: _segment1,
                        onSegmentSelected: (i) => setState(() => _segment1 = i),
                        quality: GlassQuality.premium,
                      ),
                      SizedBox(height: 12),
                      GlassSegmentedControl(
                        segments: [
                          GlassSegment(label: 'Daily'),
                          GlassSegment(label: 'Weekly'),
                          GlassSegment(label: 'Monthly')
                        ],
                        selectedIndex: _segment1,
                        onSegmentSelected: (i) => setState(() => _segment1 = i),
                      ),
                      SizedBox(height: 24),
                      GlassSegmentedControl(
                        segments: [
                          GlassSegment(label: 'XS'),
                          GlassSegment(label: 'S'),
                          GlassSegment(label: 'M'),
                          GlassSegment(label: 'L'),
                          GlassSegment(label: 'XL')
                        ],
                        selectedIndex: _segment2,
                        onSegmentSelected: (i) => setState(() => _segment2 = i),
                        height: 28,
                        borderRadius: 14,
                      ),
                      SizedBox(height: 24),
                      _QualityLabel(label: 'Vertical — tap or drag'),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GlassSegmentedControl(
                            direction: Axis.vertical,
                            height: 52,
                            segmentExtent: 56,
                            segments: const [
                              GlassSegment(
                                icon: Icon(CupertinoIcons.square_grid_2x2),
                                semanticLabel: 'Canvas',
                              ),
                              GlassSegment(
                                icon: Icon(CupertinoIcons.circle_grid_hex),
                                semanticLabel: 'Flow',
                              ),
                              GlassSegment(
                                icon: Icon(CupertinoIcons.layers_alt),
                                semanticLabel: 'Deep Dive',
                              ),
                            ],
                            selectedIndex: _verticalSegment,
                            onSegmentSelected: (i) =>
                                setState(() => _verticalSegment = i),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  const [
                                    'Canvas',
                                    'Flow',
                                    'Deep Dive'
                                  ][_verticalSegment],
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.label
                                        .resolveFrom(context),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'The indicator, jelly motion, drag physics, '
                                  'and icon state all follow the vertical axis.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: CupertinoColors.secondaryLabel
                                        .resolveFrom(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── GlassSwitch ──────────────────────────────────────
                      const _SectionTitle(title: 'GlassSwitch'),
                      SizedBox(height: 4),
                      _QualityLabel(label: 'Premium vs Standard'),
                      SizedBox(height: 16),
                      _SwitchComparisonRow(
                        title: 'Notifications',
                        value: _switch1,
                        onChanged: (v) => setState(() => _switch1 = v),
                      ),
                      Divider(
                          color: CupertinoColors.white.withValues(alpha: 0.12),
                          height: 32),
                      _SwitchComparisonRow(
                        title: 'Dark Mode',
                        value: _switch2,
                        onChanged: (v) => setState(() => _switch2 = v),
                      ),
                      Divider(
                          color: CupertinoColors.white.withValues(alpha: 0.12),
                          height: 32),
                      _SwitchComparisonRow(
                        title: 'Location',
                        value: _switch3,
                        onChanged: (v) => setState(() => _switch3 = v),
                      ),

                      SizedBox(height: 40),

                      // ── GlassSlider ──────────────────────────────────────
                      const _SectionTitle(title: 'GlassSlider'),
                      SizedBox(height: 4),
                      _QualityLabel(label: 'Premium vs Standard'),
                      SizedBox(height: 16),
                      _QualityRow(
                        premiumLabel: 'Premium',
                        standardLabel: '',
                      ),
                      SizedBox(height: 8),
                      GlassSlider(
                        value: _slider1,
                        onChanged: (v) => setState(() => _slider1 = v),
                        quality: GlassQuality.premium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(_slider1 * 100).round()}%',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 20),
                      _QualityRow(
                        premiumLabel: '',
                        standardLabel: 'Standard',
                      ),
                      SizedBox(height: 8),
                      GlassSlider(
                        value: _slider1,
                        onChanged: (v) => setState(() => _slider1 = v),
                      ),
                      SizedBox(height: 24),
                      GlassSlider(
                        value: _slider2,
                        onChanged: (v) => setState(() => _slider2 = v),
                        activeColor: CupertinoColors.activeBlue,
                        thumbColor:
                            CupertinoColors.activeBlue.withValues(alpha: 0.3),
                      ),

                      SizedBox(height: 40),

                      // ── GlassButtonGroup ─────────────────────────────────
                      const _SectionTitle(title: 'GlassButtonGroup'),
                      SizedBox(height: 4),
                      Text(
                        'With dividers (children mode)',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: GlassButtonGroup(
                          children: [
                            GlassButton(
                              icon: Icon(CupertinoIcons.bold),
                              style: GlassButtonStyle.transparent,
                              onTap: () {},
                            ),
                            GlassButton(
                              icon: Icon(CupertinoIcons.italic),
                              style: GlassButtonStyle.transparent,
                              onTap: () {},
                            ),
                            GlassButton(
                              icon: Icon(CupertinoIcons.underline),
                              style: GlassButtonStyle.transparent,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Lightweight items (.icons constructor)',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassButtonGroup.icons(
                            useOwnLayer: true,
                            items: [
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.text_alignleft),
                                onTap: () {},
                              ),
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.trash),
                                onTap: () {},
                              ),
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.add),
                                onTap: () {},
                              ),
                            ],
                          ),
                          GlassButton(
                            icon: Icon(CupertinoIcons.square_pencil),
                            useOwnLayer: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: GlassButtonGroup.icons(
                          useOwnLayer: true,
                          items: [
                            GlassButtonGroupItem(
                              icon: Icon(CupertinoIcons.arrow_uturn_left),
                              onTap: () {},
                            ),
                            GlassButtonGroupItem(
                              icon: Icon(CupertinoIcons.arrow_uturn_right),
                              onTap: () {},
                            ),
                            GlassButtonGroupItem(
                              icon: Icon(CupertinoIcons.pencil_outline),
                              onTap: () {},
                            ),
                            GlassButtonGroupItem(
                              icon: Icon(CupertinoIcons.ellipsis),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      // ── GlassPullDownButton ──────────────────────────────
                      const _SectionTitle(title: 'GlassPullDownButton'),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassPullDownButton(
                            icon: Icon(CupertinoIcons.ellipsis_circle),
                            items: [
                              GlassMenuItem(
                                title: 'Copy',
                                icon: Icon(CupertinoIcons.doc_on_doc),
                                onTap: () {},
                              ),
                              GlassMenuItem(
                                title: 'Share',
                                icon: Icon(CupertinoIcons.share),
                                onTap: () {},
                              ),
                              GlassMenuItem(
                                title: 'Delete',
                                icon: Icon(CupertinoIcons.trash),
                                isDestructive: true,
                                onTap: () {},
                              ),
                            ],
                          ),
                          GlassPullDownButton(
                            label: 'Sort By',
                            icon: Icon(CupertinoIcons.arrow_up_arrow_down),
                            buttonWidth: 120,
                            buttonShape:
                                const LiquidRoundedRectangle(borderRadius: 22),
                            items: [
                              GlassMenuItem(
                                title: 'Name',
                                onTap: () {},
                                trailing: Icon(CupertinoIcons.checkmark_alt,
                                    size: 16,
                                    color: CupertinoColors.label
                                        .resolveFrom(context)),
                              ),
                              GlassMenuItem(title: 'Date', onTap: () {}),
                              GlassMenuItem(title: 'Size', onTap: () {}),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── GlassButtonGroup ─────────────────────────────────
                      const _SectionTitle(title: 'GlassButtonGroup'),
                      SizedBox(height: 16),

                      // Simple icons mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassButtonGroup.icons(
                            items: [
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.bold),
                                label: 'Bold',
                                onTap: () {},
                              ),
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.italic),
                                label: 'Italic',
                                onTap: () {},
                              ),
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.underline),
                                label: 'Underline',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Pattern A: GlassButtonGroupItem.menu
                      // All actions share one pill. The pill stays visible under the
                      // expanded menu (the slot fades, not the whole shell). Best when
                      // the menu action is conceptually part of the group.
                      const _SubSectionLabel(
                        label: '.menu item — shared pill',
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassButtonGroup.icons(
                            items: [
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.chart_bar),
                                label: 'Chart',
                                onTap: () {},
                              ),
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.clock),
                                label: 'History',
                                onTap: () {},
                              ),
                              GlassButtonGroupItem.menu(
                                icon: Icon(CupertinoIcons.ellipsis),
                                label: 'More',
                                menuAlignment: GlassMenuAlignment.topRight,
                                menuItems: [
                                  GlassMenuItem(
                                    title: 'Add to Watchlist',
                                    icon: Icon(CupertinoIcons.star),
                                    onTap: () {},
                                  ),
                                  GlassMenuItem(
                                    title: 'Share',
                                    icon: Icon(CupertinoIcons.share),
                                    onTap: () {},
                                  ),
                                  GlassMenuDivider(),
                                  GlassMenuItem(
                                    title: 'Remove',
                                    icon: Icon(CupertinoIcons.trash),
                                    isDestructive: true,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Pattern B: GlassButtonGroup + GlassPullDownButton side-by-side
                      // The trailing button morphs fully — no pill residue under the menu.
                      const _SubSectionLabel(
                        label: 'group + standalone menu',
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassButtonGroup.icons(
                            items: [
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.chart_bar),
                                label: 'Chart',
                                onTap: () {},
                              ),
                              GlassButtonGroupItem(
                                icon: Icon(CupertinoIcons.clock),
                                label: 'History',
                                onTap: () {},
                              ),
                            ],
                          ),
                          SizedBox(width: 8),
                          GlassPullDownButton(
                            icon: Icon(CupertinoIcons.ellipsis),
                            menuAlignment: GlassMenuAlignment.topRight,
                            items: [
                              GlassMenuItem(
                                title: 'Add to Watchlist',
                                icon: Icon(CupertinoIcons.star),
                                onTap: () {},
                              ),
                              GlassMenuItem(
                                title: 'Share',
                                icon: Icon(CupertinoIcons.share),
                                onTap: () {},
                              ),
                              GlassMenuDivider(),
                              GlassMenuItem(
                                title: 'Remove',
                                icon: Icon(CupertinoIcons.trash),
                                isDestructive: true,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── GlassBadge ───────────────────────────────────────
                      const _SectionTitle(title: 'GlassBadge'),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          GlassBadge(
                            count: 5,
                            child: GlassButton(
                              icon: Icon(CupertinoIcons.bell),
                              onTap: () {},
                              width: 48,
                              height: 48,
                            ),
                          ),
                          GlassBadge(
                            count: 12,
                            child: GlassButton(
                              icon: Icon(CupertinoIcons.envelope),
                              onTap: () {},
                              width: 48,
                              height: 48,
                            ),
                          ),
                          GlassBadge(
                            count: 99,
                            child: GlassButton(
                              icon: Icon(CupertinoIcons.chat_bubble),
                              onTap: () {},
                              width: 48,
                              height: 48,
                            ),
                          ),
                          GlassBadge.dot(
                            dotColor: CupertinoColors.activeGreen,
                            child: GlassButton(
                              icon: Icon(CupertinoIcons.person),
                              onTap: () {},
                              width: 48,
                              height: 48,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── GlassChip ────────────────────────────────────────
                      const _SectionTitle(title: 'GlassChip'),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          GlassChip(
                            label: 'Favorite',
                            icon: Icon(CupertinoIcons.heart_fill),
                            iconColor: Colors.pink,
                            onTap: () {},
                          ),
                          GlassChip(
                            label: 'Share',
                            icon: Icon(CupertinoIcons.share),
                            onTap: () {},
                          ),
                          GlassChip(
                            label: 'Star',
                            icon: Icon(CupertinoIcons.star_fill),
                            iconColor: Colors.yellow,
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ['Flutter', 'Dart', 'iOS', 'Android'].map((filter) {
                          final isSelected = _selectedFilters.contains(filter);
                          return GlassChip(
                            label: filter,
                            selected: isSelected,
                            selectedColor: CupertinoColors.activeBlue
                                .withValues(alpha: 0.4),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFilters.remove(filter);
                                } else {
                                  _selectedFilters.add(filter);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 40),

                      // ── GlassPageControl ──────────────────────────────
                      const _SectionTitle(title: 'GlassPageControl'),
                      SizedBox(height: 8),
                      Text(
                        'Glass capsule with dot indicators — iOS 26 style',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: GlassPageControl(
                          count: 7,
                          currentPage: _currentPage,
                          onPageChanged: (page) =>
                              setState(() => _currentPage = page),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Page ${_currentPage + 1} of 7',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.label
                                .resolveFrom(context)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Weather-style bottom bar layout
                      Text(
                        'Weather-style bottom bar',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          // Map button (left)
                          GlassButton(
                            icon: Icon(CupertinoIcons.map),
                            onTap: () {},
                          ),
                          SizedBox(width: 8),
                          // Page control (center, fills remaining space)
                          Expanded(
                            child: GlassPageControl(
                              count: 7,
                              currentPage: _currentPage,
                              leadingIcon: Icon(
                                CupertinoIcons.location_fill,
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                                size: 10,
                              ),
                              onPageChanged: (page) =>
                                  setState(() => _currentPage = page),
                            ),
                          ),
                          SizedBox(width: 8),
                          // List button (right)
                          GlassButton(
                            icon: Icon(CupertinoIcons.list_bullet),
                            onTap: () {},
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
// Helper Widgets
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

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color:
            CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.45),
      ),
    );
  }
}

class _QualityLabel extends StatelessWidget {
  const _QualityLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color:
            CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.5),
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({
    required this.premiumLabel,
    required this.standardLabel,
  });
  final String premiumLabel;
  final String standardLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (premiumLabel.isNotEmpty)
          _QualityBadge(
              label: premiumLabel, color: CupertinoColors.activeOrange),
        const Spacer(),
        if (standardLabel.isNotEmpty)
          _QualityBadge(
              label: standardLabel,
              color: CupertinoColors.white.withValues(alpha: 0.38)),
      ],
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Shows premium vs standard GlassSwitch side-by-side.
class _SwitchComparisonRow extends StatelessWidget {
  const _SwitchComparisonRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
        ),
        // Premium
        GlassSwitch(
          value: value,
          onChanged: onChanged,
          quality: GlassQuality.premium,
        ),
        SizedBox(width: 16),
        // Standard
        GlassSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
