// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Dialog].

class DialogExample extends StatelessWidget {
  const DialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    const Dialog(constraints: BoxConstraints(maxWidth: 560, minHeight: 280))
    // #endregion body
    ;
  }
}
