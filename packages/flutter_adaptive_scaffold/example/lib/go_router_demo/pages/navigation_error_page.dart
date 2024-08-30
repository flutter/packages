import 'package:flutter/material.dart';

/// The error page for navigation errors.
class NavigationErrorPage extends StatelessWidget {
  /// Creates a new instance of the [NavigationErrorPage].
  const NavigationErrorPage({super.key});

  /// The path for the error page.
  static const String path = '/error';

  /// The name for the error page.
  static const String name = 'Error';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Error Page'),
      ),
    );
  }
}
