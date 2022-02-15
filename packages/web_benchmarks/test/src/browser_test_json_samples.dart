// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show jsonDecode;

// JSON Event samples taken from running an instrumented version of the
// integration tests of this package that dumped all the data as captured.

/// To test isBeginFrame.
final Map<String, dynamic> beginMainFrameJson = jsonDecode('''
{
    "args": {
        "frameTime": 2338687248768
    },
    "cat": "blink",
    "dur": 6836,
    "name": "WebFrameWidgetImpl::BeginMainFrame",
    "ph": "X",
    "pid": 1367081,
    "tdur": 393,
    "tid": 1,
    "ts": 2338687258440,
    "tts": 375499
}
''');

/// To test isUpdateAllLifecyclePhases.
final Map<String, dynamic> updateLifecycleJson = jsonDecode('''
{
    "args": {},
    "cat": "blink",
    "dur": 103,
    "name": "WebFrameWidgetImpl::updateAllLifecyclePhases",
    "ph": "X",
    "pid": 1367081,
    "tdur": 102,
    "tid": 1,
    "ts": 2338687265284,
    "tts": 375900
}
''');

/// To test isBeginMeasuredFrame.
final Map<String, dynamic> beginMeasuredFrameJson = jsonDecode('''
{
    "args": {},
    "cat": "blink.user_timing",
    "id": "0xea2a8b45",
    "name": "measured_frame",
    "ph": "b",
    "pid": 1367081,
    "scope": "blink.user_timing",
    "tid": 1,
    "ts": 2338687265932
}
''');

/// To test isEndMeasuredFrame.
final Map<String, dynamic> endMeasuredFrameJson = jsonDecode('''
{
    "args": {},
    "cat": "blink.user_timing",
    "id": "0xea2a8b45",
    "name": "measured_frame",
    "ph": "e",
    "pid": 1367081,
    "scope": "blink.user_timing",
    "tid": 1,
    "ts": 2338687440485
}
''');

final Map<String, dynamic> unrelatedPhXJson = jsonDecode('''
{
    "args": {},
    "cat": "blink,rail",
    "dur": 2,
    "name": "PageAnimator::serviceScriptedAnimations",
    "ph": "X",
    "pid": 1367081,
    "tdur": 2,
    "tid": 1,
    "ts": 2338691143317,
    "tts": 1685405
}
''');

final Map<String, dynamic> anotherUnrelatedJson = jsonDecode('''
{
    "args": {
        "sort_index": -1
    },
    "cat": "__metadata",
    "name": "thread_sort_index",
    "ph": "M",
    "pid": 1367081,
    "tid": 1,
    "ts": 2338692906482
}
''');
