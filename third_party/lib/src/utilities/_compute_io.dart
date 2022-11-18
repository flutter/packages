import 'dart:io';

import 'package:flutter/foundation.dart';

/// Whether to use an isolate-spawning version of compute or not.
final bool isTest =
    kDebugMode && Platform.executable.endsWith('flutter_tester') ||
        Platform.executable.endsWith('flutter_tester.exe');
