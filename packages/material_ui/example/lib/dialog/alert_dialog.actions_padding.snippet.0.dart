// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [AlertDialog.actionsPadding].

class AlertDialogExample extends StatelessWidget {
  const AlertDialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    AlertDialog(
      title: const Text('Title'),
      contentPadding: const EdgeInsets.all(8.0),
      content: Container(width: 200, height: 200, color: Colors.green),
      actions: <Widget>[
        ElevatedButton(onPressed: () {}, child: const Text('Button 1')),
        ElevatedButton(onPressed: () {}, child: const Text('Button 2')),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    )
    // #endregion body
    ;
  }
}
