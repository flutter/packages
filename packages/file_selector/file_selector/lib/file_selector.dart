// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

export 'package:file_selector_platform_interface/file_selector_platform_interface.dart'
    show
        FileSaveLocation,
        FileSystemXDirectory,
        FileSystemXFile,
        ScopedStorageXDirectory,
        ScopedStorageXFile,
        XDirectory,
        XEntity,
        XFile,
        XTypeGroup;

/// Opens a file selection dialog and returns the path chosen by the user.
///
/// [acceptedTypeGroups] is a list of file type groups that can be selected in
/// the dialog. How this is displayed depends on the platform, for example:
/// - On Windows and Linux, each group will be an entry in a list of filter
///   options.
/// - On macOS, the union of all types allowed by all of the groups will be
///   allowed.
/// Throws an [ArgumentError] if any type groups do not include filters
/// supported by the current platform.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location. This is ignored on the Web platform.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
/// This is ignored on the Web platform.
///
/// Returns `null` if the user cancels the operation.
Future<XFile?> openFile({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? confirmButtonText,
}) {
  return _assertInstanceIsSet().openFile(
    OpenDialogOptions(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText,
    ),
  );
}

/// Opens a file selection dialog and returns the list of paths chosen by the
/// user.
///
/// [acceptedTypeGroups] is a list of file type groups that can be selected in
/// the dialog. How this is displayed depends on the platform, for example:
/// - On Windows and Linux, each group will be an entry in a list of filter
///   options.
/// - On macOS, the union of all types allowed by all of the groups will be
///   allowed.
/// Throws an [ArgumentError] if any type groups do not include filters
/// supported by the current platform.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
///
/// Returns an empty list if the user cancels the operation.
Future<List<XFile>> openFiles({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? confirmButtonText,
}) {
  return _assertInstanceIsSet().openFiles(
    OpenDialogOptions(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText,
    ),
  );
}

/// Opens a save dialog and returns the target path chosen by the user.
///
/// [acceptedTypeGroups] is a list of file type groups that can be selected in
/// the dialog. How this is displayed depends on the platform, for example:
/// - On Windows and Linux, each group will be an entry in a list of filter
///   options.
/// - On macOS, the union of all types allowed by all of the groups will be
///   allowed.
/// Throws an [ArgumentError] if any type groups do not include filters
/// supported by the current platform.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [suggestedName] is initial value of file name.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Save").
///
/// [canCreateDirectories] controls whether the user is allowed to create new
/// directories in the save dialog. When not provided, uses the platform default.
/// May not be supported on all platforms.
///
/// Returns `null` if the user cancels the operation.
Future<FileSaveLocation?> getSaveLocation({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? suggestedName,
  String? confirmButtonText,
  bool? canCreateDirectories,
}) async {
  return _assertInstanceIsSet().getSaveLocation(
    SaveLocationOptions(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      suggestedName: suggestedName,
      confirmButtonText: confirmButtonText,
      canCreateDirectories: canCreateDirectories,
    ),
  );
}

/// Opens a directory selection dialog and returns the path chosen by the user.
///
/// This always returns `null` on the web.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
///
/// [canCreateDirectories] controls whether the user is allowed to create new
/// directories in the dialog. When not provided, uses the platform default.
/// May not be supported on all platforms.
///
/// Returns `null` if the user cancels the operation.
Future<XDirectory?> getDirectory({
  String? initialDirectory,
  String? confirmButtonText,
  bool? canCreateDirectories,
}) async {
  return _assertInstanceIsSet().getDirectory(
    FileDialogOptions(
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText,
      canCreateDirectories: canCreateDirectories,
    ),
  );
}

/// Opens a directory selection dialog and returns a list of the paths chosen
/// by the user.
///
/// This always returns an empty array on the web.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
///
/// [canCreateDirectories] controls whether the user is allowed to create new
/// directories in the dialog. When not provided, uses the platform default.
/// May not be supported on all platforms.
///
/// Returns an empty array if the user cancels the operation.
Future<List<XDirectory>> getDirectories({
  String? initialDirectory,
  String? confirmButtonText,
  bool? canCreateDirectories,
}) async {
  return _assertInstanceIsSet().getDirectories(
    FileDialogOptions(
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText,
      canCreateDirectories: canCreateDirectories,
    ),
  );
}

FileSelectorPlatform _assertInstanceIsSet() {
  assert(
    FileSelectorPlatform.instance != null,
    'A platform implementation for `file_selector` has not been set. Please '
    'ensure that an implementation of `FileSelectorPlatform` has been set to '
    '`FileSelectorPlatform.instance` before use. For unit testing, '
    '`FileSelectorPlatform.instance` can be set with your own test implementation.',
  );
  return FileSelectorPlatform.instance!;
}
