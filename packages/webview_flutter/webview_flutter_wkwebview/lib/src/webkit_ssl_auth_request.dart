// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'common/web_kit.g.dart';

class WebKitSslAuthRequest extends PlatformSslAuthRequest {
  WebKitSslAuthRequest._({
    required super.certificates,
    required SecTrust trust,
    required this.host,
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

  final String host;

  static Future<WebKitSslAuthRequest> fromTrust({
    required SecTrust trust,
    required String host,
    required void Function(
      UrlSessionAuthChallengeDisposition disposition,
      Map<String, Object?>? credentialMap,
    ) onResponse,
  }) async {
    // Converts a list native certificate objects to a list of platform
    // interface certificates.
    Future<List<SslCertificate>> fromNativeCertificates(
      List<SecCertificate> certificates, [
      List<SslError> errors = const <SslError>[],
    ]) async {
      return <SslCertificate>[
        for (final SecCertificate certificate in certificates)
          SslCertificate(
            data: await SecCertificate.copyData(certificate),
            errors: errors,
          ),
      ];
    }

    try {
      final bool trusted = await SecTrust.evaluateWithError(trust);

      // Since this is expected to be an auth request for an invalid
      // certificate, the method above is expected to throw with an error
      // message. However, this handles the scenario where the certificate is
      // valid or doesn't throw just in case.
      final List<SecCertificate> certificates =
          (await SecTrust.copyCertificateChain(trust)) ?? <SecCertificate>[];
      if (trusted) {
        return WebKitSslAuthRequest._(
          certificates: await fromNativeCertificates(certificates),
          trust: trust,
          host: host,
          onResponse: onResponse,
        );
      } else {
        return WebKitSslAuthRequest._(
          certificates: await fromNativeCertificates(
            certificates,
            <SslError>[
              const SslError(
                description: 'Certificate failed evaluation.',
              )
            ],
          ),
          trust: trust,
          host: host,
          onResponse: onResponse,
        );
      }
    } on PlatformException catch (exception) {
      final List<SecCertificate> certificates =
          (await SecTrust.copyCertificateChain(trust)) ?? <SecCertificate>[];

      return WebKitSslAuthRequest._(
        certificates: await fromNativeCertificates(
          certificates,
          <SslError>[
            SslError(
              description: '${exception.code}: ${exception.message ?? ''}',
            )
          ],
        ),
        trust: trust,
        host: host,
        onResponse: onResponse,
      );
    }
  }

  @override
  Future<void> cancel() async {
    _onResponse(
      UrlSessionAuthChallengeDisposition.cancelAuthenticationChallenge,
      null,
    );
  }

  @override
  Future<void> proceed() async {
    _onResponse(
      UrlSessionAuthChallengeDisposition.useCredential,
      <String, Object?>{'serverTrust': _trust},
    );
  }
}
