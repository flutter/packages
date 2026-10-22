// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

/// The file name of the currently running executable.
///
/// Used as the fallback application name by the about dialog widgets when
/// no `Title` ancestor is available.
String get executableName => Platform.resolvedExecutable.split(Platform.pathSeparator).last;
