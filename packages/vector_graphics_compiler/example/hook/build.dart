// Copyright 2025 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:vector_graphics_compiler/build.dart';

void main(List<String> args) {
  build(args, (BuildInput input, BuildOutputBuilder output) async {
    await compileSvg(
      input,
      output,
      name: 'example_file',
      file: input.packageRoot.resolve('assets/example.svg'),
      options: const Options(dumpDebug: true, concurrency: 2),
    );
  });
}
