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
import 'package:usage/uuid/uuid.dart';

import 'src/stack_trace.dart';
import 'src/utils.dart';
import 'src/version.dart';

export 'src/version.dart';

/// Used to provide timestamp for logging.
typedef ClockProvider = DateTime Function();

/// Logs crash reports and events to the Sentry.io service.
class SentryClient {
  /// Sentry.io client identifier for _this_ client.
  @visibleForTesting
  static const String sentryClient = '$sdkName/$sdkVersion';

  /// The default logger name used if no other value is supplied.
  static const String defaultLoggerName = 'SentryClient';

  /// Instantiates a client using [dsn] issued to your project by Sentry.io as
  /// the endpoint for submitting events.
  ///
  /// [environmentAttributes] contain event attributes that do not change over
  /// the course of a program's lifecycle. These attributes will be added to
  /// all events captured via this client. The following attributes often fall
  /// under this category: [Event.loggerName], [Event.serverName],
  /// [Event.release], [Event.environment].
  ///
  /// If [compressPayload] is `true` the outgoing HTTP payloads are compressed
  /// using gzip. Otherwise, the payloads are sent in plain UTF8-encoded JSON
  /// text. If not specified, the compression is enabled by default.
  ///
  /// If [httpClient] is provided, it is used instead of the default client to
  /// make HTTP calls to Sentry.io. This is useful in tests.
  ///
  /// If [clock] is provided, it is used to get time instead of the system
  /// clock. This is useful in tests. Should be an implementation of ClockProvider.
  /// This parameter is dynamic to maintain backwards compatibility with
  /// previous use of Clock from the Quiver library.
  ///
  /// If [uuidGenerator] is provided, it is used to generate the "event_id"
  /// field instead of the built-in random UUID v4 generator. This is useful in
  /// tests.
  factory SentryClient({
    @required String dsn,
    Event environmentAttributes,
    bool compressPayload,
    Client httpClient,
    dynamic clock,
    UuidGenerator uuidGenerator,
  }) {
    httpClient ??= new Client();
    clock ??= _getUtcDateTime;
    uuidGenerator ??= _generateUuidV4WithoutDashes;
    compressPayload ??= true;

    final ClockProvider clockProvider =
        clock is ClockProvider ? clock : clock.get;

    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');

    assert(() {
      if (uri.pathSegments.isEmpty)
        throw new ArgumentError(
            'Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    }());

    final String publicKey = userInfo[0];
    final String secretKey = userInfo.length >= 2 ? userInfo[1] : null;
    final String projectId = uri.pathSegments.last;

    return new SentryClient._(
      httpClient: httpClient,
      clock: clockProvider,
      uuidGenerator: uuidGenerator,
      environmentAttributes: environmentAttributes,
      dsnUri: uri,
      publicKey: publicKey,
      secretKey: secretKey,
      projectId: projectId,
      compressPayload: compressPayload,
    );
  }

  SentryClient._({
    @required Client httpClient,
    @required ClockProvider clock,
    @required UuidGenerator uuidGenerator,
    @required this.environmentAttributes,
    @required this.dsnUri,
    @required this.publicKey,
    this.secretKey,
    @required this.compressPayload,
    @required this.projectId,
  })  : _httpClient = httpClient,
        _clock = clock,
        _uuidGenerator = uuidGenerator;

  final Client _httpClient;
  final ClockProvider _clock;
  final UuidGenerator _uuidGenerator;

  /// Contains [Event] attributes that are automatically mixed into all events
  /// captured through this client.
  ///
  /// This event is designed to contain static values that do not change from
  /// event to event, such as local operating system version, the version of
  /// Dart/Flutter SDK, etc. These attributes have lower precedence than those
  /// supplied in the even passed to [capture].
  final Event environmentAttributes;

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

  /// Information about the current user.
  ///
  /// This information is sent with every logged event. If the value
  /// of this field is updated, all subsequent events will carry the
  /// new information.
  ///
  /// [Event.userContext] overrides the [User] context set here.
  ///
  /// See also:
  /// * https://docs.sentry.io/learn/context/#capturing-the-user
  User userContext;

  @visibleForTesting
  String get postUri =>
      '${dsnUri.scheme}://${dsnUri.host}/api/$projectId/store/';

  /// Reports an [event] to Sentry.io.
  Future<SentryResponse> capture({@required Event event}) async {
    final DateTime now = _clock();
    String authHeader = 'Sentry sentry_version=6, sentry_client=$sentryClient, '
        'sentry_timestamp=${now.millisecondsSinceEpoch}, sentry_key=$publicKey';
    if (secretKey != null) {
      authHeader += ', sentry_secret=$secretKey';
    }

    final Map<String, String> headers = <String, String>{
      'User-Agent': '$sentryClient',
      'Content-Type': 'application/json',
      'X-Sentry-Auth': authHeader,
    };

    final Map<String, dynamic> data = <String, dynamic>{
      'project': projectId,
      'event_id': _uuidGenerator(),
      'timestamp': formatDateAsIso8601WithSecondPrecision(now),
      'logger': defaultLoggerName,
    };

    if (environmentAttributes != null)
      mergeAttributes(environmentAttributes.toJson(), into: data);

    // Merge the user context.
    if (userContext != null) {
      mergeAttributes({'user': userContext.toJson()}, into: data);
    }
    mergeAttributes(event.toJson(), into: data);

    List<int> body = utf8.encode(json.encode(data));
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

    final String eventId = json.decode(response.body)['id'];
    return new SentryResponse.success(eventId: eventId);
  }

  /// Reports the [exception] and optionally its [stackTrace] to Sentry.io.
  Future<SentryResponse> captureException({
    @required dynamic exception,
    dynamic stackTrace,
  }) {
    final Event event = new Event(
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
  const SentryResponse.success({@required this.eventId})
      : isSuccessful = true,
        error = null;

  const SentryResponse.failure(this.error)
      : isSuccessful = false,
        eventId = null;

  /// Whether event was submitted successfully.
  final bool isSuccessful;

  /// The ID Sentry.io assigned to the submitted event for future reference.
  final String eventId;

  /// Error message, if the response is not successful.
  final String error;
}

typedef UuidGenerator = String Function();

String _generateUuidV4WithoutDashes() =>
    new Uuid().generateV4().replaceAll('-', '');

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

/// Sentry does not take a timezone and instead expects the date-time to be
/// submitted in UTC timezone.
DateTime _getUtcDateTime() => new DateTime.now().toUtc();

/// An event to be reported to Sentry.io.
@immutable
class Event {
  /// Refers to the default fingerprinting algorithm.
  ///
  /// You do not need to specify this value unless you supplement the default
  /// fingerprint with custom fingerprints.
  static const String defaultFingerprint = '{{ default }}';

  /// Creates an event.
  const Event({
    this.loggerName,
    this.serverName,
    this.release,
    this.environment,
    this.message,
    this.exception,
    this.stackTrace,
    this.level,
    this.culprit,
    this.tags,
    this.extra,
    this.fingerprint,
    this.userContext,
  });

  /// The logger that logged the event.
  final String loggerName;

  /// Identifies the server that logged this event.
  final String serverName;

  /// The version of the application that logged the event.
  final String release;

  /// The environment that logged the event, e.g. "production", "staging".
  final String environment;

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

  /// Information about the current user.
  ///
  /// The value in this field overrides the user context
  /// set in [SentryClient.userContext] for this logged event.
  final User userContext;

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
      'platform': sdkPlatform,
      'sdk': {
        'version': sdkVersion,
        'name': sdkName,
      },
    };

    if (loggerName != null) json['logger'] = loggerName;

    if (serverName != null) json['server_name'] = serverName;

    if (release != null) json['release'] = release;

    if (environment != null) json['environment'] = environment;

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
      json['stacktrace'] = <String, dynamic>{
        'frames': encodeStackTrace(stackTrace),
      };
    }

    if (level != null) json['level'] = level.name;

    if (culprit != null) json['culprit'] = culprit;

    if (tags != null && tags.isNotEmpty) json['tags'] = tags;

    if (extra != null && extra.isNotEmpty) json['extra'] = extra;

    Map<String, dynamic> userContextMap;
    if (userContext != null &&
        (userContextMap = userContext.toJson()).isNotEmpty)
      json['user'] = userContextMap;

    if (fingerprint != null && fingerprint.isNotEmpty)
      json['fingerprint'] = fingerprint;

    return json;
  }
}

/// Describes the current user associated with the application, such as the
/// currently signed in user.
///
/// The user can be specified globally in the [SentryClient.userContext] field,
/// or per event in the [Event.userContext] field.
///
/// You should provide at least either an [id] (a unique identifier for an
/// authenticated user) or [ipAddress] (their IP address).
///
/// Conforms to the User Interface contract for Sentry
/// https://docs.sentry.io/clientdev/interfaces/user/.
///
/// The outgoing JSON representation is:
///
/// ```
/// "user": {
///   "id": "unique_id",
///   "username": "my_user",
///   "email": "foo@example.com",
///   "ip_address": "127.0.0.1",
///   "subscription": "basic"
/// }
/// ```
class User {
  /// A unique identifier of the user.
  final String id;

  /// The username of the user.
  final String username;

  /// The email address of the user.
  final String email;

  /// The IP of the user.
  final String ipAddress;

  /// Any other user context information that may be helpful.
  ///
  /// These keys are stored as extra information but not specifically processed
  /// by Sentry.
  final Map<String, dynamic> extras;

  /// At a minimum you must set an [id] or an [ipAddress].
  const User({this.id, this.username, this.email, this.ipAddress, this.extras})
      : assert(id != null || ipAddress != null);

  /// Produces a [Map] that can be serialized to JSON.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "ip_address": ipAddress,
      "extras": extras,
    };
  }
}
