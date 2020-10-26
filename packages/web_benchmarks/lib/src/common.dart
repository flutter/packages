// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This library contains code that's common between the client and the server.
///
/// The code must be compilable both as a command-line program and as a web
/// program.
library web_benchmarks.common;

/// The number of samples we use to collect statistics from.
const int kMeasuredSampleCount = 100;
