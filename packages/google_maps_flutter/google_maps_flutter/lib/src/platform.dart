// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Correctly exposes `Platform.isAndroid` without causing web detection issues.
library;

export 'platform_web.dart' if (dart.library.io) 'platform_io.dart';
