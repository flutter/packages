// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Compilation options for bulding a Flutter web app.
///
/// This object holds metadata that is used to determine how the benchmark app
/// should be built.
class CompilationOptions {
  /// Creates a [CompilationOptions] object that compiles to JavaScript.
  const CompilationOptions.js({
    this.renderer = WebRenderer.canvaskit,
  }) : useWasm = false;

  /// Creates a [CompilationOptions] object that compiles to WebAssembly.
  const CompilationOptions.wasm()
      : useWasm = true,
        renderer = WebRenderer.skwasm;

  /// The renderer to use for the build.
  final WebRenderer renderer;

  /// Whether to build the app with dart2wasm.
  final bool useWasm;

  @override
  String toString() {
    return '(renderer: ${renderer.name}, compiler: ${useWasm ? 'dart2wasm' : 'dart2js'})';
  }
}

/// The possible types of web renderers Flutter can build for.
enum WebRenderer {
  /// The HTML web renderer.
  html,

  /// The CanvasKit web renderer.
  canvaskit,

  /// The SKIA Wasm web renderer.
  skwasm,
}
