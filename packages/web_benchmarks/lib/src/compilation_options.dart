// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Compilation options for bulding a Flutter web app.
///
/// This object holds metadata that is used to determine how the benchmark app
/// should be built.
class CompilationOptions {
  /// Creates a [CompilationOptions] object that compiles to JavaScript.
  const CompilationOptions.js() : useWasm = false;

  /// Creates a [CompilationOptions] object that compiles to WebAssembly.
  const CompilationOptions.wasm() : useWasm = true;

  /// Whether to build the app with dart2wasm.
  final bool useWasm;

  @override
  String toString() {
    return '(compiler: ${useWasm ? 'dart2wasm' : 'dart2js'})';
  }
}
