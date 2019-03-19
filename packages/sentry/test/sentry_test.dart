// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart';
import 'package:sentry/sentry.dart';
import 'package:test/test.dart';

const String _testDsn = 'https://public:secret@sentry.example.com/1';
const String _testDsnWithoutSecret = 'https://public@sentry.example.com/1';

void main() {
  group('$SentryClient', () {
    test('can parse DSN', () async {
      final SentryClient client = SentryClient(dsn: _testDsn);
      expect(client.dsnUri, Uri.parse(_testDsn));
      expect(client.postUri, 'https://sentry.example.com/api/1/store/');
      expect(client.publicKey, 'public');
      expect(client.secretKey, 'secret');
      expect(client.projectId, '1');
      await client.close();
    });

    test('can parse DSN without secret', () async {
      final SentryClient client = SentryClient(dsn: _testDsnWithoutSecret);
      expect(client.dsnUri, Uri.parse(_testDsnWithoutSecret));
      expect(client.postUri, 'https://sentry.example.com/api/1/store/');
      expect(client.publicKey, 'public');
      expect(client.secretKey, null);
      expect(client.projectId, '1');
      await client.close();
    });

    test('sends client auth header without secret', () async {
      final MockClient httpMock = MockClient();
      final ClockProvider fakeClockProvider = () => DateTime.utc(2017, 1, 2);

      Map<String, String> headers;

      httpMock.answerWith((Invocation invocation) async {
        if (invocation.memberName == #close) {
          return null;
        }
        if (invocation.memberName == #post) {
          headers = invocation.namedArguments[#headers];
          return Response('{"id": "test-event-id"}', 200);
        }
        fail('Unexpected invocation of ${invocation.memberName} in HttpMock');
      });

      final SentryClient client = SentryClient(
        dsn: _testDsnWithoutSecret,
        httpClient: httpMock,
        clock: fakeClockProvider,
        compressPayload: false,
        uuidGenerator: () => 'X' * 32,
        environmentAttributes: const Event(
          serverName: 'test.server.com',
          release: '1.2.3',
          environment: 'staging',
        ),
      );

      try {
        throw ArgumentError('Test error');
      } catch (error, stackTrace) {
        final SentryResponse response = await client.captureException(
            exception: error, stackTrace: stackTrace);
        expect(response.isSuccessful, true);
        expect(response.eventId, 'test-event-id');
        expect(response.error, null);
      }

      final Map<String, String> expectedHeaders = <String, String>{
        'User-Agent': '$sdkName/$sdkVersion',
        'Content-Type': 'application/json',
        'X-Sentry-Auth': 'Sentry sentry_version=6, '
            'sentry_client=${SentryClient.sentryClient}, '
            'sentry_timestamp=${fakeClockProvider().millisecondsSinceEpoch}, '
            'sentry_key=public',
      };

      expect(headers, expectedHeaders);

      await client.close();
    });

    Future<void> testCaptureException(bool compressPayload) async {
      final MockClient httpMock = MockClient();
      final ClockProvider fakeClockProvider = () => DateTime.utc(2017, 1, 2);

      String postUri;
      Map<String, String> headers;
      List<int> body;
      httpMock.answerWith((Invocation invocation) async {
        if (invocation.memberName == #close) {
          return null;
        }
        if (invocation.memberName == #post) {
          postUri = invocation.positionalArguments.single;
          headers = invocation.namedArguments[#headers];
          body = invocation.namedArguments[#body];
          return Response('{"id": "test-event-id"}', 200);
        }
        fail('Unexpected invocation of ${invocation.memberName} in HttpMock');
      });

      final SentryClient client = SentryClient(
        dsn: _testDsn,
        httpClient: httpMock,
        clock: fakeClockProvider,
        uuidGenerator: () => 'X' * 32,
        compressPayload: compressPayload,
        environmentAttributes: const Event(
          serverName: 'test.server.com',
          release: '1.2.3',
          environment: 'staging',
        ),
      );

      try {
        throw ArgumentError('Test error');
      } catch (error, stackTrace) {
        final SentryResponse response = await client.captureException(
            exception: error, stackTrace: stackTrace);
        expect(response.isSuccessful, true);
        expect(response.eventId, 'test-event-id');
        expect(response.error, null);
      }

      expect(postUri, client.postUri);

      final Map<String, String> expectedHeaders = <String, String>{
        'User-Agent': '$sdkName/$sdkVersion',
        'Content-Type': 'application/json',
        'X-Sentry-Auth': 'Sentry sentry_version=6, '
            'sentry_client=${SentryClient.sentryClient}, '
            'sentry_timestamp=${fakeClockProvider().millisecondsSinceEpoch}, '
            'sentry_key=public, '
            'sentry_secret=secret',
      };

      if (compressPayload) {
        expectedHeaders['Content-Encoding'] = 'gzip';
      }

      expect(headers, expectedHeaders);

      Map<String, dynamic> data;
      if (compressPayload) {
        data = json.decode(utf8.decode(gzip.decode(body)));
      } else {
        data = json.decode(utf8.decode(body));
      }
      final Map<String, dynamic> stacktrace = data.remove('stacktrace');
      expect(stacktrace['frames'], const TypeMatcher<List<dynamic>>());
      expect(stacktrace['frames'], isNotEmpty);

      final Iterable<dynamic> frames = stacktrace['frames'];
      final Map<String, dynamic> topFrame = frames.last;
      expect(topFrame.keys,
          <String>['abs_path', 'function', 'lineno', 'in_app', 'filename']);
      expect(topFrame['abs_path'], 'sentry_test.dart');
      expect(topFrame['function'], 'main.<fn>.testCaptureException');
      expect(topFrame['lineno'], greaterThan(0));
      expect(topFrame['in_app'], true);
      expect(topFrame['filename'], 'sentry_test.dart');

      expect(data, <String, dynamic>{
        'project': '1',
        'event_id': 'X' * 32,
        'timestamp': '2017-01-02T00:00:00',
        'platform': 'dart',
        'exception': <Map<String, String>>[
          <String, String>{
            'type': 'ArgumentError',
            'value': 'Invalid argument(s): Test error'
          }
        ],
        'sdk': <String, String>{'version': sdkVersion, 'name': 'dart'},
        'logger': SentryClient.defaultLoggerName,
        'server_name': 'test.server.com',
        'release': '1.2.3',
        'environment': 'staging',
      });

      await client.close();
    }

    test('sends an exception report (compressed)', () async {
      await testCaptureException(true);
    });

    test('sends an exception report (uncompressed)', () async {
      await testCaptureException(false);
    });

    test('reads error message from the x-sentry-error header', () async {
      final MockClient httpMock = MockClient();
      final ClockProvider fakeClockProvider = () => DateTime.utc(2017, 1, 2);

      httpMock.answerWith((Invocation invocation) async {
        if (invocation.memberName == #close) {
          return null;
        }
        if (invocation.memberName == #post) {
          return Response('', 401, headers: <String, String>{
            'x-sentry-error': 'Invalid api key',
          });
        }
        fail('Unexpected invocation of ${invocation.memberName} in HttpMock');
      });

      final SentryClient client = SentryClient(
        dsn: _testDsn,
        httpClient: httpMock,
        clock: fakeClockProvider,
        uuidGenerator: () => 'X' * 32,
        compressPayload: false,
        environmentAttributes: const Event(
          serverName: 'test.server.com',
          release: '1.2.3',
          environment: 'staging',
        ),
      );

      try {
        throw ArgumentError('Test error');
      } catch (error, stackTrace) {
        final SentryResponse response = await client.captureException(
            exception: error, stackTrace: stackTrace);
        expect(response.isSuccessful, false);
        expect(response.eventId, null);
        expect(response.error,
            'Sentry.io responded with HTTP 401: Invalid api key');
      }

      await client.close();
    });

    test('$Event userContext overrides client', () async {
      final MockClient httpMock = MockClient();
      final ClockProvider fakeClockProvider = () => DateTime.utc(2017, 1, 2);

      String loggedUserId; // used to find out what user context was sent
      httpMock.answerWith((Invocation invocation) async {
        if (invocation.memberName == #close) {
          return null;
        }
        if (invocation.memberName == #post) {
          // parse the body and detect which user context was sent
          final List<int> bodyData =
              invocation.namedArguments[const Symbol('body')];
          final String decoded = utf8.decode(bodyData);
          final Map<String, dynamic> decodedJson = json.decode(decoded);
          loggedUserId = decodedJson['user']['id'];
          return Response('', 401, headers: <String, String>{
            'x-sentry-error': 'Invalid api key',
          });
        }
        fail('Unexpected invocation of ${invocation.memberName} in HttpMock');
      });

      const User clientUserContext = User(
          id: 'client_user',
          username: 'username',
          email: 'email@email.com',
          ipAddress: '127.0.0.1');
      const User eventUserContext = User(
          id: 'event_user',
          username: 'username',
          email: 'email@email.com',
          ipAddress: '127.0.0.1',
          extras: <String, String>{'foo': 'bar'});

      final SentryClient client = SentryClient(
        dsn: _testDsn,
        httpClient: httpMock,
        clock: fakeClockProvider,
        uuidGenerator: () => 'X' * 32,
        compressPayload: false,
        environmentAttributes: const Event(
          serverName: 'test.server.com',
          release: '1.2.3',
          environment: 'staging',
        ),
      );
      client.userContext = clientUserContext;

      try {
        throw ArgumentError('Test error');
      } catch (error, stackTrace) {
        final Event eventWithoutContext =
            Event(exception: error, stackTrace: stackTrace);
        final Event eventWithContext = Event(
            exception: error,
            stackTrace: stackTrace,
            userContext: eventUserContext);
        await client.capture(event: eventWithoutContext);
        expect(loggedUserId, clientUserContext.id);
        await client.capture(event: eventWithContext);
        expect(loggedUserId, eventUserContext.id);
      }

      await client.close();
    });
  });

  group('$Event', () {
    test('serializes to JSON', () {
      const User user = User(
          id: 'user_id',
          username: 'username',
          email: 'email@email.com',
          ipAddress: '127.0.0.1',
          extras: <String, String>{'foo': 'bar'});
      expect(
        Event(
          message: 'test-message',
          exception: StateError('test-error'),
          level: SeverityLevel.debug,
          culprit: 'Professor Moriarty',
          tags: const <String, String>{
            'a': 'b',
            'c': 'd',
          },
          extra: const <String, dynamic>{
            'e': 'f',
            'g': 2,
          },
          fingerprint: const <String>[Event.defaultFingerprint, 'foo'],
          userContext: user,
        ).toJson(),
        <String, dynamic>{
          'platform': 'dart',
          'sdk': <String, String>{'version': sdkVersion, 'name': 'dart'},
          'message': 'test-message',
          'exception': <Map<String, String>>[
            <String, String>{
              'type': 'StateError',
              'value': 'Bad state: test-error'
            }
          ],
          'level': 'debug',
          'culprit': 'Professor Moriarty',
          'tags': <String, String>{'a': 'b', 'c': 'd'},
          'extra': <String, dynamic>{'e': 'f', 'g': 2},
          'fingerprint': <String>['{{ default }}', 'foo'],
          'user': <String, dynamic>{
            'id': 'user_id',
            'username': 'username',
            'email': 'email@email.com',
            'ip_address': '127.0.0.1',
            'extras': const <String, String>{'foo': 'bar'}
          },
        },
      );
    });
  });
}

typedef Answer = dynamic Function(Invocation invocation);

class MockClient implements Client {
  Answer _answer;

  void answerWith(Answer answer) {
    _answer = answer;
  }

  @override
  void noSuchMethod(Invocation invocation) {
    return _answer(invocation);
  }
}
