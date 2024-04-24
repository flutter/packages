// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Joint types for [Polyline].
enum JointType {
  /// Mitered joint, with fixed pointed extrusion equal to half the stroke width on the outside of the joint.
  ///
  /// Constant Value: 0
  mitered._(0),

  /// Flat bevel on the outside of the joint.
  ///
  /// Constant Value: 1
  bevel._(1),

  /// Rounded on the outside of the joint by an arc of radius equal to half the stroke width, centered at the vertex.
  ///
  /// Constant Value: 2
  round._(2);

  const JointType._(this.value);

  /// The value representing the [JointType] on the sdk.
  final int value;
}
