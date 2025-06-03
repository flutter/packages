// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(dit): Remove this, https://github.com/flutter/flutter/issues/144286

export 'lost_data.dart';
export 'unsupported.dart'
    if (dart.library.js_interop) 'html.dart'
    if (dart.library.io) 'io.dart';
