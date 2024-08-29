import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// The path for the settings page.
  static const String path = 'settings';

  /// The name for the settings page.
  static const String name = 'Settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
