// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../types/http_auth_request.dart';

/// Defines the response parameters of a pending [HttpAuthRequest] received by
/// the webview.
@immutable
class WebViewCredential {
  /// Creates a [WebViewCredential].
  const WebViewCredential({required this.user, required this.password});

  /// The user name.
  final String user;

  /// The password.
  final String password;
}
