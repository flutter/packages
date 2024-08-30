import 'package:flutter/material.dart';

/// The detail modal page.
class DetailModalPage extends StatelessWidget {
  /// Construct the detail modal page.
  const DetailModalPage({super.key});

  /// The path for the detail modal page.
  static const String path = 'detail-modal';

  /// The name for the detail modal page.
  static const String name = 'DetailModal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Modal Page'),
      ),
      body: const Center(
        child: Text('Detail modal Page'),
      ),
    );
  }
}
