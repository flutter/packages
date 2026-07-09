// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Colors;

/// Flutter code sample for [CupertinoCheckbox].

class CupertinoCheckboxExample extends StatelessWidget {
  const CupertinoCheckboxExample({super.key, required this.onChanged});

  final ValueChanged<bool?>? onChanged;

  ValueChanged<bool?>? get _nullableOnChanged => onChanged;
  bool get _value => true;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    CupertinoCheckbox(
      value: _value,
      onChanged: _nullableOnChanged,
      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.orange.withValues(alpha: .32);
        }
        return Colors.orange;
      }),
    )
    // #region body
    ;
  }
}
