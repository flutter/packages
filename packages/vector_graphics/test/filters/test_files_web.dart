// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('fetch')
external JSPromise<_Response> _fetch(JSString url);

extension type _Response(JSObject _) implements JSObject {
  external bool get ok;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

final Map<String, Uint8List> _files = <String, Uint8List>{};

Future<Uint8List> _load(String path) async {
  final _Response response = await _fetch(Uri.base.resolve('/assets/$path').toString().toJS).toDart;
  if (!response.ok) {
    throw StateError('Missing browser test asset: $path');
  }
  return (await response.arrayBuffer().toDart).toDart.asUint8List();
}

Future<void> loadTestFiles() async {
  // Test registration precedes the first Flutter frame; fetch fixtures directly
  // rather than waiting for the engine's asset platform channel to initialize.
  final paths = jsonDecode(utf8.decode(await _load('test/filters/files.json'))) as List<dynamic>;
  for (var start = 0; start < paths.length; start += 16) {
    await Future.wait(
      paths.skip(start).take(16).cast<String>().map((String path) async {
        _files[path] = await _load(path);
      }),
    );
  }
}

Uint8List readTestBytes(String path) =>
    _files[path] ?? (throw StateError('Missing test asset: $path'));
String readTestString(String path) => utf8.decode(readTestBytes(path));
void writeFailureImage(String name, Uint8List data) {
  // The host extracts these PNGs from test output into build/filter_failures.
  // ignore: avoid_print
  print('FILTER_FAILURE_IMAGE:$name:${base64Encode(data)}');
}
