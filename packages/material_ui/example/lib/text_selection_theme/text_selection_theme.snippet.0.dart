// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [TextSelectionTheme].

class TextSelectionThemeExample extends StatelessWidget {
  const TextSelectionThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    const TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: Colors.blue,
        selectionHandleColor: Colors.lightBlue,
      ),
      child: TextField(),
    )
    // #endregion body
    ;
  }
}
