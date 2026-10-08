/// GlassSearchableBottomBar — Visual Regression & Issue Repro
///
/// Exercises edge cases in isolation and provides a global playground configuration
/// to test how parameters interact across different scenarios.
///
/// Run standalone:
///   flutter run -t example/lib/searchable_bar_repro.dart
///
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _ReproApp()));
}

class _ReproApp extends StatelessWidget {
  const _ReproApp();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'SearchableBottomBar Repro',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        ),
        child: child!,
      ),
      home: const _ReproHome(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenario & Config state
// ─────────────────────────────────────────────────────────────────────────────
enum _Scenario {
  extraButtonLeft('A — extraButton (left)'),
  extraButtonRight('A — extraButton (right)'),
  springDesync('B — Spring desync'),
  paddingFlicker('C — Padding flicker');

  const _Scenario(this.label);
  final String label;
}

class _GlobalConfig {
  const _GlobalConfig({
    required this.showsCancelButton,
    required this.searchBarHeight,
    required this.tabPillAnchor,
  });

  final bool showsCancelButton;
  final double searchBarHeight;
  final GlassTabPillAnchor tabPillAnchor;
}

class _ReproHome extends StatefulWidget {
  const _ReproHome();

  @override
  State<_ReproHome> createState() => _ReproHomeState();
}

class _ReproHomeState extends State<_ReproHome> {
  _Scenario _scenario = _Scenario.extraButtonRight;

  bool _showsCancelButton = true;
  double _searchBarHeight = 50.0;
  GlassTabPillAnchor _tabPillAnchor = GlassTabPillAnchor.start;

  @override
  Widget build(BuildContext context) {
    final config = _GlobalConfig(
      showsCancelButton: _showsCancelButton,
      searchBarHeight: _searchBarHeight,
      tabPillAnchor: _tabPillAnchor,
    );

    return GlassScaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SearchableBottomBar Repro',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 16),

                  // Global Config Toggles
                  _buildToggleRow('showsCancelButton', _showsCancelButton,
                      (v) => setState(() => _showsCancelButton = v)),

                  SizedBox(height: 8),
                  _buildSegmentedConfig<double>(
                    label: 'searchHeight',
                    value: _searchBarHeight,
                    options: {50.0: '50.0', 64.0: '64.0'},
                    onChanged: (v) => setState(() => _searchBarHeight = v),
                  ),
                  SizedBox(height: 8),
                  _buildSegmentedConfig<GlassTabPillAnchor>(
                    label: 'anchor',
                    value: _tabPillAnchor,
                    options: const {
                      GlassTabPillAnchor.start: 'start',
                      GlassTabPillAnchor.center: 'center',
                    },
                    onChanged: (v) => setState(() => _tabPillAnchor = v),
                  ),

                  SizedBox(height: 16),
                  Divider(color: CupertinoColors.white.withValues(alpha: 0.1)),
                  SizedBox(height: 8),

                  // Scenario Selector
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _Scenario.values.map((s) {
                      final active = s == _scenario;
                      return GestureDetector(
                        onTap: () => setState(() => _scenario = s),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF0A84FF)
                                : const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.label,
                            style: TextStyle(
                              color: active
                                  ? CupertinoColors.white
                                  : CupertinoColors.white
                                      .withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_scenario),
                child: _buildScenario(_scenario, config),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: CupertinoColors.white.withValues(alpha: 0.8),
                  fontSize: 13)),
          Transform.scale(
            scale: 0.75,
            child: CupertinoSwitch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedConfig<T extends Object>({
    required String label,
    required T value,
    required Map<T, String> options,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.8),
                fontSize: 13)),
        CupertinoSlidingSegmentedControl<T>(
          groupValue: value,
          onValueChanged: (v) {
            if (v != null) onChanged(v);
          },
          children: options.map(
            (k, v) => MapEntry(
              k,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(v, style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScenario(_Scenario s, _GlobalConfig config) {
    return switch (s) {
      _Scenario.extraButtonLeft => _ScenarioExtraButton(
          position: GlassExtraButtonPosition.beforeSearch,
          config: config,
        ),
      _Scenario.extraButtonRight => _ScenarioExtraButton(
          position: GlassExtraButtonPosition.afterSearch,
          config: config,
        ),
      _Scenario.springDesync => _ScenarioSpringDesync(config: config),
      _Scenario.paddingFlicker => _ScenarioPaddingFlicker(config: config),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildBackground() {
  return Container(
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
  );
}

const _kTabs = [
  GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
  GlassTab(label: 'Browse', icon: Icon(CupertinoIcons.compass)),
  GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
];

// ─────────────────────────────────────────────────────────────────────────────
// Scenario A — extraButton
// ─────────────────────────────────────────────────────────────────────────────
class _ScenarioExtraButton extends StatefulWidget {
  const _ScenarioExtraButton({required this.position, required this.config});
  final GlassExtraButtonPosition position;
  final _GlobalConfig config;

  @override
  State<_ScenarioExtraButton> createState() => _ScenarioExtraButtonState();
}

class _ScenarioExtraButtonState extends State<_ScenarioExtraButton> {
  bool _searching = false;
  int _selectedIndex = 0;
  bool _collapseOnSearchFocus = true;

  @override
  Widget build(BuildContext context) {
    final posLabel = widget.position == GlassExtraButtonPosition.beforeSearch
        ? 'left'
        : 'right';
    return Stack(
      children: [
        _buildBackground(),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _searching ? 'SEARCH ACTIVE' : 'Tab $_selectedIndex',
                style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'extraButton position: $posLabel\n'
                'Toggle collapseOnSearchFocus below ↓',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.6),
                    height: 1.6),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('collapseOnSearchFocus  ',
                      style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.8),
                          fontSize: 13)),
                  Transform.scale(
                    scale: 0.75,
                    child: CupertinoSwitch(
                      value: _collapseOnSearchFocus,
                      onChanged: (v) =>
                          setState(() => _collapseOnSearchFocus = v),
                    ),
                  ),
                ],
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
            isSearchActive: _searching,
            searchBarHeight: widget.config.searchBarHeight,
            tabPillAnchor: widget.config.tabPillAnchor,
            onTabSelected: (i) => setState(() {
              _selectedIndex = i;
              _searching = false;
            }),
            quality: GlassQuality.premium,
            extraButton: GlassTabBarExtraButton(
              icon: Icon(CupertinoIcons.plus),
              label: 'Add',
              onTap: () {},
              size: 64,
              position: widget.position,
              collapseOnSearchFocus: _collapseOnSearchFocus,
            ),
            searchConfig: GlassSearchBarConfig(
              hintText: 'Search',
              showsCancelButton: widget.config.showsCancelButton,
              onSearchToggle: (v) => setState(() => _searching = v),
            ),
            tabs: _kTabs,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenario B — Spring desync
// ─────────────────────────────────────────────────────────────────────────────
class _ScenarioSpringDesync extends StatefulWidget {
  const _ScenarioSpringDesync({required this.config});
  final _GlobalConfig config;

  @override
  State<_ScenarioSpringDesync> createState() => _ScenarioSpringDesyncState();
}

class _ScenarioSpringDesyncState extends State<_ScenarioSpringDesync> {
  bool _searching = false;
  int _selectedIndex = 0;
  int _toggleCount = 0;

  void _rapidReverse() {
    for (var i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          setState(() {
            _searching = !_searching;
            _toggleCount++;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Toggles: $_toggleCount',
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              Text('✓ No visibly jarring jump on rapid reverse',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.6),
                      height: 1.6)),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                      label: 'Toggle once',
                      color: const Color(0xFF30D158),
                      onTap: () => setState(() {
                            _searching = !_searching;
                            _toggleCount++;
                          })),
                  SizedBox(width: 12),
                  _ActionButton(
                      label: 'Rapid ×5',
                      color: const Color(0xFFFF9F0A),
                      onTap: _rapidReverse),
                ],
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
            isSearchActive: _searching,
            searchBarHeight: widget.config.searchBarHeight,
            tabPillAnchor: widget.config.tabPillAnchor,
            onTabSelected: (i) => setState(() {
              _selectedIndex = i;
              _searching = false;
            }),
            quality: GlassQuality.premium,
            searchConfig: GlassSearchBarConfig(
              hintText: 'Search',
              showsCancelButton: widget.config.showsCancelButton,
              onSearchToggle: (v) => setState(() => _searching = v),
            ),
            tabs: _kTabs,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenario C — Padding flicker
// ─────────────────────────────────────────────────────────────────────────────
class _ScenarioPaddingFlicker extends StatefulWidget {
  const _ScenarioPaddingFlicker({required this.config});
  final _GlobalConfig config;

  @override
  State<_ScenarioPaddingFlicker> createState() =>
      _ScenarioPaddingFlickerState();
}

class _ScenarioPaddingFlickerState extends State<_ScenarioPaddingFlicker> {
  bool _searching = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hPad = _searching ? 12.0 : 20.0;
    final vPad = _searching ? 8.0 : 20.0;

    return Stack(
      children: [
        _buildBackground(),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Padding change on focus',
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'hPad: ${hPad.toStringAsFixed(0)}  '
                'vPad: ${vPad.toStringAsFixed(0)}\n\n'
                '⚠ Watch for a gray rectangle flash\n'
                'at the moment of toggle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.6),
                    height: 1.6),
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
            isSearchActive: _searching,
            horizontalPadding: hPad,
            verticalPadding: vPad,
            searchBarHeight: widget.config.searchBarHeight,
            tabPillAnchor: widget.config.tabPillAnchor,
            onTabSelected: (i) => setState(() {
              _selectedIndex = i;
              _searching = false;
            }),
            quality: GlassQuality.premium,
            searchConfig: GlassSearchBarConfig(
              hintText: 'Search',
              showsCancelButton: widget.config.showsCancelButton,
              onSearchToggle: (v) => setState(() => _searching = v),
            ),
            tabs: _kTabs,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small action button
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14),
        ),
      ),
    );
  }
}
