// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$PathProviderPlatform', () {
    test('$MethodChannelPathProvider is the default instance', () {
      expect(PathProviderPlatform.instance, isA<MethodChannelPathProvider>());
    });

    test('getApplicationCachePath throws unimplemented error', () {
      final ExtendsPathProviderPlatform pathProviderPlatform =
          ExtendsPathProviderPlatform();

      expect(
        () => pathProviderPlatform.getApplicationCachePath(),
        throwsUnimplementedError,
      );
    });
  });
}

class ExtendsPathProviderPlatform extends PathProviderPlatform {}
