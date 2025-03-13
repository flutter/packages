// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:cross_file_example/readme_excerpts.dart';
import 'package:test/test.dart';

const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop');

void main() {
  test('instantiateXFile loads asset file', () async {
    // Ensure that the snippet code runs successfully.
    final XFile xFile = await instantiateXFile();
    // It should have a nonempty path and name.
    expect(xFile.path, allOf(isNotNull, isNotEmpty));
    expect(xFile.name, allOf(isNotNull, isNotEmpty));

    // And the example file should have contents.
    final String fileContent = await xFile.readAsString();
    expect(fileContent, allOf(isNotNull, isNotEmpty));
  }, skip: kIsWeb);
}
