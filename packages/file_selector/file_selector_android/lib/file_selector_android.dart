// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'file_selector_android_platform_interface.dart';

class FileSelectorAndroid {
  Future<String?> getPlatformVersion() {
    return FileSelectorAndroidPlatform.instance.getPlatformVersion();
  }
}
