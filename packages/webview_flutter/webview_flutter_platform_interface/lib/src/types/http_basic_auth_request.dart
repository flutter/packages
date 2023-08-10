// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines the parameters of a pending HTTP basic authentication request.
class HttpBasicAuthRequest {
  /// Creates a [HttpBasicAuthRequest].
  const HttpBasicAuthRequest({
    required this.onProceed,
    required this.onCancel,
    required this.host,
    required this.realm,
  });

  /// The callback to authenticate.
  final void Function(String username, String password) onProceed;

  /// The callback to cancel authentication.
  final void Function() onCancel;

  /// The host requiring authentication.
  final String host;

  /// The realm requiring authentication.
  final String realm;
}
