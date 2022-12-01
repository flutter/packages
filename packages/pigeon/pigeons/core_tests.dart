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

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
@HostApi()
abstract class HostIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  @ObjCSelector('echoAllTypes:')
  AllTypes echoAllTypes(AllTypes everything);

  // TODO(stuartmorgan): Add wrapper methods to trigger calls back into
  // FlutterIntegrationCore methods, to allow Dart-driven integration testing
  // of host->Dart calls. Each wrapper would be implemented by calling the
  // corresponding FlutterIntegrationCore method, passing arguments and return
  // values along unchanged. Since these will need to be async, we also need
  // async host API tests here, so that failures in Dart->host async calling
  // don't only show up here.
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
}

/// An API that can be implemented for minimal, compile-only tests.
@HostApi()
abstract class HostTrivialApi {
  void noop();
}
