// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/cross_file_darwin_apis.g.dart',
    swiftOut: 'darwin/Classes/CrossFileDarwinApis.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class CrossFileDarwinApi {
  String? tryCreateBookmarkedUrl(String url);

  bool isReadableFile(String url);

  bool fileExists(String url);

  int? fileModificationDate(String url);

  int? fileSize(String url);
}

@ProxyApi()
abstract class FileHandle {
  FileHandle.forReadingFromUrl(String url);

  Uint8List? readUpToCount(int count);

  Uint8List? readToEnd();

  int seek(int offset);

  void close();
}
