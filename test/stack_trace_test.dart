// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sentry/src/stack_trace.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  group('stackTraceFrameToJsonFrame', () {
    test('marks dart: frames as not app frames', () {
      final Frame frame = new Frame(Uri.parse('dart:core'), 1, 2, 'buzz');
      expect(stackTraceFrameToJsonFrame(frame), {
        'abs_path': 'dart:core',
        'function': 'buzz',
        'lineno': 1,
        'in_app': false,
        'filename': 'core'
      });
    });

    test('cleanses absolute paths', () {
      final Frame frame =
          new Frame(Uri.parse('file://foo/bar/baz.dart'), 1, 2, 'buzz');
      expect(stackTraceFrameToJsonFrame(frame)['abs_path'], 'baz.dart');
    });
  });
}
