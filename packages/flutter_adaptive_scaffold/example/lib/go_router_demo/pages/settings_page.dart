import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const String path = '/settings';
  static const String name = 'Settings';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
