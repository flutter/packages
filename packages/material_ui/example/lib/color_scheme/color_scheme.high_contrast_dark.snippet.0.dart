// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

ThemeData createTheme() {
  return ThemeData(
    // #region body
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: const Color(0xffefb7ff),
          brightness: Brightness.dark,
        ).copyWith(
          primaryContainer: const Color(0xffefb7ff),
          onPrimaryContainer: Colors.black,
          secondaryContainer: const Color(0xff66fff9),
          onSecondaryContainer: Colors.black,
          error: const Color(0xff9b374d),
          onError: Colors.white,
        ),
    // #endregion body
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: createTheme(), home: const Scaffold());
  }
}
