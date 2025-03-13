// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../paint.dart';

/// A class that transforms from one color to another during SVG parsing.
abstract class ColorMapper {
  /// Returns a new color to use in place of [color] during SVG parsing.
  ///
  /// The SVG parser will call this method every time it parses a color
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  );
}
