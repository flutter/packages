// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_benchmarks/client.dart';

import 'runner.dart';

class SimpleRecorder extends AppRecorder {
  SimpleRecorder() : super(benchmarkName: 'simple');

  @override
  Future<void> automate() async {
    // Record whether we are in wasm mode or not. Ideally, we'd have a more
    // first-class way to add metadata like this, but this will work for us to
    // pass information about the environment back to the server for the
    // purposes of our own tests.
    profile.extraData['isWasm'] = kIsWasm ? 1 : 0;
  }
}

Future<void> main() async {
  await runBenchmarks(<String, RecorderFactory>{
    'simple': () => SimpleRecorder(),
  });
}
