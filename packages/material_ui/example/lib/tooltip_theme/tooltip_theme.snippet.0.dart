// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  Widget _buildTooltip() {
    return
    // #region body
    TooltipTheme(
      data: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.9),
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Tooltip(
        message: 'Example tooltip',
        child: IconButton(
          iconSize: 36.0,
          icon: const Icon(Icons.touch_app),
          onPressed: () {},
        ),
      ),
    )
    // #endregion body
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: _buildTooltip())),
    );
  }
}
