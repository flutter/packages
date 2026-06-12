// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() {
  // Changes made in https://github.com/flutter/flutter/pull/163314
  Tooltip tooltip = Tooltip();
  tooltip = Tooltip(height: null);
  tooltip = Tooltip(height: 15.0);
  tooltip = Tooltip(constraints: null, height: 15.0);
  tooltip = Tooltip(constraints: BoxConstraints(maxWidth: 20.0), height: 15.0);
  tooltip.height;
}
