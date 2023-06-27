import 'dart:io';
import 'dart:typed_data';

import 'package:wasm/wasm.dart';

import 'platform.dart';

// This file implements the Network and Wasm APIs through the wasm package
// for desktop.

class NetworkImplementation extends Network {
  @override
  Future<Uint8List> get(String url) async {
    final HttpClientResponse client = await (await HttpClient().getUrl(Uri.parse(url))).close();
    return Uint8List.fromList(await client.expand((List<int> chunk) => chunk).toList());
  }
}

class WasmImplementation extends Wasm {
  late final WasmInstance _wasmInstance;

  @override
  Future<void> loadModule(String url) async {
    final wasmBytes = await NetworkImplementation().get(url);
    _wasmInstance = WasmModule(wasmBytes).builder().build();
  }

  @override
  dynamic call(String name, [List<Object?>? arguments]) {
    final WasmFunction function = _wasmInstance.lookupFunction(name);
    return function.apply(arguments ?? const <Object>[]);
  }
}
