// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  javaOptions: JavaOptions(
    className: 'Pigeon',
    package: 'dev.flutter.aaclarke.pigeon',
  ),
  objcOptions: ObjcOptions(
    prefix: 'AC',
  ),
))
enum RequestState {
  pending,
  success,
  failure,
}

class SearchRequest {
  String? query;
  int? anInt;
  bool? aBool;
}

class SearchReply {
  String? result;
  String? error;
  RequestState? state;
}

@HostApi(dartHostTestHandler: 'TestHostApi')
abstract class Api {
  void initialize();
  SearchReply search(SearchRequest request);
}

class Nested {
  SearchRequest? request;
}

@HostApi(dartHostTestHandler: 'TestNestedApi')
abstract class NestedApi {
  SearchReply search(Nested nested);
}

@FlutterApi()
abstract class FlutterSearchApi {
  SearchReply search(SearchRequest request);
}
