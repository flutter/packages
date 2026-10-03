// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

String readTestString(String path) => File(path).readAsStringSync();
Uint8List readTestBytes(String path) => File(path).readAsBytesSync();
void writeFailureImage(String name, Uint8List data) {
  final directory = Directory('build/filter_failures')..createSync(recursive: true);
  File('${directory.path}/$name.actual.png').writeAsBytesSync(data);
}

Future<void> loadTestFiles() async {}
