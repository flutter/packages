// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'message.dart';

class Mock implements TestHostApi {
  bool didCall = false;
  @override
  SearchReply search(SearchRequest arg) {
    didCall = true;
    return SearchReply()..result = arg.query;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('description', () async {
    final Api api = Api();
    final Mock mock = Mock();
    TestHostApi.setup(mock);
    final SearchReply reply = await api.search(SearchRequest()..query = 'foo');
    expect(mock.didCall, true);
    expect(reply.result, 'foo');
  });
}
