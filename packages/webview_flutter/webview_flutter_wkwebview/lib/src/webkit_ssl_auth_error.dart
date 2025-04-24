// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'common/web_kit.g.dart';

class WebKitSslAuthError extends PlatformSslAuthError {
  WebKitSslAuthError({
    required super.certificate,
    required super.description,
    required SecTrust trust,
    required this.host,
    required this.port,
    required void Function(
      UrlSessionAuthChallengeDisposition disposition,
      Map<String, Object?>? credentialMap,
    ) onResponse,
  })  : _trust = trust,
        _onResponse = onResponse;

  final SecTrust _trust;

  final void Function(
    UrlSessionAuthChallengeDisposition disposition,
    Map<String, Object?>? credentialMap,
  ) _onResponse;

  /// The host portion of the url associated with the error.
  final String host;

  /// The port portion of the url associated with the error.
  final int port;

  @override
  Future<void> cancel() async {
    _onResponse(
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
    _onResponse(
      UrlSessionAuthChallengeDisposition.useCredential,
      <String, Object?>{'serverTrust': _trust},
    );
  }
}
