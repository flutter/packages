import 'package:flutter/material.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  static const String path = '/counter';
  static const String name = 'Counter';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Counter Page'),
      ),
    );
  }
}
