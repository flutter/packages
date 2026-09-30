// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT LAND: diagnostics for https://github.com/flutter/flutter/issues/193452.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:integration_test/integration_test.dart';

@JS('__gmDiagInstall')
external JSFunction? get _installFn;

@JS('__gmDiagSnapshot')
external JSFunction? get _snapshotFn;

@JS('__gmDiagBreadcrumb')
external JSFunction? get _breadcrumbFn;

final List<Map<String, Object?>> _testMapTelemetry = <Map<String, Object?>>[];

/// Installs the `google.maps.Map` wrapper from `web/gm_diag.js`, if the Maps
/// API has loaded. Safe to call repeatedly.
bool installMapDiagnostics() {
  final JSFunction? install = _installFn;
  if (install == null) {
    return false;
  }
  return (install.callAsFunction() as JSBoolean?)?.toDart ?? false;
}

/// Appends a diagnostic breadcrumb to `window.__gmDiag.breadcrumbs`.
void recordBreadcrumb(String message) {
  installMapDiagnostics();
  _breadcrumbFn?.callAsFunction(null, message.toJS);
}

/// A JSON snapshot of every recent map's lifecycle, layout, pending tiles,
/// Maps network activity and console errors.
String mapDiagnostics() {
  installMapDiagnostics();
  final JSFunction? snapshot = _snapshotFn;
  if (snapshot == null) {
    return '{"error": "web/gm_diag.js did not load"}';
  }
  try {
    return (snapshot.callAsFunction()! as JSString).toDart;
  } catch (e) {
    return '{"error": ${_quote('snapshot threw: $e')}}';
  }
}

/// Decoded JSON snapshot from [mapDiagnostics].
Map<String, Object?> mapDiagnosticsMap() => jsonDecode(mapDiagnostics()) as Map<String, Object?>;

/// Waits up to 8 seconds for the most recently created map's `tilesloaded`
/// event to fire, then records its lifecycle timings into
/// [IntegrationTestWidgetsFlutterBinding.reportData].
Future<void> recordLatestMapTelemetry(int readyMs) async {
  final watch = Stopwatch()..start();
  Map<String, Object?> diag = mapDiagnosticsMap();
  var record = <String, Object?>{};
  while (true) {
    final List<Object?> maps = (diag['maps'] as List<Object?>?) ?? <Object?>[];
    record = maps.isEmpty ? <String, Object?>{} : maps.last! as Map<String, Object?>;
    if (record['firstTilesloadedMs'] != null || watch.elapsed >= const Duration(seconds: 8)) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    diag = mapDiagnosticsMap();
  }
  final entry = <String, Object?>{
    'id': record['id'],
    'readyMs': readyMs,
    'firstProjectionMs': record['firstProjectionMs'],
    'firstBoundsMs': record['firstBoundsMs'],
    'firstIdleMs': record['firstIdleMs'],
    'firstLaidOutIdleMs': record['firstLaidOutIdleMs'],
    'firstTilesloadedMs': record['firstTilesloadedMs'],
    'layoutAtCreation': record['layoutAtCreation'],
    'resourcesByType': diag['resourcesByType'],
    if (record['firstTilesloadedMs'] == null) 'diag': diag,
  };
  _testMapTelemetry.add(entry);
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, Object?> report = binding.reportData ?? <String, Object?>{};
  report['gm_test_maps'] = _testMapTelemetry;
  binding.reportData = report;
}

String _quote(String s) => '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
