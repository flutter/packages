import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlatformView demo — shows GlassTabBar.searchable floating over a WebView
// (same UIKitView PlatformView type as GoogleMap / MapLibre on iOS).
//
// Key point: platformViewBackdrop: Platform.isIOS
//   Premium quality uses Impeller's backdrop-sampling shader which cannot
//   read pixels from a native UIKitView. Setting platformViewBackdrop routes
//   rendering through a live BackdropFilter that correctly blurs hybrid-
//   composed platform views.
// ─────────────────────────────────────────────────────────────────────────────

class PlatformViewDemo extends StatefulWidget {
  const PlatformViewDemo({super.key});

  @override
  State<PlatformViewDemo> createState() => _PlatformViewDemoState();
}

class _PlatformViewDemoState extends State<PlatformViewDemo> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  bool _searchActive = false;

  static const _tabs = [
    GlassTab(icon: Icon(CupertinoIcons.house_fill), label: 'Home'),
    GlassTab(icon: Icon(CupertinoIcons.map_fill), label: 'Map'),
    GlassTab(icon: Icon(CupertinoIcons.person_fill), label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      // ┌─────────────────────────────────────────────────────────────────┐
      // │  THE FIX: platformViewBackdrop: Platform.isIOS                │
      // │                                                               │
      // │  Premium uses Impeller's backdrop-sampling shader which       │
      // │  cannot read pixels from a native UIKitView (GoogleMap,       │
      // │  WebView, MapLibre). Setting platformViewBackdrop ensures     │
      // │  it falls back to standard BackdropFilter rendering over      │
      // │  native views while maintaining the premium indicator.        │
      // └─────────────────────────────────────────────────────────────────┘
      bottomBar: GlassTabBar.searchable(
        settings: LiquidGlassSettings(
            glassColor: CupertinoColors.black.withValues(alpha: 0.26)),
        quality: GlassQuality.premium,
        platformViewBackdrop: Platform.isIOS,
        isSearchActive: _searchActive,
        selectedIconColor: CupertinoColors.white,
        unselectedIconColor: CupertinoColors.white.withValues(alpha: 0.70),
        selectedLabelColor: CupertinoColors.white,
        unselectedLabelColor: CupertinoColors.white.withValues(alpha: 0.70),
        searchConfig: GlassSearchBarConfig(
          onSearchToggle: (active) => setState(() => _searchActive = active),
          // Dark glass (glassColor: CupertinoColors.black.withValues(alpha: 0.26)) needs explicit white icons.
          searchIconColor: CupertinoColors.white,
        ),
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        tabs: _tabs,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          PlaceholderTab(label: 'Home'),
          MapTab(),
          PlaceholderTab(label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map tab — OpenStreetMap via WebView (same UIKitView type as GoogleMap)
// ─────────────────────────────────────────────────────────────────────────────

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CupertinoColors.black)
      ..loadRequest(
        Uri.parse('https://www.openstreetmap.org/#map=13/37.7749/-122.4194'),
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WebViewWidget(controller: _controller);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder tabs
// ─────────────────────────────────────────────────────────────────────────────

class PlaceholderTab extends StatefulWidget {
  const PlaceholderTab({super.key, required this.label});

  final String label;

  @override
  State<PlaceholderTab> createState() => _PlaceholderTabState();
}

class _PlaceholderTabState extends State<PlaceholderTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Text(
        widget.label,
        style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
      ),
    );
  }
}
