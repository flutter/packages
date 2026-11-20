// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Slider.onChanged].

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<SliderExample> {
  int _duelCommandment = 1;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    Slider(
      value: _duelCommandment.toDouble(),
      min: 1.0,
      max: 10.0,
      divisions: 10,
      label: '$_duelCommandment',
      onChanged: (double newValue) {
        setState(() {
          _duelCommandment = newValue.round();
        });
      },
    )
    // #endregion body
    ;
  }
}
