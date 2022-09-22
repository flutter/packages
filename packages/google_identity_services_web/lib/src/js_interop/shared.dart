// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The type of several functions from the library, that don't receive
/// parameters nor return anything.
typedef VoidFn = void Function();

/*
// Enum: UX Mode
// https://developers.google.com/identity/gsi/web/reference/js-reference#ux_mode
// Used both by `oauth2.initCodeClient` and `id.initialize`.
*/

/// Use this enum to set the UX flow used by the Sign In With Google button.
/// The default value is [popup].
///
/// This attribute has no impact on the OneTap UX.
enum UxMode {
  /// Performs sign-in UX flow in a pop-up window.
  popup('popup'),
  /// Performs sign-in UX flow by a full page redirection.
  redirect('redirect');

  ///
  const UxMode(String uxMode) : _uxMode = uxMode;
  final String _uxMode;

  @override
  String toString() => _uxMode;
}
