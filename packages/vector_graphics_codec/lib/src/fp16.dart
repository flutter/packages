// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(stuartmorgan): Fix the lack of documentation, and remove the
//  public_member_api_docs ignore directive. See
//  https://github.com/flutter/flutter/issues/157616
// ignore_for_file: constant_identifier_names, public_member_api_docs

/// Adapted from libcore/util/FP16.java from the Android SDK.
/// https://en.wikipedia.org/wiki/Half-precision_floating-point_format
library fp16;

import 'dart:typed_data';

const int FP32_SIGN_SHIFT = 31;
const int FP32_EXPONENT_SHIFT = 23;
const int FP32_SHIFTED_EXPONENT_MASK = 0xff;
const int FP32_SIGNIFICAND_MASK = 0x7fffff;
const int FP32_EXPONENT_BIAS = 127;
const int FP32_QNAN_MASK = 0x400000;
const int FP32_DENORMAL_MAGIC = 126 << 23;
const int EXPONENT_BIAS = 15;
const int SIGN_SHIFT = 15;
const int EXPONENT_SHIFT = 10;
const int SIGN_MASK = 0x8000;
const int SHIFTED_EXPONENT_MASK = 0x1f;
const int SIGNIFICAND_MASK = 0x3ff;

// ignore: non_constant_identifier_names
final ByteData FP32_DENORMAL_FLOAT = ByteData(4)
  ..setUint32(0, FP32_DENORMAL_MAGIC);

/// Convert the single precision floating point value stored in [byteData] into a half-precision floating point value.
///
/// This value is stored in the same bytedata instance.
void toHalf(ByteData byteData) {
  final int bits = byteData.getInt32(0);
  final int s = bits >> FP32_SIGN_SHIFT;
  int e = (bits >> FP32_EXPONENT_SHIFT) & FP32_SHIFTED_EXPONENT_MASK;
  int m = bits & FP32_SIGNIFICAND_MASK;
  int outE = 0;
  int outM = 0;

  if (e == 0xff) {
    // Infinite or NaN
    outE = 0x1f;
    outM = m != 0 ? 0x200 : 0;
  } else {
    e = e - FP32_EXPONENT_BIAS + EXPONENT_BIAS;
    if (e >= 0x1f) {
      // Overflow
      outE = 0x1f;
    } else if (e <= 0) {
      // Underflow
      if (e < -10) {
        // The absolute fp32 value is less than MIN_VALUE, flush to +/-0
      } else {
        // The fp32 value is a normalized float less than MIN_NORMAL,
        // we convert to a denorm fp16
        m = m | 0x800000;
        final int shift = 14 - e;
        outM = m >> shift;
        final int lowm = m & ((1 << shift) - 1);
        final int hway = 1 << (shift - 1);
        // if above halfway or exactly halfway and outM is odd
        if (lowm + (outM & 1) > hway) {
          // Round to nearest even
          // Can overflow into exponent bit, which surprisingly is OK.
          // This increment relies on the +outM in the return statement below
          outM++;
        }
      }
    } else {
      outE = e;
      outM = m >> 13;
      // if above halfway or exactly halfway and outM is odd
      if ((m & 0x1fff) + (outM & 0x1) > 0x1000) {
        // Round to nearest even
        // Can overflow into exponent bit, which surprisingly is OK.
        // This increment relies on the +outM in the return statement below
        outM++;
      }
    }
  }
  // The outM is added here as the +1 increments for outM above can
  // cause an overflow in the exponent bit which is OK.
  byteData.setUint16(0, (s << SIGN_SHIFT) | (outE << EXPONENT_SHIFT) + outM);
}

/// Convert the single precision floating point value stored in [byteData] into a double
/// precision floating point value.
double toDouble(ByteData byteData) {
  final int h = byteData.getUint16(0);
  final int bits = h & 0xffff;
  final int s = bits & SIGN_MASK;
  final int e = (bits >> EXPONENT_SHIFT) & SHIFTED_EXPONENT_MASK;
  final int m = bits & SIGNIFICAND_MASK;
  int outE = 0;
  int outM = 0;
  if (e == 0) {
    // Denormal or 0
    if (m != 0) {
      // Convert denorm fp16 into normalized fp32
      byteData.setUint32(0, FP32_DENORMAL_MAGIC + m);
      double o = byteData.getFloat32(0);
      o -= FP32_DENORMAL_FLOAT.getFloat32(0);
      return s == 0 ? o : -o;
    }
  } else {
    outM = m << 13;
    if (e == 0x1f) {
      // Infinite or NaN
      outE = 0xff;
      if (outM != 0) {
        // SNaNs are quieted
        outM |= FP32_QNAN_MASK;
      }
    } else {
      outE = e - EXPONENT_BIAS + FP32_EXPONENT_BIAS;
    }
  }
  final int out = (s << 16) | (outE << FP32_EXPONENT_SHIFT) | outM;
  byteData.setUint32(0, out);
  return byteData.getFloat32(0);
}
