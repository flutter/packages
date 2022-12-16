// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// A class containing all supported types.
class AllTypes {
  bool? aBool;
  int? anInt;
  double? aDouble;
  String? aString;
  Uint8List? aByteArray;
  Int32List? a4ByteArray;
  Int64List? a8ByteArray;
  Float64List? aFloatArray;
  // ignore: always_specify_types, strict_raw_type
  List? aList;
  // ignore: always_specify_types, strict_raw_type
  Map? aMap;
  List<List<bool?>?>? nestedList;
  Map<String?, String?>? mapWithAnnotations;
  Map<String?, Object?>? mapWithObject;
}

// A class for testing nested object handling.
class AllTypesWrapper {
  AllTypesWrapper(this.values);
  AllTypes values;
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
@HostApi()
abstract class HostIntegrationCoreApi {
  // ========== Syncronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns an error, to test error handling.
  void throwError();

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('extractNestedStringFrom:')
  String? extractNestedString(AllTypesWrapper wrapper);

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  @ObjCSelector('createNestedObjectWithString:')
  AllTypesWrapper createNestedString(String string);

  /// Returns passed in arguments of multiple types.
  @ObjCSelector('sendMultipleTypesABool:anInt:aString:')
  AllTypes sendMultipleTypes(bool aBool, int anInt, String aString);

  /// Returns passed in int.
  @ObjCSelector('echoInt:')
  int echoInt(int anInt);

  /// Returns the passed in boolean asynchronously.
  @ObjCSelector('echoBool:')
  bool echoBool(bool aBool);

  // ========== Asyncronous method tests ==========

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  @async
  void noopAsync();

  /// Returns the passed string asynchronously.
  @async
  @ObjCSelector('echoAsyncString:')
  String echoAsyncString(String aString);

  // ========== Flutter API test wrappers ==========

  @async
  void callFlutterNoop();

  @async
  @ObjCSelector('callFlutterEchoString:')
  String callFlutterEchoString(String aString);

  // TODO(stuartmorgan): Add callFlutterEchoString and the associated test once
  // either https://github.com/flutter/flutter/issues/116117 is fixed, or the
  // problematic type is moved out of AllTypes and into its own test, since
  // the type mismatch breaks the second `encode` round.
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
@FlutterApi()
abstract class FlutterIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns the passed string, to test serialization and deserialization.
  @ObjCSelector('echoString:')
  String echoString(String aString);
}

/// An API that can be implemented for minimal, compile-only tests.
@HostApi()
abstract class HostTrivialApi {
  void noop();
}
