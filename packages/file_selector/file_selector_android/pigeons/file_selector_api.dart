// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/file_selector_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/file_selector_android/GeneratedFileSelectorApi.kt',
    kotlinOptions: KotlinOptions(package: 'dev.flutter.packages.file_selector_android'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
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
  String? openFile(String? initialDirectory, FileTypes allowedTypes);

  /// Opens a file dialog for loading files and returns a list of file responses
  /// chosen by the user.
  @async
  List<String> openFiles(String? initialDirectory, FileTypes allowedTypes);

  /// Opens a file dialog for loading directories and returns a directory path.
  ///
  /// Returns `null` if user cancels the operation.
  @async
  String? getDirectoryPath(String? initialDirectory);
}
