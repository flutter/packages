// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/file_selector_api.g.dart',
    dartTestOut: 'test/test_file_selector_api.g.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
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

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  @async
  FileResponse? openFile(
    String? initialDirectory,
    List<String?> mimeTypes,
    List<String?> extensions,
  );

  @async
  List<FileResponse?> openFiles(
    String? initialDirectory,
    List<String?> mimeTypes,
    List<String?> extensions,
  );

  @async
  String? getDirectoryPath(String? initialDirectory);
}
