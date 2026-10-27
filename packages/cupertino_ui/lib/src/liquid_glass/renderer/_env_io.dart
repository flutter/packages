// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// True if running in a test environment.
final bool isTestEnvironment = Platform.environment.containsKey('FLUTTER_TEST');
