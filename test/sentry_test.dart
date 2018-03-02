// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/time.dart';
import 'package:sentry/sentry.dart';
import 'package:test/test.dart';

const String _testDsn = 'https://public:secret@sentry.example.com/1';

void main() {
  group('$SentryClient', () {
    test('can parse DSN', () async {
      final SentryClient client = new SentryClient(dsn: _testDsn);
      expect(client.dsnUri, Uri.parse(_testDsn));
      expect(client.postUri, 'https://sentry.example.com/api/1/store/');
      expect(client.publicKey, 'public');
      expect(client.secretKey, 'secret');
      expect(client.projectId, '1');
      await client.close();
    });

    testCaptureException(bool compressPayload) async {
      final MockClient httpMock = new MockClient();
      final Clock fakeClock = new Clock.fixed(new DateTime.utc(2017, 1, 2));

      String postUri;
      Map<String, String> headers;
      List<int> body;
      when(httpMock.post(any, headers: any, body: any))
          .thenAnswer((Invocation invocation) {
        postUri = invocation.positionalArguments.single;
        headers = invocation.namedArguments[#headers];
        body = invocation.namedArguments[#body];
        return new Response('{"id": "test-event-id"}', 200);
      });

      final SentryClient client = new SentryClient(
        dsn: _testDsn,
        httpClient: httpMock,
        clock: fakeClock,
        uuidGenerator: () => 'X' * 32,
        compressPayload: compressPayload,
        environmentAttributes: const Event(
          serverName: 'test.server.com',
          release: '1.2.3',
          environment: 'staging',
        ),
      );

      try {
        throw new ArgumentError('Test error');
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
            'sentry_timestamp=${fakeClock.now().millisecondsSinceEpoch}, '
            'sentry_key=public, '
            'sentry_secret=secret',
      };

      if (compressPayload) expectedHeaders['Content-Encoding'] = 'gzip';

      expect(headers, expectedHeaders);

      Map<String, dynamic> json;
      if (compressPayload) {
        json = JSON.decode(UTF8.decode(GZIP.decode(body)));
      } else {
        json = JSON.decode(UTF8.decode(body));
      }
      final Map<String, dynamic> stacktrace = json.remove('stacktrace');
      expect(stacktrace['frames'], const isInstanceOf<List>());
      expect(stacktrace['frames'], isNotEmpty);

      final Map<String, dynamic> topFrame = stacktrace['frames'].first;
      expect(topFrame.keys,
          <String>['abs_path', 'function', 'lineno', 'in_app', 'filename']);
      expect(topFrame['abs_path'], 'sentry_test.dart');
      expect(topFrame['function'], 'main.<fn>.testCaptureException');
      expect(topFrame['lineno'], greaterThan(0));
      expect(topFrame['in_app'], true);
      expect(topFrame['filename'], 'sentry_test.dart');

      expect(json, {
        'project': '1',
        'event_id': 'X' * 32,
        'timestamp': '2017-01-02T00:00:00',
        'platform': 'dart',
        'exception': [
          {'type': 'ArgumentError', 'value': 'Invalid argument(s): Test error'}
        ],
        'sdk': {'version': sdkVersion, 'name': 'dart'},
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
      final MockClient httpMock = new MockClient();
      final Clock fakeClock = new Clock.fixed(new DateTime(2017, 1, 2));

      when(httpMock.post(any, headers: any, body: any))
          .thenAnswer((Invocation invocation) {
        return new Response('', 401, headers: <String, String>{
          'x-sentry-error': 'Invalid api key',
        });
      });

      final SentryClient client = new SentryClient(
        dsn: _testDsn,
        httpClient: httpMock,
        clock: fakeClock,
        uuidGenerator: () => 'X' * 32,
        compressPayload: false,
        environmentAttributes: const Event(
          serverName: 'test.server.com',
          release: '1.2.3',
          environment: 'staging',
        ),
      );

      try {
        throw new ArgumentError('Test error');
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
  });

  group('$Event', () {
    test('serializes to JSON', () {
      expect(
        new Event(
          message: 'test-message',
          exception: new StateError('test-error'),
          level: SeverityLevel.debug,
          culprit: 'Professor Moriarty',
          tags: <String, String>{
            'a': 'b',
            'c': 'd',
          },
          extra: <String, dynamic>{
            'e': 'f',
            'g': 2,
          },
          fingerprint: <String>[Event.defaultFingerprint, 'foo'],
        ).toJson(),
        <String, dynamic>{
          'platform': 'dart',
          'sdk': {'version': sdkVersion, 'name': 'dart'},
          'message': 'test-message',
          'exception': [
            {'type': 'StateError', 'value': 'Bad state: test-error'}
          ],
          'level': 'debug',
          'culprit': 'Professor Moriarty',
          'tags': {'a': 'b', 'c': 'd'},
          'extra': {'e': 'f', 'g': 2},
          'fingerprint': ['{{ default }}', 'foo'],
        },
      );
    });
  });
}

class MockClient extends Mock implements Client {}
