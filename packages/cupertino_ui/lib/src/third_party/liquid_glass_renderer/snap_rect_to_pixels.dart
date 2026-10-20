// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'package:flutter/rendering.dart';

extension SnapRectToPixels on Rect {
  Rect snapToPixels(double devicePixelRatio) {
    return Rect.fromLTRB(
      left.snapToPixel(devicePixelRatio: devicePixelRatio),
      top.snapToPixel(devicePixelRatio: devicePixelRatio),
      right.snapToPixel(devicePixelRatio: devicePixelRatio),
      bottom.snapToPixel(devicePixelRatio: devicePixelRatio),
    );
  }
}

extension on double {
  double snapToPixel({required double devicePixelRatio}) {
    return (this * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }
}
