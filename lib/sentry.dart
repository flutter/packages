// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';
import 'package:usage/uuid/uuid.dart';

import 'src/version.dart';
export 'src/version.dart' show sdkVersion;

/// Logs crash reports and events to the Sentry.io service.
class SentryClient {

  /// The name of the SDK used to submit events, i.e. _this_ SDK.
  @visibleForTesting
  static const String sdkName = 'dart';

  /// Sentry.io client identifier for _this_ client.
  @visibleForTesting
  static const String sentryClient = '$sdkName/$sdkVersion';

  /// Instantiates a client using [dns] issued to your project by Sentry.io as
  /// the endpoint for submitting events.
  ///
  /// If [httpClient] is provided, it is used instead of the default client to
  /// make HTTP calls to Sentry.io.
  ///
  /// If [clock] is provided, it is used instead of the system clock.
  factory SentryClient({@required String dsn, Client httpClient, Clock clock, UuidGenerator uuidGenerator}) {
    httpClient ??= new Client();
    clock ??= const Clock();
    uuidGenerator ??= _generateUuidV4WithoutDashes;

    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');

    assert(() {
      if (userInfo.length != 2)
        throw new ArgumentError('Colon-separated publicKey:secretKey pair not found in the user info field of the DSN URI: $dsn');

      if (uri.pathSegments.isEmpty)
        throw new ArgumentError('Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    });

    final String publicKey = userInfo.first;
    final String secretKey = userInfo.last;
    final String projectId = uri.pathSegments.last;

    return new SentryClient._(
      httpClient,
      clock,
      uuidGenerator,
      uri,
      publicKey,
      secretKey,
      projectId,
    );
  }

  SentryClient._(this._httpClient, this._clock, this._uuidGenerator, this.dsnUri, this.publicKey, this.secretKey, this.projectId);

  final Clock _clock;
  final Client _httpClient;
  final UuidGenerator _uuidGenerator;

  /// The DSN URI.
  @visibleForTesting
  final Uri dsnUri;

  /// The Sentry.io public key for the project.
  @visibleForTesting
  final String publicKey;

  /// The Sentry.io secret key for the project.
  @visibleForTesting
  final String secretKey;

  /// The Sentry.io project identifier.
  @visibleForTesting
  final String projectId;

  @visibleForTesting
  String get postUri => '${dsnUri.scheme}://${dsnUri.host}/api/$projectId/store/';

  /// Reports the [exception] and optionally its [stackTrace] to Sentry.io.
  Future<SentryResponse> captureException({
    @required dynamic exception,
    dynamic stackTrace,
  }) async {
    final DateTime now = _clock.now();
    final Map<String, String> headers = <String, String> {
      'User-Agent': '$sentryClient',
      'Content-Type': 'application/json',
      'X-Sentry-Auth': 'Sentry sentry_version=6, '
          'sentry_client=$sentryClient, '
          'sentry_timestamp=${now.millisecondsSinceEpoch}, '
          'sentry_key=$publicKey, '
          'sentry_secret=$secretKey',
    };

    final String body = JSON.encode({
      'project': projectId,
      'event_id': _uuidGenerator(),
      'timestamp': now.toIso8601String(),
      'message': '$exception',
      'platform': 'dart',
      'exception': [{
        'type': '${exception.runtimeType}',
        'value': '$exception',
      }],
      'sdk': {
        'version': sdkVersion,
        'name': sdkName,
      },
    });

    final Response response = await _httpClient.post(postUri, headers: headers, body: body);

    if (response.statusCode != 200) {
      return new SentryResponse.failure('Server responded with HTTP ${response.statusCode}');
    }

    final String eventId = JSON.decode(response.body)['id'];
    return new SentryResponse.success(eventId: eventId);
  }

  Future<Null> close() async {
    _httpClient.close();
  }

  @override
  String toString() => '$SentryClient("$postUri")';
}

class SentryResponse {
  SentryResponse.success({@required eventId})
      : isSuccessful = true,
        eventId = eventId,
        error = null;

  SentryResponse.failure(error)
      : isSuccessful = false,
        eventId = null,
        error = error;

  /// Whether event was submitted successfully.
  final bool isSuccessful;

  /// The ID Sentry.io assigned to the submitted event for future reference.
  final String eventId;

  /// Error message, if the response is not successful.
  final String error;
}

typedef UuidGenerator = String Function();

String _generateUuidV4WithoutDashes() {
  return new Uuid().generateV4().replaceAll('-', '');
}

/// Severity of the logged [Event].
enum SeverityLevel {
  fatal,
  error,
  warning,
  info,
  debug,
}

class Event {
  static const String _defaultFingerprint = '{{ default }}';

  Event({
    @required projectId,
    @required String eventId,
    @required DateTime timestamp,
    @required String logger,
    @required String platform,
    SeverityLevel level,
    String culprit,
    String serverName,
    String release,
    Map<String, String> tags,
    String environment,
    Map<String, String> modules,
    Map<String, dynamic> extra,
    List<String> fingerprint,
  });
}
