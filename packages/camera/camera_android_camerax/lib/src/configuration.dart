// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart' show immutable;

import 'java_object.dart';

/// Handle onto the raw buffer managed by screen compositor.
///
/// See https://developer.android.com/reference/android/view/Surface.html.
@immutable
class Configuration extends JavaObject {
  /// Creates a detached [Configuration].
  Configuration.detached({super.binaryMessenger, super.instanceManager})
      : super.detached();

  /// No orientation has been set.
  ///
  /// See https://developer.android.com/reference/android/content/res/Configuration#ORIENTATION_UNDEFINED.
  static const int orientationUndefined = 0;

  /// Portrait orientation for a device.
  ///
  /// See https://developer.android.com/reference/android/content/res/Configuration#ORIENTATION_PORTRAIT.
  static const int orientationPortrait = 1;

  /// Landscape orientation for a device.
  ///
  /// See https://developer.android.com/reference/android/content/res/Configuration#ORIENTATION_LANDSCAPE.
  static const int orientationLandscape = 2;
}
