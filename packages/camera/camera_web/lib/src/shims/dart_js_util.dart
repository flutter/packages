// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// A utility that shims dart:js_interop to manipulate JavaScript interop objects.
class JsUtil {
  /// Returns true if the object [o] has the property [name].
  bool hasProperty(JSObject o, JSAny name) => o.hasProperty(name).toDart;

  /// Returns the value of the property [name] in the object [o].
  JSAny? getProperty(JSObject o, JSAny name) => o.getProperty(name);
}
