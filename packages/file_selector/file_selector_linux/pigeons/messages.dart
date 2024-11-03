// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeons/messages.dart',
  gobjectHeaderOut: 'linux/messages.g.h',
  gobjectSourceOut: 'linux/messages.g.cc',
  gobjectOptions: GObjectOptions(module: 'Ffs'),
  dartOut: 'lib/src/messages.g.dart',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// A Pigeon representation of the GTK_FILE_CHOOSER_ACTION_* options.
enum PlatformFileChooserActionType { open, chooseDirectory, save }

/// A Pigeon representation of the Linux portion of an `XTypeGroup`.
class PlatformTypeGroup {
  const PlatformTypeGroup({
    this.label = '',
    this.extensions = const <String>[],
    this.mimeTypes = const <String>[],
  });

  final String label;
  final List<String> extensions;
  final List<String> mimeTypes;
}

/// Options for GKT file chooser.
///
/// These correspond to gtk_file_chooser_set_* options.
class PlatformFileChooserOptions {
  PlatformFileChooserOptions({
    required this.allowedFileTypes,
    required this.currentFolderPath,
    required this.currentName,
    required this.acceptButtonLabel,
    this.selectMultiple,
  });

  final List<PlatformTypeGroup>? allowedFileTypes;
  final String? currentFolderPath;
  final String? currentName;
  final String? acceptButtonLabel;

  /// Whether to allow multiple file selection.
  ///
  /// Nullable because it does not apply to the "save" action.
  final bool? selectMultiple;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  /// Shows an file chooser with the given [type] and [options], returning the
  /// list of selected paths.
  ///
  /// An empty list corresponds to a cancelled selection.
  List<String> showFileChooser(
      PlatformFileChooserActionType type, PlatformFileChooserOptions options);
}
