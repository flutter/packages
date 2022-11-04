// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/multiple_arity.gen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'multiple_arity_test.mocks.dart';

@GenerateMocks(<Type>[BinaryMessenger])
void main() {
  test('multiple arity', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send(
            'dev.flutter.pigeon.MultipleArityHostApi.subtract', any))
        .thenAnswer((Invocation realInvocation) async {
      final Object input = MultipleArityHostApi.codec
          .decodeMessage(realInvocation.positionalArguments[1])!;
      final List<Object?> args = input as List<Object?>;
      final int x = (args[0] as int?)!;
      final int y = (args[1] as int?)!;
      return MultipleArityHostApi.codec.encodeMessage(<Object>[x - y]);
    });

    final MultipleArityHostApi api =
        MultipleArityHostApi(binaryMessenger: mockMessenger);
    final int result = await api.subtract(30, 10);
    expect(result, 20);
  });
}
