/// Scaffold Navigation Bug Repro — Issue #177
///
/// Tests whether GlassScaffold appears transparent when navigating between
/// screens using MaterialPageRoute (the likely route type used by auto_route).
///
/// Run standalone:
///   flutter run -t example/lib/demos/scaffold_nav_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scaffold Nav Repro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ScreenA(),
    );
  }
}

// Screen A — dark background, GlassTabBar, pushes ScreenB via MaterialPageRoute
class ScreenA extends StatefulWidget {
  const ScreenA({super.key});

  @override
  State<ScreenA> createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E), Color(0xFF0A1628)],
          ),
        ),
      ),
      appBar: GlassAppBar(
        title: Text('Screen A'),
        actions: [
          GlassButton(
            icon: Icon(CupertinoIcons.arrow_right),
            label: 'Go to B',
            width: 40,
            height: 40,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ScreenB()),
            ),
          ),
        ],
      ),
      bottomBar: GlassTabBar.bottom(
        selectedIndex: _index,
        onTabSelected: (i) => setState(() => _index = i),
        tabs: const [
          GlassTab(
            label: 'Home',
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
          ),
          GlassTab(
            label: 'Settings',
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'SHARP TEXT ROW $i — must stay crisp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Screen B — NO explicit background (mirrors the user's AppScaffold pattern)
class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      // No background — exactly like the user's ScreenB / legal screen
      appBar: GlassAppBar(
        title: Text('Screen B (no background)'),
        leading: GlassButton(
          icon: Icon(CupertinoIcons.back),
          onTap: () => Navigator.of(context).pop(),
          width: 40,
          height: 40,
          iconSize: 20,
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Content item $i',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
