// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:integration_test/integration_test_driver.dart';

// Fail a hung test file after 5 minutes instead of the default 20, so a single
// hang doesn't use up most of the CI shard's 60-minute budget.
Future<void> main() => integrationDriver(timeout: const Duration(minutes: 5));
