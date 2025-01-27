// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for iOS.
class FileSelectorIOS extends FileSelectorPlatform {
  final FileSelectorApi _hostApi = FileSelectorApi();

  /// Registers the iOS implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorIOS();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String> path = await _hostApi.openFile(FileSelectorConfig(
        utis: _allowedUtiListFromTypeGroups(acceptedTypeGroups)));
    return path.isEmpty ? null : XFile(path.first);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String> pathList = await _hostApi.openFile(FileSelectorConfig(
        utis: _allowedUtiListFromTypeGroups(acceptedTypeGroups),
        allowMultiSelection: true));
    return pathList.map((String path) => XFile(path)).toList();
  }

  // Converts the type group list into a list of all allowed UTIs, since
  // iOS doesn't support filter groups.
  List<String> _allowedUtiListFromTypeGroups(List<XTypeGroup>? typeGroups) {
    // iOS requires a list of allowed types, so allowing all is expressed via
    // a root type rather than an empty list.
    const List<String> allowAny = <String>['public.data'];

    if (typeGroups == null || typeGroups.isEmpty) {
      return allowAny;
    }
    final List<String> allowedUTIs = <String>[];
    for (final XTypeGroup typeGroup in typeGroups) {
      // If any group allows everything, no filtering should be done.
      if (typeGroup.allowsAny) {
        return allowAny;
      }
      if (typeGroup.uniformTypeIdentifiers?.isEmpty ?? true) {
        throw ArgumentError('The provided type group $typeGroup should either '
            'allow all files, or have a non-empty "uniformTypeIdentifiers"');
      }
      allowedUTIs.addAll(typeGroup.uniformTypeIdentifiers!);
    }
    return allowedUTIs;
  }
}
