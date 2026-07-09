// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.15

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale_struct.dart';

class TokenBadge {
  /// md.comp.badge.color
  static const TokenColorRole color = TokenColorRole.error;

  /// md.comp.badge.large.color
  static const TokenColorRole largeColor = TokenColorRole.error;

  /// md.comp.badge.large.label-text.color
  static const TokenColorRole largeLabelTextColor = TokenColorRole.onError;

  /// md.comp.badge.large.label-text.type
  static const TypescaleStruct largeLabelTextType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 11.00,
    fontWeight: 500,
    lineHeight: 16.00,
    letterSpacing: 0.50,
  );

  /// md.comp.badge.large.shape
  static const ShapeStruct largeShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.badge.large.size
  static const double largeSize = 16.00;

  /// md.comp.badge.shape
  static const ShapeStruct shape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.badge.size
  static const double size = 6.00;
}
