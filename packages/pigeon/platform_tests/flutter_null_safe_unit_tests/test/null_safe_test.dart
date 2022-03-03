// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/null_safe_pigeon.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'null_safe_test.mocks.dart';
import 'test_util.dart';

@GenerateMocks(<Type>[BinaryMessenger])
void main() {
  test('with values filled', () {
    final FlutterSearchReply reply = FlutterSearchReply()
      ..result = 'foo'
      ..error = 'bar';
    final Object encoded = reply.encode();
    final FlutterSearchReply decoded = FlutterSearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('with null value', () {
    final FlutterSearchReply reply = FlutterSearchReply()
      ..result = 'foo'
      ..error = null;
    final Object encoded = reply.encode();
    final FlutterSearchReply decoded = FlutterSearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('send/receive', () async {
    final FlutterSearchRequest request = FlutterSearchRequest()..query = 'hey';
    final FlutterSearchReply reply = FlutterSearchReply()..result = 'ho';
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final Completer<ByteData?> completer = Completer<ByteData?>();
    completer
        .complete(Api.codec.encodeMessage(<String, Object>{'result': reply}));
    final Future<ByteData?> sendResult = completer.future;
    when(mockMessenger.send('dev.flutter.pigeon.Api.search', any))
        .thenAnswer((Invocation realInvocation) => sendResult);
    final Api api = Api(binaryMessenger: mockMessenger);
    final FlutterSearchReply readReply = await api.search(request);
    expect(readReply, isNotNull);
    expect(reply.result, readReply.result);
  });

  test('send/receive list classes', () async {
    final FlutterSearchRequest request = FlutterSearchRequest()..query = 'hey';
    final FlutterSearchRequests requests = FlutterSearchRequests()
      ..requests = <FlutterSearchRequest>[request];
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.Api.echo',
      Api.codec,
    );
    final Api api = Api(binaryMessenger: mockMessenger);
    final FlutterSearchRequests echo = await api.echo(requests);
    expect(echo.requests!.length, 1);
    expect((echo.requests![0] as FlutterSearchRequest?)!.query, 'hey');
  });

  test('primitive datatypes', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.Api.anInt',
      Api.codec,
    );
    final Api api = Api(binaryMessenger: mockMessenger);
    final int result = await api.anInt(1);
    expect(result, 1);
  });

  test('return null to nonnull', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const String channel = 'dev.flutter.pigeon.Api.anInt';
    when(mockMessenger.send(channel, any))
        .thenAnswer((Invocation realInvocation) async {
      return Api.codec.encodeMessage(<String?, Object?>{'result': null});
    });
    final Api api = Api(binaryMessenger: mockMessenger);
    expect(() async => api.anInt(1),
        throwsA(const TypeMatcher<PlatformException>()));
  });
}
