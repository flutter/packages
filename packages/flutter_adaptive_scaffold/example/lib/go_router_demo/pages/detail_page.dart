import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  /// The path for the detail page.
  static const String path = 'detail';

  /// The name for the detail page.
  static const String name = 'Detail';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Detail Page'),
      ),
    );
  }
}
