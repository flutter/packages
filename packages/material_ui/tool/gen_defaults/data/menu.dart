// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 36.0.6

import 'color_role.dart';
import 'shape_struct.dart';

class TokenMenu {
  /// md.comp.menu.container.shadow-color
  static const TokenColorRole containerShadowColor = TokenColorRole.shadow;

  /// md.comp.menu.container.elevation
  static const double containerElevation = 3.00;

  /// md.comp.menu.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 4.00,
    topRight: 4.00,
    bottomLeft: 4.00,
    bottomRight: 4.00,
  );

  /// md.comp.menu.container.color
  static const TokenColorRole containerColor = TokenColorRole.surfaceContainer;
}
