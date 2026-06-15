// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;

import 'photo_kit_darwin_scoped_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[AssetResourceReader])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    CrossFilePlatform.instance = CrossFileDarwin();
  });
}
