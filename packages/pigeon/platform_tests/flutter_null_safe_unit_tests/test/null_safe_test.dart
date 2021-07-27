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

@GenerateMocks(<Type>[BinaryMessenger])
void main() {
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
    when(mockMessenger.send('dev.flutter.pigeon.Api.echo', any))
        .thenAnswer((Invocation realInvocation) async {
      final MessageCodec<Object?> codec = Api.codec;
      final Object? input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      return codec.encodeMessage(<String, Object>{'result': input!});
    });
    final Api api = Api(binaryMessenger: mockMessenger);
    final SearchRequests echo = await api.echo(requests);
    expect(echo.requests!.length, 1);
    expect((echo.requests![0] as SearchRequest?)!.query, 'hey');
  });

  test('primiative datatypes', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send('dev.flutter.pigeon.Api.anInt', any))
        .thenAnswer((Invocation realInvocation) async {
      final MessageCodec<Object?> codec = Api.codec;
      final Object? input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      final int result = (input as int?)! + 1;
      return codec.encodeMessage(<String, Object>{'result': result});
    });
    final Api api = Api(binaryMessenger: mockMessenger);
    final int result = await api.anInt(1);
    expect(result, 2);
  });
}
