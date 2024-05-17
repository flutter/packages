// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  swiftOut: 'ios/file_selector_ios/Sources/file_selector_ios/messages.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))
class FileSelectorConfig {
  FileSelectorConfig(
      {this.utis = const <String?>[], this.allowMultiSelection = false});
  // TODO(stuartmorgan): Declare these as non-nullable generics once
  // https://github.com/flutter/flutter/issues/97848 is fixed. In practice,
  // the values will never be null, and the native implementation assumes that.
  List<String?> utis;
  bool allowMultiSelection;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  @async
  @ObjCSelector('openFileSelectorWithConfig:')
  List<String> openFile(FileSelectorConfig config);
}
