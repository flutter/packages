// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

String getFlutterCommand() => Platform.isWindows ? 'flutter.bat' : 'flutter';

/// Returns the first device listed by `flutter devices` that targets
/// [platform], or null if there is no such device.
Future<String?> getDeviceForPlatform(String platform) async {
  final ProcessResult result = await Process.run(getFlutterCommand(), <String>[
    'devices',
    '--machine',
  ], stdoutEncoding: utf8);
  if (result.exitCode != 0) {
    return null;
  }

  String output = result.stdout as String;
  // --machine doesn't currently prevent the tool from printing banners;
  // see https://github.com/flutter/flutter/issues/86055. This workaround
  // can be removed once that is fixed.
  output = output.substring(output.indexOf('['));

  final List<Map<String, dynamic>> devices =
      (jsonDecode(output) as List<dynamic>).cast<Map<String, dynamic>>();
  for (final Map<String, dynamic> deviceInfo in devices) {
    final String targetPlatform =
        (deviceInfo['targetPlatform'] as String?) ?? '';
    if (targetPlatform.startsWith(platform)) {
      final String? deviceId = deviceInfo['id'] as String?;
      if (deviceId != null) {
        return deviceId;
      }
    }
  }
  return null;
}
