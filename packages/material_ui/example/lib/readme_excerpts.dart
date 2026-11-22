// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use

// #docregion AppWideUsage
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MaterialUiCompatibilityBridge(child: child!);
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
    return const Scaffold(body: Center(child: Text('Home')));
  }
}

class SubtreeExample extends StatelessWidget {
  const SubtreeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #docregion SubtreeUsage
    Scaffold(
      appBar: AppBar(title: const Text('Modern Screen')),
      body: MaterialUiCompatibilityBridge(child: const LegacyPackageWidget()),
    )
    // #enddocregion SubtreeUsage
    ;
  }
}

class LegacyPackageWidget extends StatelessWidget {
  const LegacyPackageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Legacy package widget');
  }
}

/// A Dartdoc comment template shown in `example/README.md`.
const String dartdocCommentExample = r'''
// #docregion DartdocComment
/// {@example /example/lib/about/about_list_tile.0.dart}
/// Write a description of the example here. This description will appear in the
/// API web documentation to introduce the example.
/// {@end-example}
// #enddocregion DartdocComment
''';

/// A README code snippet for Material localization delegates.
const String localizationsDelegatesExample = r'''
// #docregion LocalizationsDelegates
localizationsDelegates: GlobalMaterialLocalizations.delegates,
// #enddocregion LocalizationsDelegates
''';
