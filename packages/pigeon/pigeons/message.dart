// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

class SearchRequest {
  String query;
  int anInt;
  bool aBool;
}

class SearchReply {
  String result;
  String error;
}

@HostApi(dartHostTestHandler: 'TestHostApi')
abstract class Api {
  SearchReply search(SearchRequest request);
}

class Nested {
  SearchRequest request;
}

@HostApi()
abstract class NestedApi {
  SearchReply search(Nested nested);
}

void configurePigeon(PigeonOptions options) {
  options.objcOptions.prefix = 'AC';
  options.javaOptions.package = 'dev.flutter.aaclarke.pigeon';
}

@FlutterApi()
abstract class FlutterSearchApi {
  SearchReply search(SearchRequest request);
}
