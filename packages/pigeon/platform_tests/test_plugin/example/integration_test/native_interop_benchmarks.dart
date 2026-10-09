// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:integration_test/integration_test.dart';
import 'package:shared_test_plugin_code/native_interop_benchmarks.dart';
import 'package:shared_test_plugin_code/native_interop_integration_tests.dart';

/// Runs the native interop benchmarks.
///
/// Run this in release mode with `dart run tool/benchmark.dart`, since debug
/// builds exaggerate every cost.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runNativeInteropBenchmarks(Platform.isAndroid ? TargetGenerator.kotlin : TargetGenerator.swift);
}
