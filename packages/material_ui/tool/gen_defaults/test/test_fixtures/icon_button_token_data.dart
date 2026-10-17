// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../data/color_role.dart';
import '../../data/shape_struct.dart';

class TokenIconButton {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
  static const TokenColorRole iconColor = TokenColorRole.onSurfaceVariant;
  static const TokenColorRole disabledIconColor = TokenColorRole.onSurface;
  static const double disabledIconOpacity = 0.38;
  static const TokenColorRole hoveredStateLayerColor = TokenColorRole.onSurfaceVariant;
  static const double hoveredStateLayerOpacity = 0.08;
  static const ShapeStruct pressedContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 8.00,
    topRight: 8.00,
    bottomLeft: 8.00,
    bottomRight: 8.00,
  );
}
