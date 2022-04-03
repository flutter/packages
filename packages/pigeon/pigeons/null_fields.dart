// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

class NullFieldsSearchRequest {
  NullFieldsSearchRequest(this.query);
  String? query;
}

enum NullFieldsSearchReplyType {
  success,
  failure,
}

class NullFieldsSearchReply {
  NullFieldsSearchReply(
    this.result,
    this.error,
    this.indices,
    this.request,
    this.type,
  );
  String? result;
  String? error;
  List<int?>? indices;
  NullFieldsSearchRequest? request;
  NullFieldsSearchReplyType? type;
}

@HostApi()
abstract class NullFieldsHostApi {
  NullFieldsSearchReply search(NullFieldsSearchRequest nested);
}

@FlutterApi()
abstract class NullFieldsFlutterApi {
  NullFieldsSearchReply search(NullFieldsSearchRequest request);
}
