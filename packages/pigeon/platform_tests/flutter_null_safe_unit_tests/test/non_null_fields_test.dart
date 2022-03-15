// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/non_null_fields.gen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'non_null_fields_test.mocks.dart';
import 'test_util.dart';

@GenerateMocks(<Type>[BinaryMessenger, NonNullTypeArgumentFlutterApi])
void main() {
  test('test constructor', () {
    final SearchRequest request = SearchRequest(query: 'what?');
    expect(request.query, 'what?');
  });

  test('non-null arg host api', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final NonNullTypeArgumentHostApi api =
        NonNullTypeArgumentHostApi(binaryMessenger: mockMessenger);
    echoOneArgument(
      mockMessenger,
      'dev.flutter.pigeon.NonNullTypeArgumentHostApi.sum',
      NonNullTypeArgumentHostApi.codec,
    );
    final List<int> values = <int>[1, 2, 3, 4];
    final List<int> result = await api.sum(values);
    expect(listEquals(result, values), isTrue);
  });

  test('non-null arg flutter api', () async {
    final NonNullTypeArgumentFlutterApi api =
        MockNonNullTypeArgumentFlutterApi();
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(api.sum(<int>[1, 2, 3, 4])).thenReturn(<int>[2, 4, 6, 8]);
    when(mockMessenger.setMessageHandler(
            'dev.flutter.pigeon.NonNullTypeArgumentFlutterApi.sum', any))
        .thenAnswer((Invocation realInvocation) {
      final MessageHandler? handler =
          realInvocation.positionalArguments[1] as MessageHandler?;
      handler!(NonNullTypeArgumentFlutterApi.codec.encodeMessage(<Object?>[
        <Object?>[1, 2, 3, 4]
      ]));
    });
    NonNullTypeArgumentFlutterApi.setup(api, binaryMessenger: mockMessenger);
    verify(api.sum(<int>[1, 2, 3, 4]));
  });
}
