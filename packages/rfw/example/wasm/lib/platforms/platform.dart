abstract class Network {
  Future<List<int>> get(String url);
}

abstract class Wasm {
  Future<void> loadModule(String url);
  Future<dynamic> call(String name, List<Object?> arguments);
}

class NetworkImplementation extends Network {
  @override
  Future<List<int>> get(String url) async {
    throw UnimplementedError();
  }
}

class WasmImplementation extends Wasm {

  @override
  Future<void> loadModule(String url) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> call(String name, List<Object?> arguments) async {
    throw UnimplementedError();
  }
}