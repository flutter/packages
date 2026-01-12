// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data' show ByteData;

/// Whether the current platform is macOS.
bool get isMacOS => false;

/// Whether the current platform is Android.
bool get isAndroid => false;

/// Whether the code is running in the context of a test.
bool get isTest => false;

/// By default, file IO is stubbed out.
///
/// If the path provider library is available (on mobile or desktop), then the
/// implementation in `file_io_desktop_and_mobile.dart` is used.

/// Stubbed out version of saveFontToDeviceFileSystem from
/// `file_io_desktop_and_mobile.dart`.
Future<void> saveFontToDeviceFileSystem({
  required String name,
  required String fileHash,
  required List<int> bytes,
}) {
  return Future<void>.value();
}

/// Stubbed out version of loadFontFromDeviceFileSystem from
/// `file_io_desktop_and_mobile.dart`.
Future<ByteData?> loadFontFromDeviceFileSystem({
  required String name,
  required String fileHash,
}) {
  return Future<ByteData?>.value();
}
