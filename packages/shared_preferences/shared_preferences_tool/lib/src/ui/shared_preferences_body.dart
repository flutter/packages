// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';

import 'data_panel.dart';
import 'keys_panel.dart';

/// The main body of the shared preferences tool.
/// It contains the [KeysPanel] and the [DataPanel].
class SharedPreferencesBody extends StatelessWidget {
  /// Default constructor for [SharedPreferencesBody].
  const SharedPreferencesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final Axis splitAxis = SplitPane.axisFor(context, 0.85);

    return SplitPane(
      axis: splitAxis,
      initialFractions: const <double>[0.33, 0.67],
      children: const <Widget>[
        KeysPanel(),
        DataPanel(),
      ],
    );
  }
}
