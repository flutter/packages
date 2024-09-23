// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web_benchmarks/client.dart';

import '../common.dart';
import '../recorder.dart';

Future<void> main() async {
  await runBenchmarks(
    <String, RecorderFactory>{
      BenchmarkName.appNavigate.name: () =>
          TestAppRecorder(benchmark: BenchmarkName.appNavigate),
      BenchmarkName.appScroll.name: () =>
          TestAppRecorder(benchmark: BenchmarkName.appScroll),
      BenchmarkName.appTap.name: () =>
          TestAppRecorder(benchmark: BenchmarkName.appTap),
    },
  );
}
