// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

/// Fake implementation of PathProviderWindows that returns hard-coded paths,
/// allowing tests to run on any platform.
///
/// Note that this should only be used with an in-memory filesystem, as the
/// path it returns is a root path that does not actually exist on Windows.
class FakePathProviderWindows extends PathProviderPlatform
    implements PathProviderWindows {
  @override
  late VersionInfoQuerier versionInfoQuerier;

  @override
  Future<String?> getApplicationSupportPath() async => r'C:\appsupport';

  @override
  Future<String?> getTemporaryPath() async => null;

  @override
  Future<String?> getLibraryPath() async => null;

  @override
  Future<String?> getApplicationDocumentsPath() async => null;

  @override
  Future<String?> getDownloadsPath() async => null;

  @override
  Future<String> getPath(String folderID) async => '';
}
