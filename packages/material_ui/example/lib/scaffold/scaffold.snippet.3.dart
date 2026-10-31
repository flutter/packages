// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Scaffold].

class ScaffoldExample extends StatelessWidget {
  const ScaffoldExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text('Show'),
          onPressed: () {
            // #region body
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 72),
              ),
            );
            // #endregion body
          },
        ),
      ),
    );
  }
}
