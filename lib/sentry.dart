// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry;

import 'package:meta/meta.dart';

/// Logs crash reports and events to the Sentry.io service.
class SentryClient {

  /// Instantiates a client from a [dns] issued to your project by Sentry.io.
  factory SentryClient({@required String dsn}) {
    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');
    assert(() {
      if (userInfo.length != 2)
        throw new ArgumentError('Colon-separated publicKey:secretKey pair not found in the user info field of the DSN URI: $dsn');

      if (uri.pathSegments.isEmpty)
        throw new ArgumentError('Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    });

    final String host = uri.host;
    final String publicKey = userInfo.first;
    final String secretKey = userInfo.last;
    final String projectId = uri.pathSegments.last;

    return new SentryClient._(
      '${uri.scheme}://$host/api/$projectId/store',
      publicKey,
      secretKey,
      projectId,
    );
  }

  SentryClient._(this.postUri, this.publicKey, this.secretKey, this.projectId);

  /// The URI where this client sends events via HTTP POST.
  @visibleForTesting
  final String postUri;

  /// The Sentry.io public key for the project.
  @visibleForTesting
  final String publicKey;

  /// The Sentry.io secret key for the project.
  @visibleForTesting
  final String secretKey;

  /// The Sentry.io project identifier.
  @visibleForTesting
  final String projectId;
}
