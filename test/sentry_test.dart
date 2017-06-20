// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

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

    test('sends an exception report', () async {
      final MockClient httpMock = new MockClient();
      final Clock fakeClock = new Clock.fixed(new DateTime(2017, 1, 2));

      String postUri;
      Map<String, String> headers;
      String body;
      when(httpMock.post(any, headers: any, body: any)).thenAnswer((Invocation invocation) {
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
      );

      try {
        throw new ArgumentError('Test error');
      } catch(error, stackTrace) {
        await client.captureException(exception: error, stackTrace: stackTrace);
      }

      expect(postUri, client.postUri);
      expect(headers, {
        'User-Agent': '${SentryClient.sdkName}/$sdkVersion',
        'Content-Type': 'application/json',
        'X-Sentry-Auth': 'Sentry sentry_version=6, '
            'sentry_client=${SentryClient.sentryClient}, '
            'sentry_timestamp=${fakeClock.now().millisecondsSinceEpoch}, '
            'sentry_key=public, '
            'sentry_secret=secret',
      });

      expect(JSON.decode(body), {
        'project': '1',
        'event_id': 'X' * 32,
        'timestamp': '2017-01-02T00:00:00.000',
        'message': 'Invalid argument(s): Test error',
        'platform': 'dart',
        'exception': [{'type': 'ArgumentError', 'value': 'Invalid argument(s): Test error'}],
        'sdk': {'version': '0.0.1', 'name': 'dart'}
      });

      await client.close();
    });
  });
}

class MockClient extends Mock implements Client {}
