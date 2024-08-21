import 'package:flutter/material.dart';

class NavigationErrorPage extends StatelessWidget {
  const NavigationErrorPage({super.key});

  static const String path = '/error';
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
