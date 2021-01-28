// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'message.dart';
import 'test.dart';

class Mock implements TestHostApi {
  bool didCall = false;
  @override
  SearchReply search(SearchRequest arg) {
    didCall = true;
    return SearchReply()..result = arg.query;
  }
}

class MockNested implements TestNestedApi {
  bool didCall = false;
  @override
  SearchReply search(Nested arg) {
    didCall = true;
    if (arg.request == null) {
      return SearchReply();
    } else {
      return SearchReply()..result = arg.request.query;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simple', () async {
    final NestedApi api = NestedApi();
    final MockNested mock = MockNested();
    TestNestedApi.setup(mock);
    final SearchReply reply = await api.search(Nested()..request = null);
    expect(mock.didCall, true);
    expect(reply.result, null);
  });

  test('nested', () async {
    final Api api = Api();
    final Mock mock = Mock();
    TestHostApi.setup(mock);
    final SearchReply reply = await api.search(SearchRequest()..query = 'foo');
    expect(mock.didCall, true);
    expect(reply.result, 'foo');
  });
}
