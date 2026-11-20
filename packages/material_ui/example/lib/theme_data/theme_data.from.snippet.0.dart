// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

MaterialApp createMaterialApp() {
  return
  // #region body
  MaterialApp(
    theme: ThemeData.from(colorScheme: const ColorScheme.light()),
    darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
  )
  // #endregion body
  ;
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialApp app = createMaterialApp();
    return MaterialApp(
      theme: app.theme,
      darkTheme: app.darkTheme,
      home: const Scaffold(),
    );
  }
}
