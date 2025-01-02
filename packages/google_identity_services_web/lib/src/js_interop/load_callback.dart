// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Methods here are documented in the Google Identity authentication website,
// but they don't really belong to either the authentication nor authorization
// libraries.

import 'dart:js_interop';

import 'shared.dart';

/*
// Library load callback: onGoogleLibraryLoad
// https://developers.google.com/identity/gsi/web/reference/js-reference#onGoogleLibraryLoad
*/

@JS('onGoogleLibraryLoad')
external set _onGoogleLibraryLoad(JSFunction callback);

/// Method called after the Sign In With Google JavaScript library is loaded.
///
/// The [function] parameter must be a Dart function and not a JS function.
set onGoogleLibraryLoad(VoidFn function) {
  _onGoogleLibraryLoad = function.toJS;
}
