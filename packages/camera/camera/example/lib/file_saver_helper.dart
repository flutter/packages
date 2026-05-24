// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'file_saver_stub.dart'
    if (dart.library.js_util) 'file_saver_web.dart'
    if (dart.library.html) 'file_saver_web.dart';

/// Triggers a file download with a custom filename.
void downloadFile(String url, String fileName) {
  saveFile(url, fileName);
}
