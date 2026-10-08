// GlassTabBar Scrollable Demo
//
// Demonstrates a scrollable GlassTabBar with a dynamic number of tabs.
// Uses CupertinoPageScaffold + GlassAppBar — the iOS 26-correct pattern
// where the bar is a transparent layout container and glass effects belong
// on the interactive elements (GlassButton), not the bar surface.

import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const TabBarScrollableApp()));
}

/// Root application widget — CupertinoApp is the correct root for iOS-style demos.
class TabBarScrollableApp extends StatelessWidget {
  const TabBarScrollableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'GlassTabBar Scrollable Demo',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: TabBarScrollableHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Home page containing the scrollable GlassTabBar.
class TabBarScrollableHome extends StatefulWidget {
  const TabBarScrollableHome({super.key});

  @override
  State<TabBarScrollableHome> createState() => _TabBarScrollableHomeState();
}

class _TabBarScrollableHomeState extends State<TabBarScrollableHome> {
  int _tabCount = 5;
  int _selectedIndex = 0;

  void _addTab() => setState(() => _tabCount++);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // GlassAppBar: iOS 26-correct — transparent bar, glass on the buttons.
      navigationBar: GlassAppBar(
        title: Text(
          'GlassTabBar — Scrollable',
          style: TextStyle(
            color: CupertinoColors.label,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GlassButton(
            icon: Icon(CupertinoIcons.add),
            onTap: _addTab,
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scrollable GlassTabBar — grows horizontally as tabs are added.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassSegmentedControl.scrollable(
                  quality: GlassQuality.premium,
                  selectedIndex: _selectedIndex,
                  onSegmentSelected: (i) => setState(() => _selectedIndex = i),
                  segments: List.generate(
                    _tabCount,
                    (i) => GlassSegment(label: 'Tab ${i + 1}'),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Tabs: $_tabCount   ·   Selected: ${_selectedIndex + 1}',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap + to add tabs',
                style: TextStyle(
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
