// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// A key go router uses for its pages.
class PageKey extends LocalKey {
  /// A key go router uses for its pages.
  const PageKey({
    required this.path,
    this.count = 0,
  });

  /// The path of the page. For example:
  /// ```dart
  /// '/family/:fid'
  /// ```
  final String path;

  /// An integer that is incremented each time a new page is created. This is
  /// used to generate an unique/different key for 2 pages with the same path.
  final int count;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PageKey && other.path == path && other.count == count;
  }

  @override
  int get hashCode => Object.hash(runtimeType, path, count);

  @override
  String toString() {
    return 'PageKey($path, $count)';
  }

  /// The full path of the page. For example:
  ///
  /// ```dart
  /// '/family/:fid-p2'
  /// ```
  String get fullPath => '$path-p$count';
}
