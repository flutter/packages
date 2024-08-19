import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key}) : super(key: key);

  static const String path = '/detail';
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
