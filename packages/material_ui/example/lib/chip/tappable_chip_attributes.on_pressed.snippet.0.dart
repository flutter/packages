// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [TappableChipAttributes.onPressed].

// #region body
class Blacksmith extends StatelessWidget {
  const Blacksmith({super.key});

  void startHammering() {
    print('bang bang bang');
  }

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: const Text('Apply Hammer'),
      onPressed: startHammering,
    );
  }
}
// #endregion body
