// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Example script to illustrate how to use the bsdiff package to generate and apply patches.

import 'dart:typed_data';

import 'package:bsdiff/bsdiff.dart';

void main() async {
  final Uint8List originalData = Uint8List.fromList(List.generate(1000, (index) => index));
  final Uint8List modifiedData = Uint8List.fromList(List.generate(2000, (index) => 2 * index));

  print('Original data size ${originalData.length} bytes');
  print('Modified data size ${modifiedData.length} bytes');

  final Uint8List generatedPatch = bsdiff(originalData, modifiedData);
  final Uint8List restoredData = bspatch(originalData, generatedPatch);

  print('Generated patch is ${generatedPatch.length} bytes');
  print('Restored data size ${restoredData.length} bytes');
}
