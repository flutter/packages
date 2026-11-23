// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() {
  // Changes made in https://github.com/flutter/packages/pull/TODO
  Widget fab = FloatingActionButton.small(onPressed: () {});
  fab = FloatingActionButton.small(
    onPressed: () {},
    tooltip: 'Add',
    child: const Icon(Icons.add),
  );
  fab = const FloatingActionButton.small(onPressed: null);
}
