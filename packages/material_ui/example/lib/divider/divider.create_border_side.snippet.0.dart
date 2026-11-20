// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 200, height: 100, child: BorderedSection()),
        ),
      ),
    );
  }
}

class BorderedSection extends StatelessWidget {
  const BorderedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: Divider.createBorderSide(context),
          bottom: Divider.createBorderSide(context),
        ),
      ),
      // child: ...
    )
    // #endregion body
    ;
  }
}
