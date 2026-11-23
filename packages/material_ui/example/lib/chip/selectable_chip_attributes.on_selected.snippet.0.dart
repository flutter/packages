// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SelectableChipAttributes.onSelected].

// #region body
class Wood extends StatefulWidget {
  const Wood({super.key});

  @override
  State<StatefulWidget> createState() => WoodState();
}

class WoodState extends State<Wood> {
  bool _useChisel = false;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: const Text('Use Chisel'),
      selected: _useChisel,
      onSelected: (bool newValue) {
        setState(() {
          _useChisel = newValue;
        });
      },
    );
  }
}
// #endregion body
