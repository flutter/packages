// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:stack_trace/stack_trace.dart';

Map<String, dynamic> stackTraceFrameToJsonFrame(Frame frame) {
  final Map<String, dynamic> json = <String, dynamic>{
    'abs_path': _absolutePathForCrashReport(frame),
    'function': frame.member,
    'lineno': frame.line,
    'in_app': !frame.isCore,
  };

  if (frame.uri.pathSegments.isNotEmpty)
    json['filename'] = frame.uri.pathSegments.last;

  return json;
}

/// A stack frame's code path may be one of "file:", "dart:" and "package:".
///
/// Absolute file paths may contain personally identifiable information, and
/// therefore are stripped to only send the base file name. For example,
/// "/foo/bar/baz.dart" is reported as "baz.dart".
///
/// "dart:" and "package:" imports are always relative and are OK to send in
/// full.
String _absolutePathForCrashReport(Frame frame) {
  if (frame.uri.scheme != 'dart' && frame.uri.scheme != 'package')
    return frame.uri.pathSegments.last;

  return '${frame.uri}';
}
