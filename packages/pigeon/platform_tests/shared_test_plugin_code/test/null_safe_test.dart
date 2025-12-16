// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_test_plugin_code/src/generated/flutter_unittests.gen.dart';
import 'package:shared_test_plugin_code/src/generated/nullable_returns.gen.dart';

import 'null_safe_test.mocks.dart';
import 'test_util.dart';

@GenerateMocks(<Type>[
  BinaryMessenger,
  NullableArgFlutterApi,
  NullableReturnFlutterApi,
  NullableCollectionArgFlutterApi,
  NullableCollectionReturnFlutterApi,
])
void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  test('with values filled', () {
    final reply = FlutterSearchReply()
      ..result = 'foo'
      ..error = 'bar';
    final encoded = reply.encode() as List<Object?>;
    final FlutterSearchReply decoded = FlutterSearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('with null value', () {
    final reply = FlutterSearchReply()
      ..result = 'foo'
      ..error = null;
    final encoded = reply.encode() as List<Object?>;
    final FlutterSearchReply decoded = FlutterSearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('send/receive', () async {
    final request = FlutterSearchRequest()..query = 'hey';
    final reply = FlutterSearchReply()..result = 'ho';
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final completer = Completer<ByteData?>();
    completer.complete(Api.pigeonChannelCodec.encodeMessage(<Object>[reply]));
    final Future<ByteData?> sendResult = completer.future;
    when(
      mockMessenger.send(
        'dev.flutter.pigeon.pigeon_integration_tests.Api.search',
        any,
      ),
    ).thenAnswer((Invocation realInvocation) => sendResult);
    final api = Api(binaryMessenger: mockMessenger);
    final FlutterSearchReply readReply = await api.search(request);
    expect(readReply, isNotNull);
    expect(reply.result, readReply.result);
  });

  test('send/receive list classes', () async {
    final request = FlutterSearchRequest()..query = 'hey';
    final requests = FlutterSearchRequests()
      ..requests = <FlutterSearchRequest>[request];
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.pigeon_integration_tests.Api.echo',
      Api.pigeonChannelCodec,
    );
    final api = Api(binaryMessenger: mockMessenger);
    final FlutterSearchRequests echo = await api.echo(requests);
    expect(echo.requests!.length, 1);
    expect((echo.requests![0] as FlutterSearchRequest?)!.query, 'hey');
  });

  test('primitive datatypes', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.pigeon_integration_tests.Api.anInt',
      Api.pigeonChannelCodec,
    );
    final api = Api(binaryMessenger: mockMessenger);
    final int result = await api.anInt(1);
    expect(result, 1);
  });

  test('return null to nonnull', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const channel = 'dev.flutter.pigeon.pigeon_integration_tests.Api.anInt';
    when(mockMessenger.send(channel, any)).thenAnswer((
      Invocation realInvocation,
    ) async {
      return Api.pigeonChannelCodec.encodeMessage(<Object?>[null]);
    });
    final api = Api(binaryMessenger: mockMessenger);
    expect(
      () async => api.anInt(1),
      throwsA(const TypeMatcher<PlatformException>()),
    );
  });

  test('send null parameter', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const channel =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableArgHostApi.doit';
    when(mockMessenger.send(channel, any)).thenAnswer((
      Invocation realInvocation,
    ) async {
      return Api.pigeonChannelCodec.encodeMessage(<Object?>[123]);
    });
    final api = NullableArgHostApi(binaryMessenger: mockMessenger);
    expect(await api.doit(null), 123);
  });

  test('send null collection parameter', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const channel =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionArgHostApi.doit';
    when(mockMessenger.send(channel, any)).thenAnswer((
      Invocation realInvocation,
    ) async {
      return Api.pigeonChannelCodec.encodeMessage(<Object?>[
        <String?>['123'],
      ]);
    });
    final api = NullableCollectionArgHostApi(binaryMessenger: mockMessenger);
    expect(await api.doit(null), <String?>['123']);
  });

  test('receive null parameters', () {
    final mockFlutterApi = MockNullableArgFlutterApi();
    when(mockFlutterApi.doit(null)).thenReturn(14);

    NullableArgFlutterApi.setUp(mockFlutterApi);

    final resultCompleter = Completer<int>();
    binding.defaultBinaryMessenger.handlePlatformMessage(
      'dev.flutter.pigeon.pigeon_integration_tests.NullableArgFlutterApi.doit',
      NullableArgFlutterApi.pigeonChannelCodec.encodeMessage(<Object?>[null]),
      (ByteData? data) {
        resultCompleter.complete(
          (NullableArgFlutterApi.pigeonChannelCodec.decodeMessage(data)!
                      as List<Object?>)
                  .first!
              as int,
        );
      },
    );

    expect(resultCompleter.future, completion(14));

    // Removes message handlers from global default binary messenger.
    NullableArgFlutterApi.setUp(null);
  });

  test('receive null collection parameters', () {
    final mockFlutterApi = MockNullableCollectionArgFlutterApi();
    when(mockFlutterApi.doit(null)).thenReturn(<String?>['14']);

    NullableCollectionArgFlutterApi.setUp(mockFlutterApi);

    final resultCompleter = Completer<List<String?>>();
    binding.defaultBinaryMessenger.handlePlatformMessage(
      'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionArgFlutterApi.doit',
      NullableCollectionArgFlutterApi.pigeonChannelCodec.encodeMessage(
        <Object?>[null],
      ),
      (ByteData? data) {
        resultCompleter.complete(
          ((NullableCollectionArgFlutterApi.pigeonChannelCodec.decodeMessage(
                            data,
                          )!
                          as List<Object?>)
                      .first!
                  as List<Object?>)
              .cast<String>(),
        );
      },
    );

    expect(resultCompleter.future, completion(<String>['14']));

    // Removes message handlers from global default binary messenger.
    NullableArgFlutterApi.setUp(null);
  });

  test('receive null return', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const channel =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableReturnHostApi.doit';
    when(mockMessenger.send(channel, any)).thenAnswer((
      Invocation realInvocation,
    ) async {
      return NullableReturnHostApi.pigeonChannelCodec.encodeMessage(<Object?>[
        null,
      ]);
    });
    final api = NullableReturnHostApi(binaryMessenger: mockMessenger);
    expect(await api.doit(), null);
  });

  test('receive null collection return', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    const channel =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionReturnHostApi.doit';
    when(mockMessenger.send(channel, any)).thenAnswer((
      Invocation realInvocation,
    ) async {
      return NullableCollectionReturnHostApi.pigeonChannelCodec.encodeMessage(
        <Object?>[null],
      );
    });
    final api = NullableCollectionReturnHostApi(binaryMessenger: mockMessenger);
    expect(await api.doit(), null);
  });

  test('send null return', () async {
    final mockFlutterApi = MockNullableReturnFlutterApi();
    when(mockFlutterApi.doit()).thenReturn(null);

    NullableReturnFlutterApi.setUp(mockFlutterApi);

    final resultCompleter = Completer<int?>();
    unawaited(
      binding.defaultBinaryMessenger.handlePlatformMessage(
        'dev.flutter.pigeon.pigeon_integration_tests.NullableReturnFlutterApi.doit',
        NullableReturnFlutterApi.pigeonChannelCodec.encodeMessage(<Object?>[]),
        (ByteData? data) {
          resultCompleter.complete(null);
        },
      ),
    );

    expect(resultCompleter.future, completion(null));

    // Removes message handlers from global default binary messenger.
    NullableArgFlutterApi.setUp(null);
  });

  test('send null collection return', () async {
    final mockFlutterApi = MockNullableCollectionReturnFlutterApi();
    when(mockFlutterApi.doit()).thenReturn(null);

    NullableCollectionReturnFlutterApi.setUp(mockFlutterApi);

    final resultCompleter = Completer<List<String?>?>();
    unawaited(
      binding.defaultBinaryMessenger.handlePlatformMessage(
        'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionReturnFlutterApi.doit',
        NullableCollectionReturnFlutterApi.pigeonChannelCodec.encodeMessage(
          <Object?>[],
        ),
        (ByteData? data) {
          resultCompleter.complete(null);
        },
      ),
    );

    expect(resultCompleter.future, completion(null));

    // Removes message handlers from global default binary messenger.
    NullableArgFlutterApi.setUp(null);
  });
}
