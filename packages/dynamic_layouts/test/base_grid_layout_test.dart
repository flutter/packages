// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DynamicSliverGridGeometry returns tight constraints for finite extents',
      () {
    const DynamicSliverGridGeometry geometry = DynamicSliverGridGeometry(
      scrollOffset: 0,
      crossAxisOffset: 0,
      crossAxisExtent: 150.0,
      mainAxisExtent: 50.0,
    );

    // Vertical
    SliverConstraints sliverConstraints = const SliverConstraints(
      axisDirection: AxisDirection.down,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: 600,
      crossAxisExtent: 300,
      crossAxisDirection: AxisDirection.left,
      viewportMainAxisExtent: 1000,
      remainingCacheExtent: 600,
      cacheOrigin: 0.0,
    );
    BoxConstraints constraints = geometry.getBoxConstraints(sliverConstraints);
    expect(constraints, BoxConstraints.tight(const Size(150.0, 50.0)));

    // Horizontal
    sliverConstraints = const SliverConstraints(
      axisDirection: AxisDirection.left,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: 600,
      crossAxisExtent: 300,
      crossAxisDirection: AxisDirection.down,
      viewportMainAxisExtent: 1000,
      remainingCacheExtent: 600,
      cacheOrigin: 0.0,
    );
    constraints = geometry.getBoxConstraints(sliverConstraints);
    expect(constraints, BoxConstraints.tight(const Size(50.0, 150.0)));
  });

  test(
      'DynamicSliverGridGeometry returns loose constraints for infinite extents',
      () {
    const DynamicSliverGridGeometry geometry = DynamicSliverGridGeometry(
      scrollOffset: 0,
      crossAxisOffset: 0,
      mainAxisExtent: double.infinity,
      crossAxisExtent: double.infinity,
    );

    // Vertical
    SliverConstraints sliverConstraints = const SliverConstraints(
      axisDirection: AxisDirection.down,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: 600,
      crossAxisExtent: 300,
      crossAxisDirection: AxisDirection.left,
      viewportMainAxisExtent: 1000,
      remainingCacheExtent: 600,
      cacheOrigin: 0.0,
    );
    BoxConstraints constraints = geometry.getBoxConstraints(sliverConstraints);
    expect(constraints, const BoxConstraints());

    // Horizontal
    sliverConstraints = const SliverConstraints(
      axisDirection: AxisDirection.left,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: 600,
      crossAxisExtent: 300,
      crossAxisDirection: AxisDirection.down,
      viewportMainAxisExtent: 1000,
      remainingCacheExtent: 600,
      cacheOrigin: 0.0,
    );
    constraints = geometry.getBoxConstraints(sliverConstraints);
    expect(constraints, const BoxConstraints());
  });
}
