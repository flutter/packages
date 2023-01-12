// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon (v5.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import
import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

enum AnEnum {
  one,
  two,
  three,
}

class AllTypes {
  AllTypes({
    required this.aBool,
    required this.anInt,
    required this.aDouble,
    required this.aString,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    required this.aList,
    required this.aMap,
    required this.anEnum,
  });

  bool aBool;

  int anInt;

  double aDouble;

  String aString;

  Uint8List aByteArray;

  Int32List a4ByteArray;

  Int64List a8ByteArray;

  Float64List aFloatArray;

  List<Object?> aList;

  Map<Object?, Object?> aMap;

  AnEnum anEnum;

  Object encode() {
    return <Object?>[
      aBool,
      anInt,
      aDouble,
      aString,
      aByteArray,
      a4ByteArray,
      a8ByteArray,
      aFloatArray,
      aList,
      aMap,
      anEnum.index,
    ];
  }

  static AllTypes decode(Object result) {
    result as List<Object?>;
    return AllTypes(
      aBool: result[0]! as bool,
      anInt: result[1]! as int,
      aDouble: result[2]! as double,
      aString: result[3]! as String,
      aByteArray: result[4]! as Uint8List,
      a4ByteArray: result[5]! as Int32List,
      a8ByteArray: result[6]! as Int64List,
      aFloatArray: result[7]! as Float64List,
      aList: result[8]! as List<Object?>,
      aMap: result[9]! as Map<Object?, Object?>,
      anEnum: AnEnum.values[result[10]! as int],
    );
  }
}

class AllNullableTypes {
  AllNullableTypes({
    this.aNullableBool,
    this.aNullableInt,
    this.aNullableDouble,
    this.aNullableString,
    this.aNullableByteArray,
    this.aNullable4ByteArray,
    this.aNullable8ByteArray,
    this.aNullableFloatArray,
    this.aNullableList,
    this.aNullableMap,
    this.nullableNestedList,
    this.nullableMapWithAnnotations,
    this.nullableMapWithObject,
    this.aNullableEnum,
  });

  bool? aNullableBool;

  int? aNullableInt;

  double? aNullableDouble;

  String? aNullableString;

  Uint8List? aNullableByteArray;

  Int32List? aNullable4ByteArray;

  Int64List? aNullable8ByteArray;

  Float64List? aNullableFloatArray;

  List<Object?>? aNullableList;

  Map<Object?, Object?>? aNullableMap;

  List<List<bool?>?>? nullableNestedList;

  Map<String?, String?>? nullableMapWithAnnotations;

  Map<String?, Object?>? nullableMapWithObject;

  AnEnum? aNullableEnum;

  Object encode() {
    return <Object?>[
      aNullableBool,
      aNullableInt,
      aNullableDouble,
      aNullableString,
      aNullableByteArray,
      aNullable4ByteArray,
      aNullable8ByteArray,
      aNullableFloatArray,
      aNullableList,
      aNullableMap,
      nullableNestedList,
      nullableMapWithAnnotations,
      nullableMapWithObject,
      aNullableEnum?.index,
    ];
  }

  static AllNullableTypes decode(Object result) {
    result as List<Object?>;
    return AllNullableTypes(
      aNullableBool: result[0] as bool?,
      aNullableInt: result[1] as int?,
      aNullableDouble: result[2] as double?,
      aNullableString: result[3] as String?,
      aNullableByteArray: result[4] as Uint8List?,
      aNullable4ByteArray: result[5] as Int32List?,
      aNullable8ByteArray: result[6] as Int64List?,
      aNullableFloatArray: result[7] as Float64List?,
      aNullableList: result[8] as List<Object?>?,
      aNullableMap: result[9] as Map<Object?, Object?>?,
      nullableNestedList: (result[10] as List<Object?>?)?.cast<List<bool?>?>(),
      nullableMapWithAnnotations:
          (result[11] as Map<Object?, Object?>?)?.cast<String?, String?>(),
      nullableMapWithObject:
          (result[12] as Map<Object?, Object?>?)?.cast<String?, Object?>(),
      aNullableEnum:
          result[13] != null ? AnEnum.values[result[13]! as int] : null,
    );
  }
}

class AllNullableTypesWrapper {
  AllNullableTypesWrapper({
    required this.values,
  });

  AllNullableTypes values;

  Object encode() {
    return <Object?>[
      values.encode(),
    ];
  }

  static AllNullableTypesWrapper decode(Object result) {
    result as List<Object?>;
    return AllNullableTypesWrapper(
      values: AllNullableTypes.decode(result[0]! as List<Object?>),
    );
  }
}

class _HostIntegrationCoreApiCodec extends StandardMessageCodec {
  const _HostIntegrationCoreApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is AllNullableTypes) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is AllNullableTypesWrapper) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is AllTypes) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return AllNullableTypes.decode(readValue(buffer)!);

      case 129:
        return AllNullableTypesWrapper.decode(readValue(buffer)!);

      case 130:
        return AllTypes.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
