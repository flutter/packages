// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SliderTheme.of].

// #region body
class Launch extends StatefulWidget {
  const Launch({super.key});

  @override
  State<Launch> createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  double _rocketThrust = 0;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(
        context,
      ).copyWith(activeTrackColor: const Color(0xff804040)),
      child: Slider(
        onChanged: (double value) {
          setState(() {
            _rocketThrust = value;
          });
        },
        value: _rocketThrust,
      ),
    );
  }
}
// #endregion body
