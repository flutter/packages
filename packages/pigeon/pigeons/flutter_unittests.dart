// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class FlutterSearchRequest {
  String? query;
}

class FlutterSearchReply {
  String? result;
  String? error;
}

class FlutterSearchRequests {
  // ignore: always_specify_types, strict_raw_type
  List? requests;
}

class FlutterSearchReplies {
  // ignore: always_specify_types, strict_raw_type
  List? replies;
}

@HostApi()
abstract class Api {
  FlutterSearchReply search(FlutterSearchRequest request);
  FlutterSearchReplies doSearches(FlutterSearchRequests request);
  FlutterSearchRequests echo(FlutterSearchRequests requests);
  int anInt(int value);
}
