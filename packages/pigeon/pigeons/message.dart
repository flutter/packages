// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is an example pigeon file that is used in compilation, unit, mock
// handler, and e2e tests.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    javaOptions: JavaOptions(
      className: 'MessagePigeon',
      package: 'dev.flutter.aaclarke.pigeon',
    ),
    objcOptions: ObjcOptions(prefix: 'AC'),
  ),
)
/// This comment is to test enum documentation comments.
///
/// This comment also tests multiple line comments.
///
///////////////////////////
/// This comment also tests comments that start with '/'
///////////////////////////
enum MessageRequestState { pending, success, failure }

/// This comment is to test class documentation comments.
///
/// This comment also tests multiple line comments.
class MessageSearchRequest {
  /// This comment is to test field documentation comments.
  String? query;

  /// This comment is to test field documentation comments.
  int? anInt;

  /// This comment is to test field documentation comments.
  bool? aBool;
}

/// This comment is to test class documentation comments.
class MessageSearchReply {
  /// This comment is to test field documentation comments.
  ///
  /// This comment also tests multiple line comments.
  String? result;

  /// This comment is to test field documentation comments.
  String? error;

  /// This comment is to test field documentation comments.
  MessageRequestState? state;
}

@HostApi(dartHostTestHandler: 'TestHostApi')
/// This comment is to test api documentation comments.
///
/// This comment also tests multiple line comments.
abstract class MessageApi {
  /// This comment is to test documentation comments.
  ///
  /// This comment also tests multiple line comments.
  void initialize();

  /// This comment is to test method documentation comments.
  MessageSearchReply search(MessageSearchRequest request);
}

/// This comment is to test class documentation comments.
class MessageNested {
  /// This comment is to test field documentation comments.
  MessageSearchRequest? request;
}

@HostApi(dartHostTestHandler: 'TestNestedApi')
/// This comment is to test api documentation comments.
abstract class MessageNestedApi {
  /// This comment is to test method documentation comments.
  ///
  /// This comment also tests multiple line comments.
  MessageSearchReply search(MessageNested nested);
}

@FlutterApi()
/// This comment is to test api documentation comments.
abstract class MessageFlutterSearchApi {
  /// This comment is to test method documentation comments.
  MessageSearchReply search(MessageSearchRequest request);
}
