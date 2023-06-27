import 'dart:typed_data';

/// Platform agnostic API for retrieving data from the network. In this case,
/// for RFW data and Wasm modules.
abstract class Network {
  Future<Uint8List> get(String url);
}

/// Platform agnostic API for loading Wasm modules and calling Wasm functions.
abstract class Wasm {
  Future<void> loadModule(String url);
  dynamic call(String name, [List<Object?>? arguments]);
}

