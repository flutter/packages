// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/primitive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'primitive_test.mocks.dart';

@GenerateMocks(<Type>[BinaryMessenger])
void main() {
  test('test anInt', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send('dev.flutter.pigeon.PrimitiveHostApi.anInt', any))
        .thenAnswer((Invocation realInvocation) async {
      const MessageCodec<Object?> codec = PrimitiveHostApi.codec;
      final Object? input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      return codec.encodeMessage(<String, Object>{'result': input!});
    });
    final PrimitiveHostApi api =
        PrimitiveHostApi(binaryMessenger: mockMessenger);
    final int result = await api.anInt(1);
    expect(result, 1);
  });

  test('test List<bool>', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send(
            'dev.flutter.pigeon.PrimitiveHostApi.aBoolList', any))
        .thenAnswer((Invocation realInvocation) async {
      const MessageCodec<Object?> codec = PrimitiveHostApi.codec;
      final Object? input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      return codec.encodeMessage(<String, Object>{'result': input!});
    });
    final PrimitiveHostApi api =
        PrimitiveHostApi(binaryMessenger: mockMessenger);
    final List<bool?> result = await api.aBoolList(<bool?>[true]);
    expect(result[0], true);
  });

  test('test Map<String?, int?>', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send(
            'dev.flutter.pigeon.PrimitiveHostApi.aStringIntMap', any))
        .thenAnswer((Invocation realInvocation) async {
      const MessageCodec<Object?> codec = PrimitiveHostApi.codec;
      final Object? input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      return codec.encodeMessage(<String, Object>{'result': input!});
    });
    final PrimitiveHostApi api =
        PrimitiveHostApi(binaryMessenger: mockMessenger);
    final Map<String?, int?> result =
        await api.aStringIntMap(<String?, int?>{'hello': 1});
    expect(result['hello'], 1);
  });
}
