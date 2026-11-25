// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [RangeSlider.semanticFormatterCallback].

class RangeSliderExample extends StatefulWidget {
  const RangeSliderExample({super.key});

  @override
  State<RangeSliderExample> createState() => _RangeSliderExampleState();
}

class _RangeSliderExampleState extends State<RangeSliderExample> {
  RangeValues _dollarsRange = const RangeValues(100.0, 250.0);

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    RangeSlider(
      values: _dollarsRange,
      min: 20.0,
      max: 330.0,
      onChanged: (RangeValues newValues) {
        setState(() {
          _dollarsRange = newValues;
        });
      },
      semanticFormatterCallback: (double newValue) {
        return '${newValue.round()} dollars';
      },
    )
    // #endregion body
    ;
  }
}
