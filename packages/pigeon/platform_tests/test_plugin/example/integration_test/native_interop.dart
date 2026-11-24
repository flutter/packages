// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:integration_test/integration_test.dart';
import 'package:shared_test_plugin_code/native_interop_integration_tests.dart';
import 'package:shared_test_plugin_code/secondary_engine_entrypoints.dart' as secondary_entrypoints;

/// Runs only the native interop tests.
///
/// Native interop reaches generated classes by name, which R8 can break in
/// minified builds, so this is run as a release build with `flutter run`,
/// which unlike `flutter test` and `flutter drive` supports release mode.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runPigeonNativeInteropIntegrationTests(TargetGenerator.kotlin);
}

@pragma('vm:entry-point')
void idleSecondaryEngineMain() => secondary_entrypoints.idleSecondaryEngineMain();

@pragma('vm:entry-point')
Future<void> secondaryEngineMain() => secondary_entrypoints.secondaryEngineMain();
