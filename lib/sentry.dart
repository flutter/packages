// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry;

import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:usage/uuid/uuid.dart';

import 'src/stack_trace.dart';
import 'src/version.dart';

export 'src/version.dart';

/// Logs crash reports and events to the Sentry.io service.
class SentryClient {
  /// Sentry.io client identifier for _this_ client.
  @visibleForTesting
  static const String sentryClient = '$sdkName/$sdkVersion';

  /// The default logger name used if no other value is supplied.
  static const String defaultLoggerName = 'SentryClient';

  /// Instantiates a client using [dns] issued to your project by Sentry.io as
  /// the endpoint for submitting events.
  ///
  /// If [loggerName] is provided, it is used instead of [defaultLoggerName].
  ///
  /// If [httpClient] is provided, it is used instead of the default client to
  /// make HTTP calls to Sentry.io.
  ///
  /// If [clock] is provided, it is used to get time instead of the system
  /// clock.
  factory SentryClient({
    @required String dsn,
    String loggerName,
    Client httpClient,
    Clock clock,
    UuidGenerator uuidGenerator,
    bool compressPayload,
    String serverName,
    String release,
    String environment,
  }) {
    httpClient ??= new Client();
    clock ??= const Clock();
    uuidGenerator ??= _generateUuidV4WithoutDashes;
    loggerName ??= defaultLoggerName;
    compressPayload ??= true;

    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');

    assert(() {
      if (userInfo.length != 2)
        throw new ArgumentError(
            'Colon-separated publicKey:secretKey pair not found in the user info field of the DSN URI: $dsn');

      if (uri.pathSegments.isEmpty)
        throw new ArgumentError(
            'Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    });

    final String publicKey = userInfo.first;
    final String secretKey = userInfo.last;
    final String projectId = uri.pathSegments.last;

    return new SentryClient._(
      httpClient: httpClient,
      clock: clock,
      uuidGenerator: uuidGenerator,
      dsnUri: uri,
      publicKey: publicKey,
      secretKey: secretKey,
      projectId: projectId,
      loggerName: loggerName,
      compressPayload: compressPayload,
      serverName: serverName,
      release: release,
      environment: environment,
    );
  }

  SentryClient._({
    @required Client httpClient,
    @required Clock clock,
    @required UuidGenerator uuidGenerator,
    @required this.dsnUri,
    @required this.publicKey,
    @required this.secretKey,
    @required this.compressPayload,
    @required this.projectId,
    @required this.loggerName,
    @required this.serverName,
    @required this.release,
    @required this.environment,
  })
      : _httpClient = httpClient,
        _clock = clock,
        _uuidGenerator = uuidGenerator;

  final Client _httpClient;
  final Clock _clock;
  final UuidGenerator _uuidGenerator;

  /// Whether to compress payloads sent to Sentry.io.
  final bool compressPayload;

  /// The DSN URI.
  @visibleForTesting
  final Uri dsnUri;

  /// The Sentry.io public key for the project.
  @visibleForTesting
  final String publicKey;

  /// The Sentry.io secret key for the project.
  @visibleForTesting
  final String secretKey;

  /// The ID issued by Sentry.io to your project.
  ///
  /// Attached to the event payload.
  final String projectId;

  /// The logger that logged the event.
  ///
  /// Attached to the event payload.
  ///
  /// If not specified [SentryClient.defaultLoggerName] is used.
  final String loggerName;

  /// Identifies the server that logged this event.
  final String serverName;

  /// The version of the application that logged the event.
  final String release;

  /// The environment that logged the event, e.g. "production", "staging".
  final String environment;

  @visibleForTesting
  String get postUri =>
      '${dsnUri.scheme}://${dsnUri.host}/api/$projectId/store/';

  /// Reports an [event] to Sentry.io.
  Future<SentryResponse> capture({@required Event event}) async {
    final DateTime now = _clock.now();
    final Map<String, String> headers = <String, String>{
      'User-Agent': '$sentryClient',
      'Content-Type': 'application/json',
      'X-Sentry-Auth': 'Sentry sentry_version=6, '
          'sentry_client=$sentryClient, '
          'sentry_timestamp=${now.millisecondsSinceEpoch}, '
          'sentry_key=$publicKey, '
          'sentry_secret=$secretKey',
    };

    Map<String, dynamic> json = <String, dynamic>{
      'project': projectId,
    };
    json['logger'] = loggerName ?? SentryClient.defaultLoggerName;
    if (serverName != null) json['server_name'] = serverName;
    if (release != null) json['release'] = release;
    if (environment != null) json['environment'] = environment;
    json.addAll(event.toJson());

    List<int> body = UTF8.encode(JSON.encode(json));
    if (compressPayload) {
      headers['Content-Encoding'] = 'gzip';
      body = GZIP.encode(body);
    }

    final Response response =
        await _httpClient.post(postUri, headers: headers, body: body);

    if (response.statusCode != 200) {
      String errorMessage =
          'Sentry.io responded with HTTP ${response.statusCode}';
      if (response.headers['x-sentry-error'] != null)
        errorMessage += ': ${response.headers['x-sentry-error']}';
      return new SentryResponse.failure(errorMessage);
    }

    final String eventId = JSON.decode(response.body)['id'];
    return new SentryResponse.success(eventId: eventId);
  }

  /// Reports the [exception] and optionally its [stackTrace] to Sentry.io.
  Future<SentryResponse> captureException({
    @required dynamic exception,
    dynamic stackTrace,
  }) {
    final Event event = new Event(
      eventId: _uuidGenerator(),
      timestamp: _clock.now(),
      exception: exception,
      stackTrace: stackTrace,
    );
    return capture(event: event);
  }

  Future<Null> close() async {
    _httpClient.close();
  }

  @override
  String toString() => '$SentryClient("$postUri")';
}

/// A response from Sentry.io.
///
/// If [isSuccessful] the [eventId] field will contain the ID assigned to the
/// captured event by the Sentry.io backend. Otherwise, the [error] field will
/// contain the description of the error.
@immutable
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
@immutable
class SeverityLevel {
  static const fatal = const SeverityLevel._('fatal');
  static const error = const SeverityLevel._('error');
  static const warning = const SeverityLevel._('warning');
  static const info = const SeverityLevel._('info');
  static const debug = const SeverityLevel._('debug');

  const SeverityLevel._(this.name);

  /// API name of the level as it is encoded in the JSON protocol.
  final String name;
}

/// An event to be reported to Sentry.io.
@immutable
class Event {
  /// Refers to the default fingerprinting algorithm.
  ///
  /// You do not need to specify this value unless you supplement the default
  /// fingerprint with custom fingerprints.
  static const String defaultFingerprint = '{{ default }}';

  /// Creates an event.
  Event({
    @required this.eventId,
    @required this.timestamp,
    this.message,
    this.exception,
    this.stackTrace,
    this.level,
    this.culprit,
    this.tags,
    this.extra,
    this.fingerprint,
  });

  /// A 32-character long UUID v4 value without dashes.
  final String eventId;

  /// The time the event happened.
  final DateTime timestamp;

  /// Event message.
  ///
  /// Generally an event either contains a [message] or an [exception].
  final String message;

  /// An object that was thrown.
  ///
  /// It's `runtimeType` and `toString()` are logged. If this behavior is
  /// undesirable, consider using a custom formatted [message] instead.
  final dynamic exception;

  /// The stack trace corresponding to the thrown [exception].
  ///
  /// Can be `null`, a [String], or a [StackTrace].
  final dynamic stackTrace;

  /// How important this event is.
  final SeverityLevel level;

  /// What caused this event to be logged.
  final String culprit;

  /// Name/value pairs that events can be searched by.
  final Map<String, String> tags;

  /// Arbitrary name/value pairs attached to the event.
  ///
  /// Sentry.io docs do not talk about restrictions on the values, other than
  /// they must be JSON-serializable.
  final Map<String, dynamic> extra;

  /// Used to deduplicate events by grouping ones with the same fingerprint
  /// together.
  ///
  /// If not specified a default deduplication fingerprint is used. The default
  /// fingerprint may be supplemented by additional fingerprints by specifying
  /// multiple values. The default fingerprint can be specified by adding
  /// [defaultFingerprint] to the list in addition to your custom values.
  ///
  /// Examples:
  ///
  ///     // A completely custom fingerprint:
  ///     var custom = ['foo', 'bar', 'baz'];
  ///     // A fingerprint that supplements the default one with value 'foo':
  ///     var supplemented = [Event.defaultFingerprint, 'foo'];
  final List<String> fingerprint;

  /// Serializes this event to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'event_id': eventId,
      'timestamp': timestamp.toIso8601String(),
      'platform': sdkPlatform,
      'sdk': {
        'version': sdkVersion,
        'name': sdkName,
      },
    };

    if (message != null) json['message'] = message;

    if (exception != null) {
      json['exception'] = [
        <String, dynamic>{
          'type': '${exception.runtimeType}',
          'value': '$exception',
        }
      ];
    }

    if (stackTrace != null) {
      assert(stackTrace is String || stackTrace is StackTrace);
      final Trace trace = stackTrace is StackTrace
          ? new Trace.from(stackTrace)
          : new Trace.parse(stackTrace);

      json['stacktrace'] = <String, dynamic>{
        'frames': trace.frames.map(stackTraceFrameToJsonFrame).toList(),
      };
    }

    if (level != null) json['level'] = level.name;

    if (culprit != null) json['culprit'] = culprit;

    if (tags != null && tags.isNotEmpty) json['tags'] = tags;

    if (extra != null && extra.isNotEmpty) json['extra'] = extra;

    if (fingerprint != null && fingerprint.isNotEmpty)
      json['fingerprint'] = fingerprint;

    return json;
  }
}
