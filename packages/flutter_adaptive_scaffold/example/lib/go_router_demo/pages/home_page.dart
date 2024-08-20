import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String path = '/home';
  static const String name = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Home Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => <void>{
                context.goNamed(DetailPage.name),
              },
              child: const Text('Detail page'),
            ),
            const SizedBox(height: 16),
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
