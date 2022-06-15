// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_objc/dartle.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  testWidgets('simple call', (WidgetTester tester) async {
    final MessageSearchRequest request = MessageSearchRequest()
      ..query = 'Aaron';
    final MessageApi api = MessageApi();
    final MessageSearchReply reply = await api.search(request);
    expect(reply.result, equals('Hello Aaron!'));
    expect(reply.state, equals(MessageRequestState.success));
  });

  testWidgets('simple nested', (WidgetTester tester) async {
    final MessageSearchRequest request = MessageSearchRequest()
      ..query = 'Aaron';
    final MessageNested nested = MessageNested()..request = request;
    final MessageNestedApi api = MessageNestedApi();
    final MessageSearchReply reply = await api.search(nested);
    expect(reply.result, equals('Hello Aaron!'));
    expect(reply.state, equals(MessageRequestState.success));
  });

  testWidgets('throws', (WidgetTester tester) async {
    final MessageSearchRequest request = MessageSearchRequest()
      ..query = 'error';
    final MessageApi api = MessageApi();
    MessageSearchReply reply;
    expect(() async {
      reply = await api.search(request);
    }, throwsException);
    expect(reply, isNull);
  });
}
