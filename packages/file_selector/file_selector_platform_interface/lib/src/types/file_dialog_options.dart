// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

/// Configuration options for any file selector dialog.
@immutable
class FileDialogOptions {
  /// Creates a new options set with the given settings.
  const FileDialogOptions({this.initialDirectory, this.confirmButtonText});

  /// The initial directory the dialog should open with.
  final String? initialDirectory;

  /// The label for the button that confirms selection.
  final String? confirmButtonText;
}

/// Configuration options for a save dialog.
@immutable
class SaveDialogOptions extends FileDialogOptions {
  /// Creates a new options set with the given settings.
  const SaveDialogOptions(
      {super.initialDirectory, super.confirmButtonText, this.suggestedName});

  /// The suggested name of the file to save or open.
  final String? suggestedName;
}
