// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:vector_graphics_compiler/build.dart';

void main(List<String> args) {
  build(args, (BuildInput input, BuildOutputBuilder output) async {
    await addSvg(
      input,
      output,
      file: 'assets/example.svg',
      treeshakeable: true,
    );
  });
}
