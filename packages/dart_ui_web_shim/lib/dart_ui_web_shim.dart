// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This file shims dart:ui in web-only scenarios, getting rid of the need to
/// suppress analyzer warnings.

// TODO(dit): flutter/flutter#55000 Remove this package once web-only dart:ui
// APIs are exposed from a dedicated place.
export 'src/dart_ui_fake.dart' if (dart.library.html) 'src/dart_ui_real.dart';
