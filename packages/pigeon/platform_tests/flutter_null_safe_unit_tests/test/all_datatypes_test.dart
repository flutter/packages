// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/all_datatypes.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'all_datatypes_test.mocks.dart';

@GenerateMocks(<Type>[BinaryMessenger])
void main() {
  test('with null values', () async {
    final Everything everything = Everything();
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send('dev.flutter.pigeon.HostEverything.echo', any))
        .thenAnswer((Invocation realInvocation) async {
      const StandardMessageCodec codec = StandardMessageCodec();
      final Object input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      return codec.encodeMessage(<String, Object>{'result': input});
    });
    final HostEverything api = HostEverything(binaryMessenger: mockMessenger);
    final Everything result = await api.echo(everything);
    expect(result.aBool, isNull);
    expect(result.anInt, isNull);
    expect(result.aDouble, isNull);
    expect(result.aString, isNull);
    expect(result.aByteArray, isNull);
    expect(result.a4ByteArray, isNull);
    expect(result.a8ByteArray, isNull);
    expect(result.aFloatArray, isNull);
    expect(result.aList, isNull);
    expect(result.aMap, isNull);
  });

  test('with values', () async {
    final Everything everything = Everything();
    everything.aBool = false;
    everything.anInt = 123;
    everything.aDouble = 2.0;
    everything.aString = 'hello';
    everything.aByteArray = Uint8List.fromList(<int>[1, 2, 3, 4]);
    everything.a4ByteArray = Int32List.fromList(<int>[1, 2, 3, 4]);
    everything.a8ByteArray = Int64List.fromList(<int>[1, 2, 3, 4]);
    everything.aFloatArray =
        Float64List.fromList(<double>[1.0, 2.5, 3.0, 4.25]);
    everything.aList = <int>[1, 2, 3, 4];
    everything.aMap = <String, int>{'hello': 1234};
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    when(mockMessenger.send('dev.flutter.pigeon.HostEverything.echo', any))
        .thenAnswer((Invocation realInvocation) async {
      const StandardMessageCodec codec = StandardMessageCodec();
      final Object input =
          codec.decodeMessage(realInvocation.positionalArguments[1]);
      return codec.encodeMessage(<String, Object>{'result': input});
    });
    final HostEverything api = HostEverything(binaryMessenger: mockMessenger);
    final Everything result = await api.echo(everything);
    expect(result.aBool, everything.aBool);
    expect(result.anInt, everything.anInt);
    expect(result.aDouble, everything.aDouble);
    expect(result.aString, everything.aString);
    expect(result.aByteArray, everything.aByteArray);
    expect(result.a4ByteArray, everything.a4ByteArray);
    expect(result.a8ByteArray, everything.a8ByteArray);
    expect(result.aFloatArray, everything.aFloatArray);
    expect(result.aList, everything.aList);
    expect(result.aMap, everything.aMap);
  });
}
