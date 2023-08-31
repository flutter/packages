// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:js/js_util.dart';
import 'package:web/web.dart';

import 'platform.dart';

// This file implements the Network and Wasm APIs using browser APIs accessed
// through JS interop available for client web applications built in Wasm.

class NetworkImplementation extends Network {
  @override
  Future<Uint8List> get(String url) async {
    Response response = await promiseToFuture<Response>(window.fetch(url.toJS));
    ByteBuffer byteBuffer = await promiseToFuture(response.arrayBuffer());
    return byteBuffer.asUint8List();
  }
}

class WasmImplementation extends Wasm {
  WasmImplementation({required Network network}) : super(network: network);

  // This is this object https://developer.mozilla.org/en-US/docs/WebAssembly/JavaScript_interface/Instance/exports
  // which contains the Wasm memory and functions.
  late final JSObject _wasmExports;

  @override
  Future<void> loadModule(String url) async {
    final Uint8List wasmBytes = await network.get(url);
    final Instance wasmInstance =
        (await promiseToFuture<WebAssemblyInstantiatedSource>(
                WebAssembly.instantiate(wasmBytes.toJS)))
            .instance;
    _wasmExports = wasmInstance.exports;
  }

  @override
  T callFunction<T>(String name, [List<Object?>? arguments]) {
    // The Wasm exports object contains the JSFunction objects that can be
    // called directly via the js_util helper function.
    Object? result =
        callMethod(_wasmExports, name, arguments ?? const <Object>[]);

    // On web, even if the Wasm function returns an int, JS interop will turn
    // it into a double, which makes cross-platform APIs inconsistent. Convert
    // it back to an expected int if that's the caller expectation.
    if (T == int) {
      return (result as num).toInt() as T;
    }

    return result as T;
  }
}
