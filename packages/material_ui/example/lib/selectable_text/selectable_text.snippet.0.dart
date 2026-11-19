// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SelectableText].

class SelectableTextExample extends StatelessWidget {
  const SelectableTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    const SelectableText(
      'Hello! How are you?',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold),
    )
    // #endregion body
    ;
  }
}
