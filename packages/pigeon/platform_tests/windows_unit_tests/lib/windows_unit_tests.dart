
import 'dart:async';

import 'package:flutter/services.dart';

class WindowsUnitTests {
  static const MethodChannel _channel = MethodChannel('windows_unit_tests');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
