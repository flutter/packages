// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SimpleDialogOption].

enum Department { treasury, state }

class SimpleDialogOptionExample extends StatelessWidget {
  const SimpleDialogOptionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, Department.treasury);
      },
      child: const Text('Treasury department'),
    )
    // #endregion body
    ;
  }
}
