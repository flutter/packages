// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_unit_tests/null_safe_pigeon.dart';
import 'package:flutter_test/flutter_test.dart';
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
    const MessageCodec<Object?> codec = StandardMessageCodec();
    final Completer<ByteData?> completer = Completer<ByteData?>();
    completer.complete(
        codec.encodeMessage(<String, Object>{'result': reply.encode()}));
    final Future<ByteData?> sendResult = completer.future;
    when(mockMessenger.send('dev.flutter.pigeon.Api.search', any))
        .thenAnswer((Invocation realInvocation) => sendResult);
    final Api api = Api(binaryMessenger: mockMessenger);
    final SearchReply readReply = await api.search(request);
    expect(readReply, isNotNull);
    expect(reply.result, readReply.result);
  });

  // TODO(gaaclarke): This test is a companion for the fix to https://github.com/flutter/flutter/issues/80538
  // test('send/receive list classes', () async {
  //   final SearchRequest request = SearchRequest()
  //       ..query = 'hey';
  //   final SearchReply reply = SearchReply()
  //       ..result = 'ho';
  //   final SearchRequests requests = SearchRequests()
  //       ..requests = <SearchRequest>[request];
  //   final SearchReplies replies = SearchReplies()
  //       ..replies = <SearchReply>[reply];
  //   final BinaryMessenger mockMessenger = MockBinaryMessenger();
  //   const MessageCodec<Object?> codec = StandardMessageCodec();
  //   final Completer<ByteData?> completer = Completer<ByteData?>();
  //   completer.complete(codec.encodeMessage(<String, Object>{'result' : replies.encode()}));
  //   final Future<ByteData?> sendResult = completer.future;
  //   when(mockMessenger.send('dev.flutter.pigeon.Api.search', any)).thenAnswer((Invocation realInvocation) => sendResult);
  //   final Api api = Api(binaryMessenger: mockMessenger);
  //   final SearchReplies readReplies = await api.doSearches(requests);
  //   expect(readReplies, isNotNull);
  //   expect(reply.result, (readReplies.replies![0] as SearchReply?)!.result);
  // });
}
