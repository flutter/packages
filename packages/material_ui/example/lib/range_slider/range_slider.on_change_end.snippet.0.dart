// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [RangeSlider.onChangeEnd].

class RangeSliderExample extends StatefulWidget {
  const RangeSliderExample({super.key});

  @override
  State<RangeSliderExample> createState() => _RangeSliderExampleState();
}

class _RangeSliderExampleState extends State<RangeSliderExample> {
  RangeValues _rangeValues = const RangeValues(4.0, 8.0);

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    RangeSlider(
      values: _rangeValues,
      min: 1.0,
      max: 10.0,
      onChanged: (RangeValues newValues) {
        setState(() {
          _rangeValues = newValues;
        });
      },
      onChangeEnd: (RangeValues endValues) {
        print('Ended change at $endValues');
      },
    )
    // #endregion body
    ;
  }
}
