// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'src/generated/native_interop_tests.gen.dart';

/// Passive entrypoint used when spinning up a headless secondary engine solely
/// to exercise native plugin registration and engine teardown.
@pragma('vm:entry-point')
void idleSecondaryEngineMain() {}

/// Active entrypoint executed inside a secondary `FlutterEngine` to verify
/// multi-engine Native Interop Host API calls from a separate live Dart isolate.
@pragma('vm:entry-point')
Future<void> secondaryEngineMain() async {
  var ready = false;
  for (var i = 0; i < 200; i++) {
    final probeApi = NativeInteropHostIntegrationCoreApi.createWithNativeInteropApi();
    if (await probeApi.isSecondaryEngineRegistrationReady()) {
      ready = true;
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  if (!ready) {
    return;
  }
  final hostApi = NativeInteropHostIntegrationCoreApi.createWithNativeInteropApi();
  final reservedApi = NativeInteropReservedNamesHostApi.createWithNativeInteropApi();
  final String echoed = await hostApi.echoString('from_secondary_engine');
  final String reservedType = await reservedApi.type();
  await hostApi.reportSecondaryEngineCheck(
    echoed == 'from_secondary_engine' && reservedType == 'type',
  );
}
