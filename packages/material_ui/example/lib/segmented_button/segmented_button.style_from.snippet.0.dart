// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  Widget _buildSegmentedButton() {
    return
    // #region body
    SegmentedButton<int>(
      style: SegmentedButton.styleFrom(
        foregroundColor: Colors.black,
        selectedForegroundColor: Colors.white,
        backgroundColor: Colors.amber,
        selectedBackgroundColor: Colors.red,
      ),
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Text('0'),
          icon: Icon(Icons.calendar_view_day),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('1'),
          icon: Icon(Icons.calendar_view_week),
        ),
      ],
      selected: const <int>{0},
      onSelectionChanged: (Set<int> selection) {},
    )
    // #endregion body
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: _buildSegmentedButton())),
    );
  }
}
