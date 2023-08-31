// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/logging.dart';
import 'package:logging/logging.dart';

void main() {
  test('setLogging does not clear listeners', () {
    log.onRecord
        .listen(expectAsync1<void, LogRecord>((LogRecord r) {}, count: 2));
    setLogging(enabled: true);
    log.info('message');
    setLogging();
    log.info('message');
  });
}
