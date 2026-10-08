/// Tab bar widgets — tabWidth demo
///
/// Demonstrates how [GlassTabBar.bottom] and [GlassTabBar.searchable]
/// control the tab pill width on both bar variants.
///
/// Run standalone:
///   flutter run -t example/lib/demos/bottom_bar_tab_width_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _DemoApp()));
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'tabWidth Demo',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        ),
        child: child!,
      ),
      home: const TabWidthDemoPage(),
    );
  }
}

// =============================================================================
// Home — interactive controls
// =============================================================================

class TabWidthDemoPage extends StatefulWidget {
  const TabWidthDemoPage({super.key});

  @override
  State<TabWidthDemoPage> createState() => _TabWidthDemoPageState();
}

// Which bar variant is being demonstrated
enum _BarVariant { searchable, standalone }

class _TabWidthDemoPageState extends State<TabWidthDemoPage> {
  // ── Controls ────────────────────────────────────────────────────────────────
  _BarVariant _variant = _BarVariant.searchable;
  int _tabCount = 2;
  double? _tabWidth; // null = expand (default)
  bool _searching = false;
  int _selected = 0;
  bool _showExtraButton = false; // only relevant for standalone bar

  static const _kWidths = <String, double?>{
    '72 px': 72.0,
    '88 px (iOS 26)': 88.0,
    '110 px': 110.0,
    'expand (null)': null,
  };

  static const _kCounts = [2, 3, 4, 5];

  List<GlassTab> get _tabs => [
        const GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
        const GlassTab(label: 'Browse', icon: Icon(CupertinoIcons.compass)),
        const GlassTab(label: 'Library', icon: Icon(CupertinoIcons.book)),
        const GlassTab(
            label: 'Radio', icon: Icon(CupertinoIcons.radiowaves_left)),
        const GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
      ].take(_tabCount).toList();

  @override
  Widget build(BuildContext context) {
    // Clamp selected index when tab count decreases
    final clampedSelected = _selected.clamp(0, _tabCount - 1);
    if (clampedSelected != _selected) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _selected = clampedSelected));
    }

    return GlassScaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Background gradient ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                  Color(0xFF533483),
                ],
              ),
            ),
          ),

          // ── Controls panel ──────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tabWidth Demo',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Controls the tab pill width on both bar variants',
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Bar variant selector
                  _SectionLabel('BAR VARIANT'),
                  SizedBox(height: 8),
                  _ChipRow(
                    options: const ['Searchable', 'Standalone'],
                    selected: _variant.index,
                    onSelected: (i) => setState(() {
                      _variant = _BarVariant.values[i];
                      _searching = false;
                    }),
                  ),

                  SizedBox(height: 16),

                  // Tab count selector
                  _SectionLabel('TAB COUNT'),
                  SizedBox(height: 8),
                  _ChipRow(
                    options: _kCounts.map((c) => '$c tabs').toList(),
                    selected: _kCounts.indexOf(_tabCount),
                    onSelected: (i) => setState(() => _tabCount = _kCounts[i]),
                  ),

                  SizedBox(height: 16),

                  // tabWidth selector
                  _SectionLabel('TABWIDTH'),
                  SizedBox(height: 8),
                  _ChipRow(
                    options: _kWidths.keys.toList(),
                    selected: _kWidths.values.toList().indexOf(_tabWidth),
                    onSelected: (i) => setState(
                        () => _tabWidth = _kWidths.values.elementAt(i)),
                  ),

                  // Extra button toggle (standalone only)
                  if (_variant == _BarVariant.standalone) ...[
                    SizedBox(height: 16),
                    _SectionLabel('EXTRA BUTTON'),
                    SizedBox(height: 8),
                    _ChipRow(
                      options: const ['None', 'Compose (+)'],
                      selected: _showExtraButton ? 1 : 0,
                      onSelected: (i) =>
                          setState(() => _showExtraButton = i == 1),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Live metrics
                  _MetricsCard(
                    tabCount: _tabCount,
                    tabWidth: _tabWidth,
                    variant: _variant,
                    hasExtraButton: _showExtraButton,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom bar ──────────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _variant == _BarVariant.searchable
                ? GlassTabBar.searchable(
                    tabs: _tabs,
                    selectedIndex: clampedSelected,
                    isSearchActive: _searching,
                    tabWidth: _tabWidth,
                    onTabSelected: (i) => setState(() {
                      _selected = i;
                      _searching = false;
                    }),
                    quality: GlassQuality.premium,
                    searchConfig: GlassSearchBarConfig(
                      hintText: 'Search',
                      showsCancelButton: true,
                      onSearchToggle: (v) => setState(() => _searching = v),
                    ),
                  )
                : GlassTabBar.bottom(
                    tabs: _tabs,
                    selectedIndex: clampedSelected,
                    tabWidth: _tabWidth,
                    onTabSelected: (i) => setState(() => _selected = i),
                    quality: GlassQuality.premium,
                    extraButton: _showExtraButton
                        ? GlassTabBarExtraButton(
                            icon: Icon(CupertinoIcons.plus),
                            label: 'Compose',
                            onTap: () {},
                          )
                        : null,
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Metric card
// =============================================================================

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.tabCount,
    required this.tabWidth,
    required this.variant,
    required this.hasExtraButton,
  });

  final int tabCount;
  final double? tabWidth;
  final _BarVariant variant;
  final bool hasExtraButton;

  @override
  Widget build(BuildContext context) {
    final pillW = tabWidth != null ? tabWidth! * tabCount : null;
    final pillLabel = pillW != null
        ? '${pillW.toStringAsFixed(0)} px (${tabWidth!.toStringAsFixed(0)} × $tabCount)'
        : 'fills available space';

    final variantLabel = variant == _BarVariant.searchable
        ? 'GlassSearchableBottomBar'
        : 'GlassBottomBar';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricRow('Widget', variantLabel),
          SizedBox(height: 8),
          _MetricRow(
              'tabWidth', tabWidth != null ? '$tabWidth px' : 'null (expand)'),
          SizedBox(height: 8),
          _MetricRow('tabCount', '$tabCount'),
          SizedBox(height: 8),
          _MetricRow('Pill width', pillLabel),
          if (variant == _BarVariant.standalone) ...[
            SizedBox(height: 8),
            _MetricRow('Extra button', hasExtraButton ? 'Compose (+)' : 'none'),
          ],
          SizedBox(height: 12),
          Text(
            tabWidth != null
                ? '✅ iOS 26 compact sizing — pill is proportional to tabs'
                : '⬛ Expand (default) — tab pill fills all available space',
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.5),
                fontSize: 13)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared small widgets
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: CupertinoColors.white.withValues(alpha: 0.55),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final active = i == selected;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF0A84FF)
                  : CupertinoColors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? const Color(0x00000000)
                    : CupertinoColors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              options[i],
              style: TextStyle(
                color: active
                    ? CupertinoColors.white
                    : CupertinoColors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }),
    );
  }
}
