// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_windows/src/guid.dart';

void main() {
  test('has correct byte representation', () async {
    final Pointer<GUID> guid = calloc<GUID>()
      ..ref.parse('{00112233-4455-6677-8899-aabbccddeeff}');
    final ByteData data = ByteData(16)
      ..setInt32(0, guid.ref.data1, Endian.little)
      ..setInt16(4, guid.ref.data2, Endian.little)
      ..setInt16(6, guid.ref.data3, Endian.little)
      ..setInt64(8, guid.ref.data4, Endian.little);
    expect(data.getUint8(0), 0x33);
    expect(data.getUint8(1), 0x22);
    expect(data.getUint8(2), 0x11);
    expect(data.getUint8(3), 0x00);
    expect(data.getUint8(4), 0x55);
    expect(data.getUint8(5), 0x44);
    expect(data.getUint8(6), 0x77);
    expect(data.getUint8(7), 0x66);
    expect(data.getUint8(8), 0x88);
    expect(data.getUint8(9), 0x99);
    expect(data.getUint8(10), 0xAA);
    expect(data.getUint8(11), 0xBB);
    expect(data.getUint8(12), 0xCC);
    expect(data.getUint8(13), 0xDD);
    expect(data.getUint8(14), 0xEE);
    expect(data.getUint8(15), 0xFF);

    calloc.free(guid);
  });

  test('handles alternate forms', () async {
    final Pointer<GUID> guid1 = calloc<GUID>()
      ..ref.parse('{00112233-4455-6677-8899-aabbccddeeff}');
    final Pointer<GUID> guid2 = calloc<GUID>()
      ..ref.parse('00112233445566778899AABBCCDDEEFF');

    expect(guid1.ref.data1, guid2.ref.data1);
    expect(guid1.ref.data2, guid2.ref.data2);
    expect(guid1.ref.data3, guid2.ref.data3);
    expect(guid1.ref.data4, guid2.ref.data4);

    calloc.free(guid1);
    calloc.free(guid2);
  });

  test('throws for bad data', () async {
    final Pointer<GUID> guid = calloc<GUID>();

    expect(() => guid.ref.parse('{00112233-4455-6677-88'), throwsArgumentError);

    calloc.free(guid);
  });
}
