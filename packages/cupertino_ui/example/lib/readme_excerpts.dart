// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use

// #docregion AppWideUsage
import 'package:cupertino_ui/cupertino_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      builder: (BuildContext context, Widget? child) {
        return CupertinoUiCompatibilityBridge(child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
// #enddocregion AppWideUsage

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(child: Center(child: Text('Home')));
  }
}

class SubtreeExample extends StatelessWidget {
  const SubtreeExample({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion SubtreeUsage
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Modern Screen'),
      ),
      child: CupertinoUiCompatibilityBridge(child: LegacyPackageWidget()),
    );
    // #enddocregion SubtreeUsage
  }
}

class LegacyPackageWidget extends StatelessWidget {
  const LegacyPackageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Legacy package widget');
  }
}
