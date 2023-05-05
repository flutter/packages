// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'x_type_group/x_type_group.dart';

export 'x_type_group/x_type_group.dart';

@immutable
class FileSaveLocationResult {
  const FileSaveLocationResult(this.path, {this.activeFilter});
  final String path;
  final XTypeGroup? activeFilter;
}
