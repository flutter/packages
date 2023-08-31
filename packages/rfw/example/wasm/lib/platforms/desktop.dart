// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wasm/wasm.dart';

import 'platform.dart';

// This file implements the Network and Wasm APIs through the wasm package
// for desktop.

class NetworkImplementation extends Network {
  @override
  Future<Uint8List> get(String url) async {
    final DateTime expiryDate =
        DateTime.now().subtract(const Duration(hours: 6));
    final Directory home = await getApplicationSupportDirectory();
    final Uri uri = Uri.parse(url);
    final File interfaceFile =
        File(path.join(home.path, 'cache', uri.pathSegments.last));
    if (!interfaceFile.existsSync() ||
        interfaceFile.lastModifiedSync().isBefore(expiryDate)) {
      final HttpClientResponse client =
          await (await HttpClient().getUrl(Uri.parse(url))).close();
      final Uint8List bytes = Uint8List.fromList(
          await client.expand((List<int> chunk) => chunk).toList());
      interfaceFile.createSync(recursive: true);
      await interfaceFile.writeAsBytes(bytes);
      return bytes;
    } else {
      return interfaceFile.readAsBytesSync();
    }
  }
}

class WasmImplementation extends Wasm {
  WasmImplementation({required Network network}) : super(network: network);

  late final WasmInstance _wasmInstance;

  @override
  Future<void> loadModule(String url) async {
    final wasmBytes = await network.get(url);
    _wasmInstance = WasmModule(wasmBytes).builder().build();
  }

  @override
  T callFunction<T>(String name, [List<Object?>? arguments]) {
    final WasmFunction function = _wasmInstance.lookupFunction(name);
    return function.apply(arguments ?? const <Object>[]);
  }
}
