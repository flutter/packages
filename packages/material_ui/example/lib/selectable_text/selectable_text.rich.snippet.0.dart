// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SelectableText.rich].

class SelectableTextRichExample extends StatelessWidget {
  const SelectableTextRichExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    const SelectableText.rich(
      TextSpan(
        text: 'Hello', // default text style
        children: <TextSpan>[
          TextSpan(
            text: ' beautiful ',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: 'world',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    )
    // #endregion body
    ;
  }
}
