// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The benchmark path to load in the URL when loading or reloading the
/// benchmark app in Chrome.
const String testBenchmarkPath = 'about';

enum BenchmarkName {
  appNavigate,
  appScroll,
  appTap,
  simpleBenchmarkPathCheck,
  simpleCompilationCheck;
}
