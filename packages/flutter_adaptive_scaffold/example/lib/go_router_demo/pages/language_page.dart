import 'package:flutter/material.dart';

/// The language page.
class LanguagePage extends StatelessWidget {
  /// Construct the language page.
  const LanguagePage({super.key});

  /// The path for the language page.
  static const String path = '/language';

  /// The name for the language page.
  static const String name = 'Language';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: const Center(
        child: Text('Language Page'),
      ),
    );
  }
}
