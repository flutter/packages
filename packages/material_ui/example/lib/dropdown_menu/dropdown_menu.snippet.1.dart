// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [DropdownMenu.searchCallback].

class DropdownMenuExample extends StatelessWidget {
  const DropdownMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    DropdownMenu<Text>(
      searchCallback: (List<DropdownMenuEntry<Text>> entries, String query) {
        if (query.isEmpty) {
          return null;
        }
        final int index = entries.indexWhere(
          (DropdownMenuEntry<Text> entry) => entry.label == query,
        );

        return index != -1 ? index : null;
      },
      dropdownMenuEntries: const <DropdownMenuEntry<Text>>[
        DropdownMenuEntry<Text>(value: Text('All'), label: 'All'),
        DropdownMenuEntry<Text>(value: Text('Unread'), label: 'Unread'),
        DropdownMenuEntry<Text>(value: Text('Read'), label: 'Read'),
      ],
    )
    // #endregion body
    ;
  }
}
