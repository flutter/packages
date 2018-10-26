// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:stack_trace/stack_trace.dart';

/// Sentry.io JSON encoding of a stack frame for the asynchronous suspension,
/// which is the gap between asynchronous calls.
const Map<String, dynamic> asynchronousGapFrameJson = const <String, dynamic>{
  'abs_path': '<asynchronous suspension>',
};

/// Encodes [stackTrace] as JSON in the Sentry.io format.
///
/// [stackTrace] must be [String] or [StackTrace].
List<Map<String, dynamic>> encodeStackTrace(dynamic stackTrace) {
  assert(stackTrace is String || stackTrace is StackTrace);
  final Chain chain = stackTrace is StackTrace
      ? new Chain.forTrace(stackTrace)
      : new Chain.parse(stackTrace);

  final List<Map<String, dynamic>> frames = <Map<String, dynamic>>[];
  for (int t = 0; t < chain.traces.length; t += 1) {
    frames.addAll(chain.traces[t].frames.map(encodeStackTraceFrame));
    if (t < chain.traces.length - 1) frames.add(asynchronousGapFrameJson);
  }
  return frames.reversed.toList();
}

Map<String, dynamic> encodeStackTraceFrame(Frame frame) {
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
