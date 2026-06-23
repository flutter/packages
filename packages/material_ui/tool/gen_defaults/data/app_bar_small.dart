// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenAppBarSmall {
  /// md.comp.app-bar.small.container.height
  static const double containerHeight = 64.00;

  /// md.comp.app-bar.small.search.container.height
  static const double searchContainerHeight = 56.00;

  /// md.comp.app-bar.small.search.container.shape
  static const ShapeStruct searchContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.app-bar.small.search.label-text.font
  static const TypescaleStruct searchLabelTextFont = TokenTypescale.bodyLarge;

  /// md.comp.app-bar.small.subtitle.font
  static const TypescaleStruct subtitleFont = TokenTypescale.labelMedium;

  /// md.comp.app-bar.small.title.font
  static const TypescaleStruct titleFont = TokenTypescale.titleLarge;
}
