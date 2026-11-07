// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Radio.fillColor].

class RadioExample extends StatelessWidget {
  const RadioExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    Radio<int>(
      value: 1,
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.orange.withValues(alpha: .32);
        }
        return Colors.orange;
      }),
    )
    // #endregion body
    ;
  }
}
