// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [DrawerController.maybeOf].

DrawerController? lookupDrawerController(BuildContext context) {
  // #region body
  DrawerController? controller = DrawerController.maybeOf(context);
  // #endregion body
  return controller;
}
