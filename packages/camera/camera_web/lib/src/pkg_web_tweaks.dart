// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'shims/dart_js_util.dart';

final JsUtil _jsUtil = JsUtil();

/// Adds safe helper getters to [web.MediaTrackSupportedConstraints].
extension NonStandardFieldsOnMediaTrackSupportedConstraints on web.MediaTrackSupportedConstraints {
  /// Returns the zoom constraint support or null if not present on the JS object.
  bool? get zoomNullable => _jsUtil.hasProperty(this, 'zoom'.toJS) ? zoom : null;

  /// Returns the torch constraint support or null if not present on the JS object.
  bool? get torchNullable => _jsUtil.hasProperty(this, 'torch'.toJS) ? torch : null;

  /// Returns the facingMode constraint support or null if not present on the JS object.
  bool? get facingModeNullable => _jsUtil.hasProperty(this, 'facingMode'.toJS) ? facingMode : null;
}

/// Adds safe helper getters to [web.MediaTrackCapabilities].
extension NonStandardFieldsOnMediaTrackCapabilities on web.MediaTrackCapabilities {
  /// Returns the zoom capability range or null if not present on the JS object.
  web.MediaSettingsRange? get zoomNullable => _jsUtil.hasProperty(this, 'zoom'.toJS) ? zoom : null;

  /// Returns the torch capability array or null if not present on the JS object.
  JSArray<JSBoolean>? get torchNullable => _jsUtil.hasProperty(this, 'torch'.toJS) ? torch : null;

  /// Returns the facingMode capability array or null if not present on the JS object or not a [JSArray].
  JSArray<JSString>? get facingModeNullable {
    if (!_jsUtil.hasProperty(this, 'facingMode'.toJS)) {
      return null;
    }
    final JSAny? val = _jsUtil.getProperty(this, 'facingMode'.toJS);
    if (val != null && val.isA<JSArray>()) {
      return val as JSArray<JSString>;
    }
    return null;
  }
}

/// Adds safe helper getters to [web.MediaTrackSettings].
extension NonStandardFieldsOnMediaTrackSettings on web.MediaTrackSettings {
  /// Returns the facingMode setting or null if not present on the JS object.
  String? get facingModeNullable =>
      _jsUtil.hasProperty(this, 'facingMode'.toJS) ? facingMode : null;
}
