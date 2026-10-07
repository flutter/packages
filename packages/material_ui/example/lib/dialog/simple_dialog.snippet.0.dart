// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SimpleDialog].

enum Department { treasury, state }

class SimpleDialogExample extends StatefulWidget {
  const SimpleDialogExample({super.key, this.onSelected});

  final ValueChanged<Department?>? onSelected;

  @override
  State<SimpleDialogExample> createState() => _SimpleDialogExampleState();
}

class _SimpleDialogExampleState extends State<SimpleDialogExample> {
  ValueChanged<Department?>? get onSelected => widget.onSelected;

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
        onSelected?.call(Department.treasury);
      case Department.state:
        // ...
        onSelected?.call(Department.state);
      case null:
        // dialog dismissed
        onSelected?.call(null);
    }
  }
  // #endregion body

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _askedToLead,
      child: const Text('Select assignment'),
    );
  }
}
