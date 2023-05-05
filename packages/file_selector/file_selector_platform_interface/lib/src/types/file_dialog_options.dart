// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

@immutable
class FileDialogOptions {
  const FileDialogOptions(
      {this.initialDirectory, this.suggestedName, this.confirmButtonText});
  final String? initialDirectory;
  final String? suggestedName;
  final String? confirmButtonText;
}
