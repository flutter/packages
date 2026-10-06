// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'x_type_group.dart';

/// The response from a save dialog.
@immutable
class FileSaveLocation {
  /// Creates a result with the given [path] and optional other dialog state.
  const FileSaveLocation(this.file, {this.activeFilter});

  /// The file to save to.
  final XFile file;

  /// The currently active filter group, if any.
  ///
  /// This is null on platforms that do not support user-selectable filter
  /// groups in save dialogs (for example, macOS), or when no filter groups
  /// were provided when showing the dialog.
  final XTypeGroup? activeFilter;
}
