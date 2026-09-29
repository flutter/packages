// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT LAND: diagnostics for https://github.com/flutter/flutter/issues/193452.

import 'dart:js_interop';

@JS('__gmDiagInstall')
external JSFunction? get _installFn;

@JS('__gmDiagSnapshot')
external JSFunction? get _snapshotFn;

/// Installs the `google.maps.Map` wrapper from `web/gm_diag.js`, if the Maps
/// API has loaded. Safe to call repeatedly.
bool installMapDiagnostics() {
  final JSFunction? install = _installFn;
  if (install == null) {
    return false;
  }
  return (install.callAsFunction() as JSBoolean?)?.toDart ?? false;
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

String _quote(String s) => '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
