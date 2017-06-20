// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sentry/sentry.dart';
import 'package:test/test.dart';

void main() {
  group('$SentryClient', () {
    test('can parse DSN', () {
      final SentryClient client = new SentryClient(dsn: 'https://public:secret@sentry.example.com/1');
      expect(client.postUri, 'https://sentry.example.com/api/1/store');
      expect(client.publicKey, 'public');
      expect(client.secretKey, 'secret');
      expect(client.projectId, '1');
    });
  });
}
