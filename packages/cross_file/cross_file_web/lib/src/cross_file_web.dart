// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'web_cross_file.dart';

/// Implementation of [CrossFilePlatform] for web.
base class CrossFileWeb extends CrossFilePlatform {
  /// Registers this class as the default instance of [CrossFilePlatform].
  static void registerWith(Registrar registrar) {
    CrossFilePlatform.instance = CrossFileWeb();
  }

  @override
  WebXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return WebXFile(params);
  }
}
