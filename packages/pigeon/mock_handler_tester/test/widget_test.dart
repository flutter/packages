// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

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
  SearchReply search(SearchRequest arg) {
    log.add('search');
    return SearchReply()..result = arg.query;
  }
}

class MockNested implements TestNestedApi {
  bool didCall = false;
  @override
  SearchReply search(Nested arg) {
    didCall = true;
    if (arg.request == null) {
      return SearchReply();
    } else {
      return SearchReply()..result = arg.request.query;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simple', () async {
    final NestedApi api = NestedApi();
    final MockNested mock = MockNested();
    TestNestedApi.setup(mock);
    final SearchReply reply = await api.search(Nested()..request = null);
    expect(mock.didCall, true);
    expect(reply.result, null);
  });

  test('nested', () async {
    final Api api = Api();
    final Mock mock = Mock();
    TestHostApi.setup(mock);
    final SearchReply reply = await api.search(SearchRequest()..query = 'foo');
    expect(mock.log, <String>['search']);
    expect(reply.result, 'foo');
  });

  test('no-arg calls', () async {
    final Api api = Api();
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
        await const BasicMessageChannel<Object>(
          'dev.flutter.pigeon.Api.initialize',
          StandardMessageCodec(),
        ).send(null),
        isEmpty,
      );
      try {
        await const BasicMessageChannel<Object>(
          'dev.flutter.pigeon.Api.search',
          StandardMessageCodec(),
        ).send(null) as Map<Object, Object>;
        expect(true, isFalse); // should not reach here
      } catch (error) {
        expect(error, isAssertionError);
        expect(
          error.toString(),
          contains(
            'Argument for dev.flutter.pigeon.Api.search was null. Expected SearchRequest.',
          ),
        );
      }
      expect(mock.log, <String>['initialize']);
    },
    // TODO(ianh): skip can be removed after first stable release in 2021
    skip: Platform.environment['CHANNEL'] == 'stable',
  );
}
