// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Platform agnostic API for retrieving data from the network. In this case,
/// for RFW data and Wasm modules.
abstract class Network {
  Future<Uint8List> get(String url);
}

/// Platform agnostic API for loading Wasm modules and calling Wasm functions.
abstract class Wasm {
  final Network network;

  Wasm({required this.network});

  Future<void> loadModule(String url);
  T callFunction<T>(String name, [List<Object?>? arguments]);
}
