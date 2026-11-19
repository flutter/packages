// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [AlertDialog].

class AlertDialogExample extends StatefulWidget {
  const AlertDialogExample({super.key});

  @override
  State<AlertDialogExample> createState() => AlertDialogExampleState();
}

class AlertDialogExampleState extends State<AlertDialogExample> {
  // #region body
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // #endregion body

  Future<void> showMyDialog() => _showMyDialog();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
