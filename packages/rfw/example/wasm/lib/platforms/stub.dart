// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'platform.dart';

class NetworkImplementation extends Network {
  @override
  Future<Uint8List> get(String url) async {
    throw UnimplementedError();
  }
}

class WasmImplementation extends Wasm {
  WasmImplementation({required Network network}) : super(network: network);

  @override
  Future<void> loadModule(String url) async {
    throw UnimplementedError();
  }

  @override
  T callFunction<T>(String name, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }
}
