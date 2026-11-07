// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:cross_file_web/cross_file_web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:web/web.dart' as web;

/// Saves a file on web.
Future<void> saveFileWeb(String fileName, String text) async {
  final webFile = web.File(
    <JSAny>[text.toJS].toJS,
    fileName,
    web.FilePropertyBag(type: 'text/plain'),
  );
  final file = ScopedStorageXFile.fromCreationParams(
    WebScopedStorageXFileCreationParams.fromBlob(webFile),
  );
  await file.getExtension<WebScopedStorageXFileExtension>()!.download(fileName);
}
