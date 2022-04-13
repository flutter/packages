// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/null_safe_pigeon.dart';
import 'package:flutter_unit_tests/nullable_returns.gen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'null_safe_test.mocks.dart';
import 'test_util.dart';

@GenerateMocks(<Type>[BinaryMessenger, NullableArgFlutterApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('with values filled', () {
    final SearchReply reply = SearchReply()
      ..result = 'foo'
      ..error = 'bar';
    final Object encoded = reply.encode();
    final SearchReply decoded = SearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('with null value', () {
    final SearchReply reply = SearchReply()
      ..result = 'foo'
      ..error = null;
    final Object encoded = reply.encode();
    final SearchReply decoded = SearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('send/receive', () async {
    final SearchRequest request = SearchRequest()..query = 'hey';
    final SearchReply reply = SearchReply()..result = 'ho';
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final Completer<ByteData?> completer = Completer<ByteData?>();
    completer
        .complete(Api.codec.encodeMessage(<String, Object>{'result': reply}));
    final Future<ByteData?> sendResult = completer.future;
    when(mockMessenger.send('dev.flutter.pigeon.Api.search', any))
        .thenAnswer((Invocation realInvocation) => sendResult);
    final Api api = Api(binaryMessenger: mockMessenger);
    final SearchReply readReply = await api.search(request);
    expect(readReply, isNotNull);
    expect(reply.result, readReply.result);
  });

  test('send/receive list classes', () async {
    final SearchRequest request = SearchRequest()..query = 'hey';
    final SearchRequests requests = SearchRequests()
      ..requests = <SearchRequest>[request];
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.Api.echo',
      Api.codec,
    );
    final Api api = Api(binaryMessenger: mockMessenger);
    final SearchRequests echo = await api.echo(requests);
    expect(echo.requests!.length, 1);
    expect((echo.requests![0] as SearchRequest?)!.query, 'hey');
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

  test('send null parameter', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const String channel = 'dev.flutter.pigeon.NullableArgHostApi.doit';
    when(mockMessenger.send(channel, any))
        .thenAnswer((Invocation realInvocation) async {
      return Api.codec.encodeMessage(<String?, Object?>{'result': 123});
    });
    final NullableArgHostApi api =
        NullableArgHostApi(binaryMessenger: mockMessenger);
    expect(await api.doit(null), 123);
  });

  test('receive null parameters', () {
    final MockNullableArgFlutterApi mockFlutterApi =
        MockNullableArgFlutterApi();
    when(mockFlutterApi.doit(null)).thenReturn(14);

    NullableArgFlutterApi.setup(mockFlutterApi);

    final Completer<int> resultCompleter = Completer<int>();
    // Null check operator is used because ServicesBinding.instance is nullable
    // in earlier versions of Flutter.
    // ignore: unnecessary_non_null_assertion
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
      'dev.flutter.pigeon.NullableArgFlutterApi.doit',
      NullableArgFlutterApi.codec.encodeMessage(<Object?>[null]),
      (ByteData? data) {
        resultCompleter.complete(
          NullableArgFlutterApi.codec.decodeMessage(data)! as int,
        );
      },
    );

    expect(resultCompleter.future, completion(14));

    // Removes message handlers from global default binary messenger.
    NullableArgFlutterApi.setup(null);
  });
}
