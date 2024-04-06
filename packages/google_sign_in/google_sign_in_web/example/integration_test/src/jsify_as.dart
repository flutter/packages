// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

/// Converts a [data] object into a JS Object of type `T`.
T jsifyAs<T>(Map<String, Object?> data) {
  return data.jsify() as T;
}
