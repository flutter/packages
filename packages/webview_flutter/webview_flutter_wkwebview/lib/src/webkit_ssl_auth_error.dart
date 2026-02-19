// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'common/web_kit.g.dart';

/// An implementation of [PlatformSslAuthError] with the WebKit api.
class WebKitSslAuthError extends PlatformSslAuthError {
  /// Creates a [WebKitSslAuthError].
  @internal
  WebKitSslAuthError({
    required super.certificate,
    required super.description,
    required SecTrust trust,
    required this.host,
    required this.port,
    required Future<void> Function(
      UrlSessionAuthChallengeDisposition disposition,
      URLCredential? credential,
    )
    onResponse,
  }) : _trust = trust,
       _onResponse = onResponse;

  final SecTrust _trust;

  final Future<void> Function(
    UrlSessionAuthChallengeDisposition disposition,
    URLCredential? credential,
  )
  _onResponse;

  /// The host portion of the url associated with the error.
  final String host;

  /// The port portion of the url associated with the error.
  final int port;

  @override
  Future<void> cancel() async {
    await _onResponse(
      UrlSessionAuthChallengeDisposition.cancelAuthenticationChallenge,
      null,
    );
  }

  @override
  Future<void> proceed() async {
    final Uint8List? exceptions = await SecTrust.copyExceptions(_trust);
    if (exceptions != null) {
      await SecTrust.setExceptions(_trust, exceptions);
    }

    await _onResponse(
      UrlSessionAuthChallengeDisposition.useCredential,
      await URLCredential.serverTrustAsync(_trust),
    );
  }
}
