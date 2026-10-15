// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Saves a file on web (stub for non-web platforms).
Future<void> saveFileWeb(String fileName, String text) async {
  throw UnsupportedError('Web saving is not supported on non-web platforms.');
}
