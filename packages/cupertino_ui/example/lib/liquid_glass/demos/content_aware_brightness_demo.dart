/// Content-Aware Brightness Demo
///
/// Showcases [GlassContentAwareScope] — the bar icons and labels automatically
/// adapt from light to dark as the content behind them changes while scrolling.
///
/// The page is built with alternating light and dark bands so the flip is
/// clearly visible. A manual override toggle demonstrates [brightnessOverride].
///
/// Run standalone: `flutter run -t lib/demos/content_aware_brightness_demo.dart`
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    child: const ContentAwareBrightnessDemoApp(),
  ));
}

class ContentAwareBrightnessDemoApp extends StatelessWidget {
  const ContentAwareBrightnessDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Content-Aware Brightness',
      theme: const CupertinoThemeData(brightness: Brightness.light),
      builder: (context, child) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: child!,
      ),
      home: const ContentAwareBrightnessDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMO PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ContentAwareBrightnessDemo extends StatefulWidget {
  const ContentAwareBrightnessDemo({super.key});

  @override
  State<ContentAwareBrightnessDemo> createState() =>
      _ContentAwareBrightnessDemoState();
}

class _ContentAwareBrightnessDemoState
    extends State<ContentAwareBrightnessDemo> {
  int _selectedTab = 0;
  Brightness? _lastFlip;

  // ── Alternating content bands ─────────────────────────────────────────────
  // Light → dark → light → dark so the bar clearly flips as you scroll.
  static const _bands = <_ContentBand>[
    _ContentBand(
      color: Color(0xFFF5F5F7),
      textColor: Color(0xFF1D1D1F),
      title: 'Light Content',
      subtitle: 'The bar stays in its default light appearance',
      icon: CupertinoIcons.sun_max_fill,
    ),
    _ContentBand(
      color: Color(0xFF1C1C1E),
      textColor: Color(0xFFF5F5F7),
      title: 'Dark Content',
      subtitle: 'The bar flips to dark — icons and labels invert',
      icon: CupertinoIcons.moon_fill,
    ),
    _ContentBand(
      color: Color(0xFFFFFFFF),
      textColor: Color(0xFF1D1D1F),
      title: 'White Content',
      subtitle: 'Back to light — the bar follows smoothly',
      icon: CupertinoIcons.brightness,
    ),
    _ContentBand(
      color: Color(0xFF2C2C2E),
      textColor: Color(0xFFE5E5EA),
      title: 'Dark Content Again',
      subtitle: 'Scroll slowly to see the cross-fade',
      icon: CupertinoIcons.moon_stars_fill,
    ),
    _ContentBand(
      color: Color(0xFFF2F2F7),
      textColor: Color(0xFF3A3A3C),
      title: 'Light — iOS System Background',
      subtitle: 'The bar returns to light appearance',
      icon: CupertinoIcons.device_phone_portrait,
    ),
    _ContentBand(
      color: Color(0xFF000000),
      textColor: Color(0xFFFFFFFF),
      title: 'Pure Black',
      subtitle: 'Maximum contrast — the bar flips dark immediately',
      icon: CupertinoIcons.circle_fill,
    ),
    _ContentBand(
      color: Color(0xFFF5F5F7),
      textColor: Color(0xFF1D1D1F),
      title: 'Light Footer',
      subtitle: 'Scroll back up to see the reverse transition',
      icon: CupertinoIcons.arrow_up,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const ColoredBox(color: Color(0xFFF2F2F7)),
      statusBarStyle: GlassStatusBarStyle.dark,
      topEdgeFade: true,
      bottomEdgeFade: true,
      contentAwareBrightness: true,

      // ── Body ──────────────────────────────────────────────────────────────
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content-Aware\nBrightness',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.label.resolveFrom(context),
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Scroll down — the bottom bar icons and labels '
                      'adapt automatically as the content behind them '
                      'changes from light to dark.',
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        height: 1.4,
                      ),
                    ),
                    if (_lastFlip != null)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _lastFlip == Brightness.dark
                                ? const Color(0xFF1C1C1E)
                                : const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Last flip: ${_lastFlip == Brightness.dark ? '☾ Dark' : '☀ Light'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _lastFlip == Brightness.dark
                                  ? CupertinoColors.white
                                  : const Color(0xFF1D1D1F),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Content bands
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _BandCard(band: _bands[index]),
              childCount: _bands.length,
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom + 120,
            ),
          ),
        ],
      ),

      // ── Bottom bar ────────────────────────────────────────────────────────
      bottomBar: GlassTabBar.bottom(
        selectedIndex: _selectedTab,
        onTabSelected: (i) => setState(() => _selectedTab = i),
        adaptiveBrightness: true,
        onBrightnessChanged: (b) => setState(() => _lastFlip = b),
        quality: GlassQuality.premium,
        interactionBehavior: GlassInteractionBehavior.full,
        selectedIconColor: const Color(0xFF007AFF),
        iconSize: 26,
        labelFontSize: 10,
        iconLabelSpacing: 1,
        tabs: const [
          GlassTab(
            label: 'Home',
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
          ),
          GlassTab(
            label: 'Search',
            icon: Icon(CupertinoIcons.search),
          ),
          GlassTab(
            label: 'Library',
            icon: Icon(CupertinoIcons.book),
            activeIcon: Icon(CupertinoIcons.book_fill),
          ),
          GlassTab(
            label: 'Settings',
            icon: Icon(CupertinoIcons.gear),
            activeIcon: Icon(CupertinoIcons.gear),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ContentBand {
  const _ContentBand({
    required this.color,
    required this.textColor,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final Color color;
  final Color textColor;
  final String title;
  final String subtitle;
  final IconData icon;
}

// ─────────────────────────────────────────────────────────────────────────────
// BAND CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BandCard extends StatelessWidget {
  const _BandCard({required this.band});

  final _ContentBand band;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      color: band.color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(band.icon,
                size: 48, color: band.textColor.withValues(alpha: 0.6)),
            SizedBox(height: 16),
            Text(
              band.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: band.textColor,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                band.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: band.textColor.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
