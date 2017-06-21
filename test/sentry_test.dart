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
      final Clock fakeClock = new Clock.fixed(new DateTime(2017, 1, 2));

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
        serverName: 'test.server.com',
        release: '1.2.3',
        environment: 'staging',
      );

      try {
        throw new ArgumentError('Test error');
      } catch (error, stackTrace) {
        await client.captureException(exception: error, stackTrace: stackTrace);
      }

      expect(postUri, client.postUri);

      Map<String, String> expectedHeaders = <String, String>{
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

      String json;
      if (compressPayload) {
        json = UTF8.decode(GZIP.decode(body));
      } else {
        json = UTF8.decode(body);
      }
      expect(JSON.decode(json), {
        'project': '1',
        'event_id': 'X' * 32,
        'timestamp': '2017-01-02T00:00:00.000',
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
  });

  group('$Event', () {
    test('serializes to JSON', () {
      final DateTime now = new DateTime(2017);
      expect(
        new Event(
          eventId: 'X' * 32,
          timestamp: now,
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
          'event_id': 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
          'timestamp': '2017-01-01T00:00:00.000',
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
