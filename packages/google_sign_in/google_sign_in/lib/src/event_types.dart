// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../google_sign_in.dart';

export 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    show GoogleSignInException;

/// A base class for authentication event streams.
@immutable
sealed class GoogleSignInAuthenticationEvent {
  const GoogleSignInAuthenticationEvent();
}

/// A sign-in event, corresponding to an authentication flow completing
/// successfully.
@immutable
class GoogleSignInAuthenticationEventSignIn
    extends GoogleSignInAuthenticationEvent {
  /// Creates an event for a successful sign in.
  const GoogleSignInAuthenticationEventSignIn({required this.user});

  /// The user that was authenticated.
  final GoogleSignInAccount user;
}

/// A sign-out event, corresponding to a user having been signed out.
///
/// Implicit sign-outs (for example, due to server-side authentication
/// revocation, or timeouts) are not guaranteed to send events.
@immutable
class GoogleSignInAuthenticationEventSignOut
    extends GoogleSignInAuthenticationEvent {}
