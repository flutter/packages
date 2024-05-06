// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  objcHeaderOut:
      'ios/file_selector_ios/Sources/file_selector_ios/include/file_selector_ios/messages.g.h',
  objcSourceOut: 'ios/file_selector_ios/Sources/file_selector_ios/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FFS',
    headerIncludePath: './include/file_selector_ios/messages.g.h',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class FileSelectorConfig {
  FileSelectorConfig(
      {this.utis = const <String?>[], this.allowMultiSelection = false});
  List<String?> utis;
  bool allowMultiSelection;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  @async
  @ObjCSelector('openFileSelectorWithConfig:')
  List<String> openFile(FileSelectorConfig config);
}
