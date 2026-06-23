// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class ShapeStruct {
  const ShapeStruct({
    required this.family,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final String family;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;
}
