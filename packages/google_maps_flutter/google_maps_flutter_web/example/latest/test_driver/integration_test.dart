// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:integration_test/integration_test_driver.dart';

// DO NOT LAND: print reported data so CI logs contain the diagnostics for
// https://github.com/flutter/flutter/issues/193452.
Future<void> main() => integrationDriver(
  responseDataCallback: (Map<String, dynamic>? data) async {
    if (data != null) {
      // ignore: avoid_print
      print('INTEGRATION_RESPONSE_DATA: ${jsonEncode(data)}');
    }
  },
  writeResponseOnFailure: true,
);
