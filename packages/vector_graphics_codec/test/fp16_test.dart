// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:vector_graphics_codec/src/fp16.dart';

double convert(double value) {
  final ByteData byteData = ByteData(8);
  byteData.setFloat32(0, value);
  toHalf(byteData);
  return toDouble(byteData);
}

void main() {
  test('fp16 positive values', () {
    final List<List<double>> missed = <List<double>>[];

    /// Validate that all numbers between [min] and [max] can be converted within [tolerance].
    void checkRange(
        {required double min, required double max, required double tolerance}) {
      final ByteData byteData = ByteData(8);
      for (double i = min; i < max; i += 1) {
        byteData.setFloat32(0, i);
        toHalf(byteData);

        final double result = toDouble(byteData);
        if ((result - i).abs() > tolerance) {
          missed.add(<double>[i, result]);
        }
      }
    }

    // The first 2048 values can be represented within 1.0.
    checkRange(min: 0, max: 2048, tolerance: 1.0);

    // 2048-4096 values can be represented within 2.0.
    checkRange(min: 2048, max: 4096, tolerance: 2.0);

    // 4096	- 8192 can be represented within 4.0.
    checkRange(min: 4096, max: 8192, tolerance: 4.0);

    // 8192	- 16384	can be represented within 8.0.
    checkRange(min: 8192, max: 16384, tolerance: 8.0);

    // 16384 -	32768	can be represented within 16.0.
    checkRange(min: 16384, max: 32768, tolerance: 16.0);

    // 32768 -	65519	can be represented within 32.0.
    checkRange(min: 32768, max: 65519, tolerance: 16.0);

    expect(missed, isEmpty);
  });

  test('fp16 signed values', () {
    expect(convert(-1.0), -1.0);
    expect(convert(-100.0), -100.0);
    expect(convert(-125.4375), -125.4375);
    expect(convert(-12500.5), -12504.0);
  });

  test('fp16 sentinel values', () {
    expect(convert(double.infinity), double.infinity);
    expect(convert(65520), double.infinity);
    expect(convert(double.nan), isNaN);
    expect(convert(double.negativeInfinity), double.negativeInfinity);
  });
}
