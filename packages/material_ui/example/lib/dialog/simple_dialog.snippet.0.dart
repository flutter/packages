// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SimpleDialog].

enum Department { treasury, state }

class SimpleDialogExample {
  SimpleDialogExample(this.context);

  final BuildContext context;

  // #region body
  Future<void> _askedToLead() async {
    switch (await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select assignment'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Department.treasury);
              },
              child: const Text('Treasury department'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Department.state);
              },
              child: const Text('State department'),
            ),
          ],
        );
      },
    )) {
      case Department.treasury:
        // Let's go.
        // ...
        break;
      case Department.state:
        // ...
        break;
      case null:
        // dialog dismissed
        break;
    }
  }
  // #endregion body

  Future<void> askedToLead() => _askedToLead();
}
