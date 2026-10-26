// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Switch.thumbIcon].

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
      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return const Icon(Icons.close);
        }
        return null; // All other states will use the default thumbIcon.
      }),
    )
    // #endregion body
    ;
  }
}
