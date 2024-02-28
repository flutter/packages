// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Methods here are documented in the Google Identity authentication website,
// but they don't really belong to either the authentication nor authorization
// libraries.
@JS()
library id_load_callback;

import 'dart:js_interop';

import 'shared.dart';

/*
// Library load callback: onGoogleLibraryLoad
// https://developers.google.com/identity/gsi/web/reference/js-reference#onGoogleLibraryLoad
*/

@JS('onGoogleLibraryLoad')
@staticInterop
external set _onGoogleLibraryLoad(JSFunction callback);

/// Method called after the Sign In With Google JavaScript library is loaded.
///
/// The [callback] parameter must be manually wrapped in [allowInterop]
/// before being set to the [onGoogleLibraryLoad] property.
set onGoogleLibraryLoad(VoidFn function) {
  _onGoogleLibraryLoad = function.toJS;
}
