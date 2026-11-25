// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SliderThemeData].

// #region body
class Blissful extends StatefulWidget {
  const Blissful({super.key});

  @override
  State<Blissful> createState() => _BlissfulState();
}

class _BlissfulState extends State<Blissful> {
  double _bliss = 0;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(
        context,
      ).copyWith(activeTrackColor: const Color(0xff404080)),
      child: Slider(
        onChanged: (double value) {
          setState(() {
            _bliss = value;
          });
        },
        value: _bliss,
      ),
    );
  }
}
// #endregion body
