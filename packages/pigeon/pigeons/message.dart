// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  javaOptions: JavaOptions(
    className: 'MessagePigeon',
    package: 'dev.flutter.aaclarke.pigeon',
  ),
  objcOptions: ObjcOptions(
    prefix: 'AC',
  ),
))
enum MessageRequestState {
  pending,
  success,
  failure,
}

class MessageSearchRequest {
  String? query;
  int? anInt;
  bool? aBool;
}

class MessageSearchReply {
  String? result;
  String? error;
  MessageRequestState? state;
}

@HostApi(dartHostTestHandler: 'TestHostApi')
abstract class MessageApi {
  void initialize();
  MessageSearchReply search(MessageSearchRequest request);
}

class MessageNested {
  MessageSearchRequest? request;
}

@HostApi(dartHostTestHandler: 'TestNestedApi')
abstract class MessageNestedApi {
  MessageSearchReply search(MessageNested nested);
}

@FlutterApi()
abstract class MessageFlutterSearchApi {
  MessageSearchReply search(MessageSearchRequest request);
}
