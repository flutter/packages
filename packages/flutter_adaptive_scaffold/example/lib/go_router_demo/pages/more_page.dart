import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  static const String path = '/more';
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
