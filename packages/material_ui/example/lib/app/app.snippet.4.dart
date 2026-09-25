// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MaterialApp.actions].

class MaterialAppExample extends StatelessWidget {
  const MaterialAppExample({super.key});

  // #region body
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      actions: <Type, Action<Intent>>{
        ...WidgetsApp.defaultActions,
        ActivateAction: CallbackAction<Intent>(
          onInvoke: (Intent intent) {
            // Do something here...
            return null;
          },
        ),
      },
      color: const Color(0xFFFF0000),
      builder: (BuildContext context, Widget? child) {
        return const Placeholder();
      },
    );
  }
  // #endregion body
}
