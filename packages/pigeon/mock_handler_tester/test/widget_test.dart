// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'message.dart';
import 'test.dart';

class Mock implements TestHostApi {
  List<String> log = <String>[];

  @override
  void initialize() {
    log.add('initialize');
  }

  @override
  MessageSearchReply search(MessageSearchRequest arg) {
    log.add('search');
    return MessageSearchReply()..result = arg.query;
  }
}

class MockNested implements TestNestedApi {
  bool didCall = false;
  @override
  MessageSearchReply search(MessageNested arg) {
    didCall = true;
    if (arg.request == null) {
      return MessageSearchReply();
    } else {
      return MessageSearchReply()..result = arg.request?.query;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simple', () async {
    final MessageNestedApi api = MessageNestedApi();
    final MockNested mock = MockNested();
    TestNestedApi.setup(mock);
    final MessageSearchReply reply =
        await api.search(MessageNested()..request = null);
    expect(mock.didCall, true);
    expect(reply.result, null);
  });

  test('nested', () async {
    final MessageApi api = MessageApi();
    final Mock mock = Mock();
    TestHostApi.setup(mock);
    final MessageSearchReply reply =
        await api.search(MessageSearchRequest()..query = 'foo');
    expect(mock.log, <String>['search']);
    expect(reply.result, 'foo');
  });

  test('no-arg calls', () async {
    final MessageApi api = MessageApi();
    final Mock mock = Mock();
    TestHostApi.setup(mock);
    await api.initialize();
    expect(mock.log, <String>['initialize']);
  });

  test(
    'calling methods with null',
    () async {
      final Mock mock = Mock();
      TestHostApi.setup(mock);
      expect(
        await const BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.mock_handler_tester.MessageApi.initialize',
          StandardMessageCodec(),
        ).send(<Object?>[null]),
        isEmpty,
      );
      try {
        await const BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.mock_handler_tester.MessageApi.search',
          StandardMessageCodec(),
        ).send(<Object?>[null]) as List<Object?>?;
        expect(true, isFalse); // should not reach here
      } catch (error) {
        expect(error, isAssertionError);
        expect(
          error.toString(),
          contains(
            'Argument for dev.flutter.pigeon.mock_handler_tester.MessageApi.search was null, expected non-null MessageSearchRequest.',
          ),
        );
      }
      expect(mock.log, <String>['initialize']);
    },
  );
}
