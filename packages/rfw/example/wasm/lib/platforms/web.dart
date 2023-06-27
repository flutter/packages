import 'dart:js_interop';;
import 'dart:typed_data';

import 'package:js/js_util.dart';
import 'package:web/web.dart';

import 'api.dart';

class NetworkImplementation extends Network {
  @override
  Future<List<int>> get(String url) async {
    return (await _loadByteBuffer(url)).asUint8List();
  }

  static Future<ByteBuffer> _loadByteBuffer(String url) async {
    final Response response = await promiseToFuture<Response>(window.fetch(url.toJS));
    return await promiseToFuture(response.arrayBuffer());
  }
}

class WasmImplementation extends Wasm {
  // This is this object https://developer.mozilla.org/en-US/docs/WebAssembly/JavaScript_interface/Instance/exports
  // which contains the Wasm memory and functions.
  late final JSObject _wasmExports;

  @override
  Future<void> loadModule(String url) async {
    // final ByteBuffer logicByteBuffer = await NetworkImplementation._loadByteBuffer(url);
    // wasmInstance = (
    //   await promiseToFuture<WebAssemblyInstantiatedSource>(
    //     WebAssembly.instantiate(logicByteBuffer.toJS)
    //   )
    // ).instance;
  }

  @override
  Future<dynamic> call(String name, List<Object?> arguments) async {
    // return callMethod(wasmInstance.exports, name, arguments);
  }
}