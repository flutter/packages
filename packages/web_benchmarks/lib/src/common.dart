// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This library contains code that's common between the client and the server.
///
/// The code must be compilable both as a command-line program and as a web
/// program.
library web_benchmarks.common;

/// The number of samples we use to collect statistics from.
const int kMeasuredSampleCount = 100;

/// A special value returned by the `/next-benchmark` HTTP POST request when
/// all benchmarks have run and there are no more benchmarks to run.
const String kEndOfBenchmarks = '__end_of_benchmarks__';

/// The default initial path for the URL that will be loaded upon opening the
/// benchmark app or reloading it in Chrome.
const String defaultInitialPath = 'index.html';
