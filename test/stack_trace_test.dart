// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sentry/src/stack_trace.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  group('encodeStackTraceFrame', () {
    test('marks dart: frames as not app frames', () {
      final Frame frame = new Frame(Uri.parse('dart:core'), 1, 2, 'buzz');
      expect(encodeStackTraceFrame(frame), {
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
      expect(encodeStackTraceFrame(frame)['abs_path'], 'baz.dart');
    });
  });

  group('encodeStackTrace', () {
    test('encodes a simple stack trace', () {
      expect(encodeStackTrace('''
#0      baz (file:///pathto/test.dart:50:3)
#1      bar (file:///pathto/test.dart:46:9)
      '''), [
        {
          'abs_path': 'test.dart',
          'function': 'baz',
          'lineno': 50,
          'in_app': true,
          'filename': 'test.dart'
        },
        {
          'abs_path': 'test.dart',
          'function': 'bar',
          'lineno': 46,
          'in_app': true,
          'filename': 'test.dart'
        }
      ]);
    });

    test('encodes an asynchronous stack trace', () {
      expect(encodeStackTrace('''
#0      baz (file:///pathto/test.dart:50:3)
<asynchronous suspension>
#1      bar (file:///pathto/test.dart:46:9)
      '''), [
        {
          'abs_path': 'test.dart',
          'function': 'baz',
          'lineno': 50,
          'in_app': true,
          'filename': 'test.dart'
        },
        {
          'abs_path': '<asynchronous suspension>',
        },
        {
          'abs_path': 'test.dart',
          'function': 'bar',
          'lineno': 46,
          'in_app': true,
          'filename': 'test.dart'
        }
      ]);
    });
  });
}
