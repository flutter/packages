// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

/// Representation of the Win32 GUID struct.
// For the layout of this struct, see
// https://learn.microsoft.com/windows/win32/api/guiddef/ns-guiddef-guid
@Packed(4)
base class GUID extends Struct {
  /// Native Data1 field.
  @Uint32()
  external int data1;

  /// Native Data2 field.
  @Uint16()
  external int data2;

  /// Native Data3 field.
  @Uint16()
  external int data3;

  /// Native Data4 field.
  // This should be an eight-element byte array, but there's no such annotation.
  @Uint64()
  external int data4;

  /// Parses a GUID string, with optional enclosing "{}"s and optional "-"s,
  /// into data.
  void parse(String guid) {
    final String hexOnly = guid.replaceAll(RegExp(r'[{}-]'), '');
    if (hexOnly.length != 32) {
      throw ArgumentError.value(guid, 'guid', 'Invalid GUID string');
    }
    final ByteData bytes = ByteData(16);
    for (int i = 0; i < 16; ++i) {
      bytes.setUint8(
          i, int.parse(hexOnly.substring(i * 2, i * 2 + 2), radix: 16));
    }
    data1 = bytes.getInt32(0);
    data2 = bytes.getInt16(4);
    data3 = bytes.getInt16(6);
    // [bytes] is big endian, but the host is little endian, so a default
    // big-endian read would reverse the bytes. Since data4 is supposed to be
    // a byte array, the order should be preserved, so do a little-endian read.
    // https://en.wikipedia.org/wiki/Universally_unique_identifier#Encoding
    data4 = bytes.getInt64(8, Endian.little);
  }
}
