// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'x_type_group.dart';

/// Configuration options for any file selector dialog.
@immutable
class FileDialogOptions {
  /// Creates a new options set with the given settings.
  const FileDialogOptions({
    this.initialDirectory,
    this.confirmButtonText,
    this.canCreateDirectories,
  });

  /// The initial directory the dialog should open with.
  final String? initialDirectory;

  /// The label for the button that confirms selection.
  final String? confirmButtonText;

  /// Whether the user is allowed to create new directories in the dialog.
  ///
  /// If null, the platform will decide the default value.
  ///
  /// May not be supported on all platforms.
  final bool? canCreateDirectories;
}

/// Configuration options to open a file.
@immutable
class OpenDialogOptions extends FileDialogOptions {
  /// Creates a new options set with the given settings.
  const OpenDialogOptions({
    super.initialDirectory,
    super.confirmButtonText,
    super.canCreateDirectories,
    this.acceptedTypeGroups,
  });

  /// A set of allowed XTypes.
  final List<XTypeGroup>? acceptedTypeGroups;
}

/// Configuration options for a save location.
@immutable
class SaveLocationOptions extends FileDialogOptions {
  /// Creates a new options set with the given settings.
  const SaveLocationOptions({
    super.initialDirectory,
    super.confirmButtonText,
    super.canCreateDirectories,
    this.acceptedTypeGroups,
    this.suggestedName,
  });

  /// A set of allowed XTypes.
  final List<XTypeGroup>? acceptedTypeGroups;

  /// The suggested name of the file to save or open.
  final String? suggestedName;
}
