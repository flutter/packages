// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'core_tests.dart';

/// An API that can be implemented for minimal, compile-only tests.
//
// This is also here to test that multiple host APIs can be generated
// successfully in all languages (e.g., in Java where it requires having a
// wrapper class).
@HostApi()
abstract class HostTrivialApi {
  void noop();
}

/// A simple API implemented in some unit tests.
//
// This is separate from HostIntegrationCoreApi to avoid having to update a
// lot of unit tests every time we add something to the integration test API.
// TODO(stuartmorgan): Restructure the unit tests to reduce the number of
// different APIs we define.
@HostApi()
abstract class HostSmallApi {
  @async
  @ObjCSelector('echoString:')
  String echo(String aString);

  @async
  void voidVoid();
}

/// A simple API called in some unit tests.
//
// This is separate from FlutterIntegrationCoreApi to allow for incrementally
// moving from the previous fragmented unit test structure to something more
// unified.
// TODO(stuartmorgan): Restructure the unit tests to reduce the number of
// different APIs we define.
@FlutterApi()
abstract class FlutterSmallApi {
  @ObjCSelector('echoWrappedList:')
  @SwiftFunction('echo(_:)')
  TestMessage echoWrappedList(TestMessage msg);

  @ObjCSelector('echoString:')
  @SwiftFunction('echo(string:)')
  String echoString(String aString);
}

/// A data class containing a List, used in unit tests.
// TODO(stuartmorgan): Evaluate whether these unit tests are still useful; see
// TODOs above about restructuring.
class TestMessage {
  // ignore: always_specify_types, strict_raw_type
  List? testList;
}
