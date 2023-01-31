// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/primitive.gen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'primitive_test.mocks.dart';
import 'test_util.dart';

@GenerateMocks(<Type>[BinaryMessenger, PrimitiveFlutterApi])
void main() {
  test('test anInt', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.PrimitiveHostApi.anInt',
      PrimitiveHostApi.codec,
    );
    final PrimitiveHostApi api =
        PrimitiveHostApi(binaryMessenger: mockMessenger);
    final int result = await api.anInt(1);
    expect(result, 1);
  });

  test('test List<bool>', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.PrimitiveHostApi.aBoolList',
      PrimitiveHostApi.codec,
    );
    final PrimitiveHostApi api =
        PrimitiveHostApi(binaryMessenger: mockMessenger);
    final List<bool?> result = await api.aBoolList(<bool?>[true]);
    expect(result[0], true);
  });

  test('test List<bool> flutterapi', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final PrimitiveFlutterApi api = MockPrimitiveFlutterApi();
    when(api.aBoolList(<bool?>[true, false])).thenReturn(<bool?>[]);
    when(mockMessenger.setMessageHandler(
            'dev.flutter.pigeon.PrimitiveFlutterApi.aBoolList', any))
        .thenAnswer((Invocation realInvocation) {
      final MessageHandler? handler =
          realInvocation.positionalArguments[1] as MessageHandler?;
      handler!(PrimitiveFlutterApi.codec.encodeMessage(<Object?>[
        <Object?>[true, false]
      ]));
    });
    PrimitiveFlutterApi.setup(api, binaryMessenger: mockMessenger);
    verify(api.aBoolList(<bool?>[true, false]));
  });

  test('test Map<String?, int?>', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.PrimitiveHostApi.aStringIntMap',
      PrimitiveHostApi.codec,
    );
    final PrimitiveHostApi api =
        PrimitiveHostApi(binaryMessenger: mockMessenger);
    final Map<String?, int?> result =
        await api.aStringIntMap(<String?, int?>{'hello': 1});
    expect(result['hello'], 1);
  });
}
