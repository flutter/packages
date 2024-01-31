// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:web_benchmarks/client.dart';

import 'runner.dart';

class SimpleRecorder extends AppRecorder {
  SimpleRecorder() : super(benchmarkName: 'simple');

  @override
  Future<void> automate() async {
    // Do nothing.
  }
}

Future<void> main() async {
  await runBenchmarks(<String, RecorderFactory>{
    'simple': () => SimpleRecorder(),
  });
}
