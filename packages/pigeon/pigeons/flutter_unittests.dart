// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class SearchRequest {
  String? query;
}

class SearchReply {
  String? result;
  String? error;
}

class SearchRequests {
  // ignore: always_specify_types
  List? requests;
}

class SearchReplies {
  // ignore: always_specify_types
  List? replies;
}

@HostApi()
abstract class Api {
  SearchReply search(SearchRequest request);
  SearchReplies doSearches(SearchRequests request);
  SearchRequests echo(SearchRequests requests);
}
