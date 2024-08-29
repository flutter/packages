import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import 'pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// The path for the home page.
  static const String path = '/home';

  /// The name for the home page.
  static const String name = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => <void>{
                context.goNamed(DetailOverviewPage.name),
              },
              child: const Text('Detail page'),
            ),
            const SizedBox(height: kMaterialGutterValue),
            ElevatedButton(
              onPressed: () => <void>{
                context.goNamed(DetailModalPage.name),
              },
              child: const Text('Detail modal page'),
            ),
          ],
        ),
      ),
    );
  }
}
