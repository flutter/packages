// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// The logger for this package.
final Logger log = Logger('GoRouter');

StreamSubscription<LogRecord>? _subscription;

/// Forwards diagnostic messages to the dart:developer log() API.
void setLogging({bool enabled = false}) {
  _subscription?.cancel();
  if (!enabled) {
    return;
  }

  _subscription = log.onRecord.listen((LogRecord e) {
    // use `dumpErrorToConsole` for severe messages to ensure that severe
    // exceptions are formatted consistently with other Flutter examples and
    // avoids printing duplicate exceptions
    if (e.level >= Level.SEVERE) {
      final Object? error = e.error;
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: error is Exception ? error : Exception(error),
          stack: e.stackTrace,
          library: e.loggerName,
          context: ErrorDescription(e.message),
        ),
      );
    } else {
      developer.log(
        e.message,
        time: e.time,
        sequenceNumber: e.sequenceNumber,
        level: e.level.value,
        name: e.loggerName,
        zone: e.zone,
        error: e.error,
        stackTrace: e.stackTrace,
      );
    }
  });
}
