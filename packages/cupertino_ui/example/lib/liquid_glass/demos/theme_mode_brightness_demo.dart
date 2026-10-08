import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Regression test for Issue #124:
/// "GlassTabBar loses shadow in Dark Mode regardless of App Theme"
///
/// Tests EXACTLY what the issue reporter described:
///   - MaterialApp with ThemeMode.light
///   - GlassTabBar used as Scaffold.bottomNavigationBar
///   - OS toggled to Dark Mode
///
/// Run on physical device: `flutter run -d <device-id>`
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      // The crucial callback that correctly intercepts the cascade
      brightnessResolver: Theme.maybeBrightnessOf,
      child: const BrightnessResolutionDemoApp(),
    ),
  );
}

class BrightnessResolutionDemoApp extends StatelessWidget {
  const BrightnessResolutionDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brightness Resolution Test',
      themeMode: ThemeMode.light, // App locked to light mode
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF0F0F5),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const _TestScreen(),
    );
  }
}

class _TestScreen extends StatefulWidget {
  const _TestScreen();

  @override
  State<_TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<_TestScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Detect actual resolved brightness to show on screen
    final resolvedBrightness = Theme.maybeBrightnessOf(context);
    final osBrightness = MediaQuery.platformBrightnessOf(context);

    return Scaffold(
      // NOTE: Using backgroundColor from theme — not transparent.
      // This exactly mirrors what the issue reporter has.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brightness Resolution Test',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _InfoRow(
                label: 'App ThemeMode',
                value: 'ThemeMode.light (hardcoded)',
                color: Colors.green,
              ),
              _InfoRow(
                label: 'OS Brightness',
                value: osBrightness.name.toUpperCase(),
                color: osBrightness == Brightness.dark
                    ? Colors.orange
                    : Colors.green,
              ),
              _InfoRow(
                label: 'Theme.maybeBrightnessOf',
                value: resolvedBrightness?.name.toUpperCase() ?? 'null',
                color: resolvedBrightness == Brightness.light
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(height: 32),
              const Text(
                'Instructions:\n'
                '1. Toggle OS to Dark Mode.\n'
                '2. "OS Brightness" above should show DARK.\n'
                '3. "Theme.maybeBrightnessOf" must still show LIGHT.\n'
                '4. The GlassTabBar below must keep its shadow\n'
                '   and NOT show a black border.',
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 32),
              const Expanded(
                child: _PassFailCard(),
              ),
            ],
          ),
        ),
      ),
      // ← THIS is the exact setup from Issue #124
      bottomNavigationBar: GlassTabBar.bottom(
        tabs: const [
          GlassTab(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
          ),
          GlassTab(
            label: 'Search',
            icon: Icon(Icons.search),
          ),
          GlassTab(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassFailCard extends StatelessWidget {
  const _PassFailCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✅ PASS',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          SizedBox(height: 8),
          Text(
            'GlassTabBar has a soft shadow\nand no black border.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 24),
          Text('❌ FAIL',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          SizedBox(height: 8),
          Text(
            'GlassTabBar loses shadow\nor shows a black/dark border.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
