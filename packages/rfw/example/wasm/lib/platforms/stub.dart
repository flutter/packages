import 'dart:typed_data';

import 'platform.dart';

class NetworkImplementation extends Network {
  @override
  Future<Uint8List> get(String url) async {
    throw UnimplementedError();
  }
}

class WasmImplementation extends Wasm {
  @override
  Future<void> loadModule(String url) async {
    throw UnimplementedError();
  }

  @override
  T callFunction<T>(String name, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }
}