class HostIntegrationCoreApi {
  /// Constructor for [HostIntegrationCoreApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  HostIntegrationCoreApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _HostIntegrationCoreApiCodec();

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  Future<void> noop() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.noop', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  /// Returns the passed object, to test serialization and deserialization.
  Future<AllTypes> echoAllTypes(AllTypes arg_everything) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoAllTypes', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_everything]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as AllTypes?)!;
    }
  }

  /// Returns the passed object, to test serialization and deserialization.
  Future<AllNullableTypes?> echoAllNullableTypes(
      AllNullableTypes? arg_everything) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoAllNullableTypes', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_everything]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as AllNullableTypes?);
    }
  }

  /// Returns an error, to test error handling.
  Future<void> throwError() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.throwError', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  /// Returns passed in int.
  Future<int> echoInt(int arg_anInt) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoInt', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_anInt]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as int?)!;
    }
  }

  /// Returns passed in double.
  Future<double> echoDouble(double arg_aDouble) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoDouble', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aDouble]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as double?)!;
    }
  }

  /// Returns the passed in boolean.
  Future<bool> echoBool(bool arg_aBool) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoBool', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aBool]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as bool?)!;
    }
  }

  /// Returns the passed in string.
  Future<String> echoString(String arg_aString) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoString', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aString]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as String?)!;
    }
  }

  /// Returns the passed in Uint8List.
  Future<Uint8List> echoUint8List(Uint8List arg_aUint8List) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoUint8List', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aUint8List]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as Uint8List?)!;
    }
  }

  /// Returns the passed in generic Object.
  Future<Object> echoObject(Object arg_anObject) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoObject', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_anObject]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return replyList[0]!;
    }
  }

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  Future<String?> extractNestedNullableString(
      AllNullableTypesWrapper arg_wrapper) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.extractNestedNullableString',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_wrapper]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as String?);
    }
  }

  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  Future<AllNullableTypesWrapper> createNestedNullableString(
      String? arg_nullableString) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.createNestedNullableString',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_nullableString]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as AllNullableTypesWrapper?)!;
    }
  }

  /// Returns passed in arguments of multiple types.
  Future<AllNullableTypes> sendMultipleNullableTypes(bool? arg_aNullableBool,
      int? arg_aNullableInt, String? arg_aNullableString) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.sendMultipleNullableTypes',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(
            <Object?>[arg_aNullableBool, arg_aNullableInt, arg_aNullableString])
        as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as AllNullableTypes?)!;
    }
  }

  /// Returns passed in int.
  Future<int?> echoNullableInt(int? arg_aNullableInt) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableInt', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aNullableInt]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as int?);
    }
  }

  /// Returns passed in double.
  Future<double?> echoNullableDouble(double? arg_aNullableDouble) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableDouble', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aNullableDouble]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as double?);
    }
  }

  /// Returns the passed in boolean.
  Future<bool?> echoNullableBool(bool? arg_aNullableBool) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableBool', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aNullableBool]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as bool?);
    }
  }

  /// Returns the passed in string.
  Future<String?> echoNullableString(String? arg_aNullableString) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableString', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aNullableString]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as String?);
    }
  }

  /// Returns the passed in Uint8List.
  Future<Uint8List?> echoNullableUint8List(
      Uint8List? arg_aNullableUint8List) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableUint8List',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aNullableUint8List]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as Uint8List?);
    }
  }

  /// Returns the passed in generic Object.
  Future<Object?> echoNullableObject(Object? arg_aNullableObject) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableObject', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aNullableObject]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return replyList[0];
    }
  }

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  Future<void> noopAsync() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.noopAsync', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  /// Returns the passed string asynchronously.
  Future<String> echoAsyncString(String arg_aString) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.echoAsyncString', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aString]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as String?)!;
    }
  }

  Future<void> callFlutterNoop() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.callFlutterNoop', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  Future<String> callFlutterEchoString(String arg_aString) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostIntegrationCoreApi.callFlutterEchoString',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_aString]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as String?)!;
    }
  }
}

class _FlutterIntegrationCoreApiCodec extends StandardMessageCodec {
  const _FlutterIntegrationCoreApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is AllNullableTypes) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is AllTypes) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return AllNullableTypes.decode(readValue(buffer)!);

      case 129:
        return AllTypes.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
abstract class FlutterIntegrationCoreApi {
  static const MessageCodec<Object?> codec = _FlutterIntegrationCoreApiCodec();

  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  void noop();

  /// Returns the passed object, to test serialization and deserialization.
  AllTypes echoAllTypes(AllTypes everything);

  /// Returns the passed object, to test serialization and deserialization.
  AllNullableTypes echoAllNullableTypes(AllNullableTypes everything);

  /// Returns the passed string, to test serialization and deserialization.
  String echoString(String aString);

  static void setup(FlutterIntegrationCoreApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterIntegrationCoreApi.noop', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          // ignore message
          api.noop();
          return;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllTypes', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllTypes was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final AllTypes? arg_everything = (args[0] as AllTypes?);
          assert(arg_everything != null,
              'Argument for dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllTypes was null, expected non-null AllTypes.');
          final AllTypes output = api.echoAllTypes(arg_everything!);
          return output;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllNullableTypes',
          codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllNullableTypes was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final AllNullableTypes? arg_everything =
              (args[0] as AllNullableTypes?);
          assert(arg_everything != null,
              'Argument for dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllNullableTypes was null, expected non-null AllNullableTypes.');
          final AllNullableTypes output =
              api.echoAllNullableTypes(arg_everything!);
          return output;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterIntegrationCoreApi.echoString', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterIntegrationCoreApi.echoString was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_aString = (args[0] as String?);
          assert(arg_aString != null,
              'Argument for dev.flutter.pigeon.FlutterIntegrationCoreApi.echoString was null, expected non-null String.');
          final String output = api.echoString(arg_aString!);
          return output;
        });
      }
    }
  }
}

/// An API that can be implemented for minimal, compile-only tests.
class HostTrivialApi {
  /// Constructor for [HostTrivialApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  HostTrivialApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = StandardMessageCodec();

  Future<void> noop() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostTrivialApi.noop', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }
}
