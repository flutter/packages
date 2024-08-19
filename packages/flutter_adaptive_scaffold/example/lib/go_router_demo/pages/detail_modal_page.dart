import 'package:flutter/material.dart';

class DetailModalPage extends StatelessWidget {
  const DetailModalPage({Key? key}) : super(key: key);

  static const String path = 'detail-modal';
  static const String name = 'DetailModal';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Detail modal Page'),
      ),
    );
  }
}
