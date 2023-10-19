// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  cppOptions: CppOptions(namespace: 'file_selector_windows'),
  cppHeaderOut: 'windows/messages.g.h',
  cppSourceOut: 'windows/messages.g.cpp',
  copyrightHeader: 'pigeons/copyright.txt',
))
class TypeGroup {
  TypeGroup(this.label, {required this.extensions});

  String label;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The C++ code treats all of it as non-nullable.
  List<String?> extensions;
}

class SelectionOptions {
  SelectionOptions({
    this.allowMultiple = false,
    this.selectFolders = false,
    this.allowedTypes = const <TypeGroup?>[],
  });
  bool allowMultiple;
  bool selectFolders;

  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The C++ code treats the values as non-nullable.
  List<TypeGroup?> allowedTypes;
}

/// The result from an open or save dialog.
class FileDialogResult {
  FileDialogResult({required this.paths, this.typeGroupIndex});

  /// The selected paths.
  ///
  /// Empty if the dialog was canceled.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The Dart code treats the values as non-nullable.
  List<String?> paths;

  /// The type group index (into the list provided in [SelectionOptions]) of
  /// the group that was selected when the dialog was confirmed.
  ///
  /// Null if no type groups were provided, or the dialog was canceled.
  int? typeGroupIndex;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  FileDialogResult showOpenDialog(
    SelectionOptions options,
    String? initialDirectory,
    String? confirmButtonText,
  );
  FileDialogResult showSaveDialog(
    SelectionOptions options,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  );
}
