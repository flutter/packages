// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'src/generated/native_interop_tests.gen.dart';

/// Passive entrypoint used when spinning up a headless secondary engine solely
/// to exercise native plugin registration and engine teardown.
@pragma('vm:entry-point')
void idleSecondaryEngineMain() {}

/// Active entrypoint executed inside a secondary `FlutterEngine` to verify
/// multi-engine Native Interop Host API calls from a separate live Dart isolate.
@pragma('vm:entry-point')
Future<void> secondaryEngineMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hostApi = NativeInteropHostIntegrationCoreApi.createWithNativeInteropApi();
  var ready = false;
  for (var i = 0; i < 1200; i++) {
    if (await hostApi.isSecondaryEngineRegistrationReady()) {
      ready = true;
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  if (!ready) {
    await hostApi.reportSecondaryEngineCheck(false);
    return;
  }
  final reservedApi = NativeInteropReservedNamesHostApi.createWithNativeInteropApi();
  NativeInteropReservedNamesFlutterApi.setUp(_SecondaryEngineReservedNamesFlutterApi());
  NativeInteropFlutterIntegrationCoreApi.setUp(_SecondaryEngineAsyncFlutterApi());
  final String echoed = await hostApi.echoString('from_secondary_engine');
  final String reservedType = await reservedApi.type();
  final String flutterRelease = await reservedApi.callFlutterRelease('ping');
  final String flutterAsyncEcho = await hostApi.callFlutterEchoAsyncString('ping');
  NativeInteropFlutterIntegrationCoreApi.setUp(null);
  NativeInteropReservedNamesFlutterApi.setUp(null);
  await hostApi.reportSecondaryEngineCheck(
    echoed == 'from_secondary_engine' &&
        reservedType == 'type' &&
        flutterRelease == 'secondary:ping' &&
        flutterAsyncEcho == 'secondary_async:ping',
  );
}

class _SecondaryEngineReservedNamesFlutterApi extends NativeInteropReservedNamesFlutterApi {
  @override
  String release(String value) => 'secondary:$value';

  @override
  String type() => 'secondary_type';

  @override
  String implementIn(String value) => 'secondary:$value';

  @override
  bool isNull() => true;

  @override
  String getReference() => 'secondary_reference';

  @override
  String register(String value) => 'secondary:$value';

  @override
  String dartApi() => 'secondary_dartApi';
}

class _SecondaryEngineAsyncFlutterApi extends NativeInteropFlutterIntegrationCoreApi {
  @override
  Future<String> echoAsyncString(String aString) async {
    await Future<void>.delayed(Duration.zero);
    return 'secondary_async:$aString';
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
