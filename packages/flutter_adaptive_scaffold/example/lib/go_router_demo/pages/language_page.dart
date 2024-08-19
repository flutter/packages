import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  static const String path = '/language';
  static const String name = 'Language';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Language Page'),
      ),
    );
  }
}
