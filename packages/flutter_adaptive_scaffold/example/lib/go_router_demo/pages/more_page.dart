import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  /// The path for the more page.
  static const String path = '/more';

  /// The name for the more page.
  static const String name = 'More';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('More Page'),
      ),
    );
  }
}
