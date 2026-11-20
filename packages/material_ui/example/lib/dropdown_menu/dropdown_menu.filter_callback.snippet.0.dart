// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [DropdownMenu.filterCallback].

class DropdownMenuExample extends StatelessWidget {
  const DropdownMenuExample({
    super.key,
    this.entries = const <DropdownMenuEntry<Text>>[],
  });

  final List<DropdownMenuEntry<Text>> entries;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    DropdownMenu<Text>(
      enableFilter: true,
      filterCallback: (List<DropdownMenuEntry<Text>> entries, String filter) {
        final String trimmedFilter = filter.trim().toLowerCase();
        if (trimmedFilter.isEmpty) {
          return entries;
        }

        return entries
            .where(
              (DropdownMenuEntry<Text> entry) =>
                  entry.label.toLowerCase().contains(trimmedFilter),
            )
            .toList();
      },
      dropdownMenuEntries: entries,
    )
    // #endregion body
    ;
  }
}
