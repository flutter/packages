// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_android/src/file_selector_android.dart';
import 'package:file_selector_android/file_selector_android_method_channel.dart';
import 'package:file_selector_android/file_selector_android_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFileSelectorAndroidPlatform
    with MockPlatformInterfaceMixin
    implements FileSelectorAndroidPlatform {
  @override
  Future<String?> getPlatformVersion() => Future<String>.value('42');
}

void main() {
  final FileSelectorAndroidPlatform initialPlatform =
      FileSelectorAndroidPlatform.instance;

  test('$MethodChannelFileSelectorAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFileSelectorAndroid>());
  });

  test('getPlatformVersion', () async {
    final FileSelectorAndroid fileSelectorAndroidPlugin = FileSelectorAndroid();
    final MockFileSelectorAndroidPlatform fakePlatform =
        MockFileSelectorAndroidPlatform();
    FileSelectorAndroidPlatform.instance = fakePlatform;

    expect(await fileSelectorAndroidPlugin.getPlatformVersion(), '42');
  });
}
