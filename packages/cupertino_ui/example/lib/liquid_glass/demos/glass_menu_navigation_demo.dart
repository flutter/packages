// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT

/// GlassMenu & GlassPopover Navigation Transitions Standalone Demo.
///
/// Demonstrates clean menu and popover dismissal when navigating to another
/// page, ensuring overlays dismiss cleanly behind the incoming route:
///   1. Imperative Navigation ([Navigator.push]) with speed/slow-mo controls.
///   2. Declarative Navigation ([Navigator.pages] simulating `go_router`).
///   3. Nested Navigator hierarchy (tab shell) vs Single Root Navigator.
///   4. High-contrast, easily readable UI with instant Light/Dark mode toggle.
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_menu_navigation_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    adaptiveQuality: true,
    child: const GlassMenuNavigationDemoApp(),
  ));
}

class GlassMenuNavigationDemoApp extends StatefulWidget {
  const GlassMenuNavigationDemoApp({super.key});

  @override
  State<GlassMenuNavigationDemoApp> createState() =>
      _GlassMenuNavigationDemoAppState();
}

class _GlassMenuNavigationDemoAppState
    extends State<GlassMenuNavigationDemoApp> {
  bool _isDark = true;

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Menu Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
      ),
      builder: (context, child) => Theme(
        data: _isDark
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData.light(useMaterial3: true),
        child: child!,
      ),
      home: GlassMenuNavigationDemoPage(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

enum _NavigationMode {
  imperative('Imperative (push)'),
  declarative('Declarative (pages / go_router)');

  const _NavigationMode(this.label);
  final String label;
}

enum _NavigatorStructure {
  single('Single Navigator'),
  nested('Nested Tab Shell');

  const _NavigatorStructure(this.label);
  final String label;
}

class GlassMenuNavigationDemoPage extends StatefulWidget {
  const GlassMenuNavigationDemoPage({
    super.key,
    this.isDark,
    this.onToggleTheme,
  });

  /// External theme state. If null, the widget manages its own state.
  final bool? isDark;

  /// External theme toggle callback. If null, the widget manages its own toggle.
  final VoidCallback? onToggleTheme;

  @override
  State<GlassMenuNavigationDemoPage> createState() =>
      _GlassMenuNavigationDemoPageState();
}

class _GlassMenuNavigationDemoPageState
    extends State<GlassMenuNavigationDemoPage> {
  _NavigationMode _navMode = _NavigationMode.imperative;
  _NavigatorStructure _structure = _NavigatorStructure.nested;
  double _transitionDurationSeconds = 0.5;
  String? _declarativeDestination;
  bool _localDark = true;

  bool get _isDark => widget.isDark ?? _localDark;

  void _toggleTheme() {
    if (widget.onToggleTheme != null) {
      widget.onToggleTheme!();
    } else {
      setState(() => _localDark = !_localDark);
    }
  }

  Duration get _transitionDuration =>
      Duration(milliseconds: (_transitionDurationSeconds * 1000).round());

  // Colors designed for high contrast and effortless legibility
  Color get _bg => _isDark ? const Color(0xFF121217) : const Color(0xFFF3F4F8);
  Color get _cardBg =>
      _isDark ? const Color(0xFF1C1D24) : const Color(0xFFFFFFFF);
  Color get _cardBorder =>
      _isDark ? const Color(0xFF2E303C) : const Color(0xFFE2E4EC);
  Color get _textPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111116);
  Color get _textSecondary =>
      _isDark ? const Color(0xFFCBD0DD) : const Color(0xFF383C4A);
  Color get _textMuted =>
      _isDark ? const Color(0xFF9EA5B6) : const Color(0xFF6B7280);

  void _navigateTo(BuildContext context, String destination) {
    if (_navMode == _NavigationMode.declarative) {
      setState(() {
        _declarativeDestination = destination;
      });
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: _transitionDuration,
          reverseTransitionDuration: _transitionDuration,
          pageBuilder: (context, animation, secondaryAnimation) {
            return _DestinationPage(
              title: destination,
              isDark: _isDark,
              onBack: () => Navigator.of(context).pop(),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_structure == _NavigatorStructure.nested) {
      return _buildNestedShell();
    }
    return _buildMainContent(context);
  }

  Widget _buildNestedShell() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: _isDark
            ? const Color(0xFF181920).withValues(alpha: 0.9)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        activeColor: CupertinoColors.activeBlue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_stack_3d_up_fill),
            label: 'Demo Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info_circle_fill),
            label: 'Architecture Info',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 1) {
          return CupertinoTabView(
            builder: (context) => _ArchitectureInfoPage(isDark: _isDark),
          );
        }
        return CupertinoTabView(
          builder: (nestedContext) => _buildMainContent(nestedContext),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (_navMode == _NavigationMode.declarative &&
        _declarativeDestination != null) {
      return Navigator(
        pages: [
          MaterialPage(
            key: const ValueKey('home_page'),
            child: _buildDashboard(context),
          ),
          MaterialPage(
            key: ValueKey(_declarativeDestination),
            child: _DestinationPage(
              title: _declarativeDestination!,
              isDark: _isDark,
              onBack: () => setState(() => _declarativeDestination = null),
            ),
          ),
        ],
        onDidRemovePage: (page) {
          setState(() => _declarativeDestination = null);
        },
      );
    }

    return _buildDashboard(context);
  }

  Widget _buildDashboard(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _isDark
            ? const Color(0xFF181920).withValues(alpha: 0.9)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        middle: Text(
          'Menu Navigation Transitions',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _toggleTheme,
          child: Icon(
            _isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
            color: _isDark
                ? CupertinoColors.systemYellow
                : CupertinoColors.systemIndigo,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Status banner with high contrast
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    _isDark ? const Color(0xFF0F311D) : const Color(0xFFE8F8EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isDark
                      ? const Color(0xFF28A745)
                      : const Color(0xFF34C759),
                  width: 1.4,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: Color(0xFF28A745),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seamless Route Transitions',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isDark
                                ? const Color(0xFF75E898)
                                : const Color(0xFF186E32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'When navigating to a new page from a menu item or popover, overlays dismiss cleanly behind the incoming route without ghosting or glass bleed.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: _isDark
                                ? const Color(0xFFE2F9EB)
                                : const Color(0xFF1C4524),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Controls Card
            _buildControlsCard(),
            const SizedBox(height: 16),

            // User Reported Scenario Card (Start Activity)
            _buildActivityTriggerCard(context),
            const SizedBox(height: 16),

            // Popover Scenario Card
            _buildPopoverTriggerCard(context),
            const SizedBox(height: 16),

            // Architecture highlights card
            _buildArchitectureSummaryCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Navigation Configuration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Navigation Mode selector
          Text(
            'Router Paradigm:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<_NavigationMode>(
              groupValue: _navMode,
              children: {
                for (final m in _NavigationMode.values)
                  m: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      m.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
              },
              onValueChanged: (val) {
                if (val != null) {
                  setState(() {
                    _navMode = val;
                    _declarativeDestination = null;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Navigator structure selector
          Text(
            'Navigator Structure:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<_NavigatorStructure>(
              groupValue: _structure,
              children: {
                for (final s in _NavigatorStructure.values)
                  s: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
              },
              onValueChanged: (val) {
                if (val != null) {
                  setState(() {
                    _structure = val;
                    _declarativeDestination = null;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 14),

          // Transition duration slider (slow-mo inspection)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page Slide Duration:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_transitionDurationSeconds.toStringAsFixed(1)}s (${_transitionDurationSeconds > 1.0 ? "Slow Motion" : _transitionDurationSeconds >= 0.5 ? "Normal Speed" : "Fast"})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CupertinoSlider(
            value: _transitionDurationSeconds,
            min: 0.2,
            max: 2.0,
            divisions: 9,
            onChanged: (val) =>
                setState(() => _transitionDurationSeconds = val),
          ),
          Text(
            'Tip: Increase slider to 1.5s or 2.0s to clearly inspect the transition frame-by-frame.',
            style: TextStyle(
              fontSize: 11,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTriggerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.bars,
                  size: 18,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Glass Menu Navigation Test',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Step 1: Tap the button below to open the GlassMenu.\n'
            'Step 2: Tap "Start Activity (Navigates to Page)".\n'
            'Result: The incoming page smoothly slides over the menu. The menu never hovers above or distorts the destination page.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GlassMenu(
              triggerBuilder: (context, toggleMenu) => GlassButton.custom(
                onTap: toggleMenu,
                shape: const LiquidRoundedSuperellipse(borderRadius: 14),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.bars, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Open Navigation Menu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              items: [
                GlassMenuItem(
                  icon: const Icon(
                    CupertinoIcons.arrow_right_circle_fill,
                    color: CupertinoColors.activeBlue,
                  ),
                  title: 'Start Activity (Navigates to Page)',
                  onTap: () => _navigateTo(context, 'Activity Dashboard'),
                ),
                GlassMenuItem(
                  icon: const Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    color: CupertinoColors.systemPurple,
                  ),
                  title: 'Performance Stats (Navigates)',
                  onTap: () => _navigateTo(context, 'Performance Stats'),
                ),
                GlassMenuItem(
                  icon: const Icon(
                    CupertinoIcons.xmark_circle,
                    color: CupertinoColors.systemGrey,
                  ),
                  title: 'Dismiss Menu (No Navigation)',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopoverTriggerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.bubble_left_fill,
                  size: 18,
                  color: CupertinoColors.systemOrange,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Glass Popover Navigation Test',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'GlassPopover shares the exact same nearestOverlay and scheduler-safe dismissal engine:',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GlassPopover(
              triggerBuilder: (context, toggle) => GlassButton.custom(
                onTap: toggle,
                shape: const LiquidRoundedSuperellipse(borderRadius: 14),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.bubble_left_fill, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Open Popover Dialog',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              contentBuilder: (context, close) => Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Popover Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap below to navigate to a new route from this popover:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Navigate to Details',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        close();
                        _navigateTo(context, 'Popover Details Page');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Route-Confined Overlays Work',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint(
            'Nearest Overlay Scoping:',
            'Morphing overlays attach to the nearest route overlay instead of rootOverlay, keeping the menu inside the current route so incoming pages naturally render above it during transitions.',
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            'Relative Coordinate Computation:',
            'Trigger offsets are measured directly against the nearest overlay box (localToGlobal with ancestor: overlayBox), completely fixing coordinate drift in nested layouts and sidebars.',
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            'Declarative Router Safety (go_router):',
            'Immediate dismissals during Navigator updates are deferred past Flutter\'s persistentCallbacks phase, eliminating assertion crashes during declarative router rebuilds.',
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 12.5, height: 1.45, color: _textSecondary),
              children: [
                TextSpan(
                  text: '$title ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DestinationPage extends StatelessWidget {
  const _DestinationPage({
    required this.title,
    required this.isDark,
    required this.onBack,
  });

  final String title;
  final bool isDark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? const Color(0xFF181920).withValues(alpha: 0.9)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        leading: CupertinoNavigationBarBackButton(
          onPressed: onBack,
          color: CupertinoColors.activeBlue,
        ),
        middle: Text(
          title,
          style: TextStyle(
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                    Color(0xFF415A77),
                  ]
                : const [
                    Color(0xFFE0EAFC),
                    Color(0xFFCFDEF3),
                    Color(0xFFB5C9E2),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                shape: LiquidRoundedSuperellipse(borderRadius: 20),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 64,
                        color: CupertinoColors.activeGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Clean Transition Verified!\n'
                        'The destination page rendered cleanly without any overlapping menu or glass bleed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFD0D6E2)
                              : const Color(0xFF333D4F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlassButton.custom(
                        onTap: onBack,
                        shape:
                            const LiquidRoundedSuperellipse(borderRadius: 14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.arrow_left, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Return to Demo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchitectureInfoPage extends StatelessWidget {
  const _ArchitectureInfoPage({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111116);
    final bodyColor =
        isDark ? const Color(0xFFCBD0DD) : const Color(0xFF383C4A);

    return CupertinoPageScaffold(
      backgroundColor:
          isDark ? const Color(0xFF121217) : const Color(0xFFF3F4F8),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? const Color(0xFF181920).withValues(alpha: 0.9)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        middle: Text(
          'Architecture & Design',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Route-Confined Overlay System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1C1D24) : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E303C)
                      : const Color(0xFFE2E4EC),
                ),
              ),
              child: Text(
                'In modern Flutter applications, modal overlays and popovers must integrate seamlessly with page transitions. Instead of hoisting glass overlays globally into the root navigator, liquid_glass_widgets binds menus to their nearest route overlay. When an item triggers a route push, the outgoing menu naturally stays behind the incoming route, preventing visual artifacts and backdrop bleeding.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: bodyColor,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Key Architectural Highlights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Nearest Overlay Hierarchy: Overlays are scoped to their enclosing route overlay, ensuring incoming pages always stack cleanly on top.\n'
              '2. Relative Ancestor Coordinate Geometry: Trigger bounding boxes are mapped relative to the overlay container, eliminating layout drift in split-views and tab bars.\n'
              '3. Declarative Router Safety: Overlay dismissals defer safely past Flutter\'s persistent callbacks phase, preventing assertion errors during go_router / Navigator.pages updates.',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: bodyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
