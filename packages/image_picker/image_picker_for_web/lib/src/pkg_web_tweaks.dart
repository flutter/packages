// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart' as web;

/// Adds a `toList` method to [web.FileList] objects.
extension WebFileListToDartList on web.FileList {
  /// Converts a [web.FileList] into a [List] of [web.File].
  ///
  /// This method makes a copy.
  List<web.File> get toList =>
      <web.File>[for (int i = 0; i < length; i++) item(i)!];
}
