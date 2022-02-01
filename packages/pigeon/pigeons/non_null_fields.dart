// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

class SearchRequest {
  SearchRequest({required this.query});
  String query;
}

class SearchReply {
  SearchReply(this.result, this.error, this.indices);
  String result;
  String error;
  List<int?> indices;
}

@HostApi()
abstract class NonNullHostApi {
  SearchReply search(SearchRequest nested);
}

@FlutterApi()
abstract class NonNullFlutterApi {
  SearchReply search(SearchRequest request);
}
