// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Switch.thumbColor].

class SwitchExample extends StatelessWidget {
  const SwitchExample({super.key, required this.onChanged});

  final ValueChanged<bool>? onChanged;

  ValueChanged<bool>? get _nullableOnChanged => onChanged;
  bool get _value => true;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    Switch(
      value: _value,
      // If `onChanged` is null, this switch is disabled.
      // If `onChanged` is not null, this switch is enabled.
      onChanged: _nullableOnChanged,
      thumbColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.orange.withValues(alpha: .48);
        }
        return Colors.orange;
      }),
    )
    // #endregion body
    ;
  }
}
