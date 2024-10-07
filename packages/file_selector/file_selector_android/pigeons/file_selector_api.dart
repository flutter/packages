// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/file_selector_api.g.dart',
    javaOut:
        'android/src/main/java/dev/flutter/packages/file_selector_android/GeneratedFileSelectorApi.java',
    javaOptions: JavaOptions(
      package: 'dev.flutter.packages.file_selector_android',
      className: 'GeneratedFileSelectorApi',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class FileResponse {
  late final String path;
  late final String? mimeType;
  late final String? name;
  late final int size;
  late final Uint8List bytes;
}

class FileTypes {
  late List<String> mimeTypes;
  late List<String> extensions;
}

/// An API to call to native code to select files or directories.
@HostApi()
abstract class FileSelectorApi {
  /// Opens a file dialog for loading files and returns a file path.
  ///
  /// Returns `null` if user cancels the operation.
  @async
  FileResponse? openFile(String? initialDirectory, FileTypes allowedTypes);

  /// Opens a file dialog for loading files and returns a list of file responses
  /// chosen by the user.
  @async
  List<FileResponse> openFiles(
    String? initialDirectory,
    FileTypes allowedTypes,
  );

  /// Opens a file dialog for loading directories and returns a directory path.
  ///
  /// Returns `null` if user cancels the operation.
  @async
  String? getDirectoryPath(String? initialDirectory);
}
