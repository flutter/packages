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
    return (await _loadByteBuffer(url)).asUint8List();
  }

  static Future<ByteBuffer> _loadByteBuffer(String url) async {
    final Response response =
        await promiseToFuture<Response>(window.fetch(url.toJS));
    return await promiseToFuture(response.arrayBuffer());
  }
}

class WasmImplementation extends Wasm {
  // This is this object https://developer.mozilla.org/en-US/docs/WebAssembly/JavaScript_interface/Instance/exports
  // which contains the Wasm memory and functions.
  late final JSObject _wasmExports;

  @override
  Future<void> loadModule(String url) async {
    final ByteBuffer wasmByteBuffer =
        await NetworkImplementation._loadByteBuffer(url);
    final Instance wasmInstance =
        (await promiseToFuture<WebAssemblyInstantiatedSource>(
                WebAssembly.instantiate(wasmByteBuffer.toJS)))
            .instance;
    _wasmExports = wasmInstance.exports;
  }

  @override
  dynamic call(String name, [List<Object?>? arguments]) {
    // The wasm exports object contains the JSFunction objects that can be
    // called directly via the js_util helper function.
    return callMethod(_wasmExports, name, arguments ?? const <Object>[]);
  }
}
