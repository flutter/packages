// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon (v0.3.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name
// @dart = 2.12
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';

class Everything {
  bool? aBool;
  int? anInt;
  double? aDouble;
  String? aString;
  Uint8List? aByteArray;
  Int32List? a4ByteArray;
  Int64List? a8ByteArray;
  Float64List? aFloatArray;
  List<Object?>? aList;
  Map<Object?, Object?>? aMap;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['aBool'] = aBool;
    pigeonMap['anInt'] = anInt;
    pigeonMap['aDouble'] = aDouble;
    pigeonMap['aString'] = aString;
    pigeonMap['aByteArray'] = aByteArray;
    pigeonMap['a4ByteArray'] = a4ByteArray;
    pigeonMap['a8ByteArray'] = a8ByteArray;
    pigeonMap['aFloatArray'] = aFloatArray;
    pigeonMap['aList'] = aList;
    pigeonMap['aMap'] = aMap;
    return pigeonMap;
  }

  static Everything decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return Everything()
      ..aBool = pigeonMap['aBool'] as bool?
      ..anInt = pigeonMap['anInt'] as int?
      ..aDouble = pigeonMap['aDouble'] as double?
      ..aString = pigeonMap['aString'] as String?
      ..aByteArray = pigeonMap['aByteArray'] as Uint8List?
      ..a4ByteArray = pigeonMap['a4ByteArray'] as Int32List?
      ..a8ByteArray = pigeonMap['a8ByteArray'] as Int64List?
      ..aFloatArray = pigeonMap['aFloatArray'] as Float64List?
      ..aList = pigeonMap['aList'] as List<Object?>?
      ..aMap = pigeonMap['aMap'] as Map<Object?, Object?>?;
  }
}

class _HostEverythingCodec extends StandardMessageCodec {
  const _HostEverythingCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is Everything) {
      buffer.putUint8(255);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 255:
        return Everything.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class HostEverything {
  /// Constructor for [HostEverything].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  HostEverything({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _HostEverythingCodec();

  Future<Everything> giveMeEverything() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostEverything.giveMeEverything', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return Everything.decode(replyMap['result']!);
    }
  }

  Future<Everything> echo(Everything arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.HostEverything.echo', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(encoded) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return Everything.decode(replyMap['result']!);
    }
  }
}

class _FlutterEverythingCodec extends StandardMessageCodec {
  const _FlutterEverythingCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is Everything) {
      buffer.putUint8(255);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 255:
        return Everything.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

abstract class FlutterEverything {
  static const MessageCodec<Object?> codec = _FlutterEverythingCodec();

  Everything giveMeEverything();
  Everything echo(Everything arg);
  static void setup(FlutterEverything? api) {
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterEverything.giveMeEverything', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          // ignore message
          final Everything output = api.giveMeEverything();
          return output.encode();
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterEverything.echo', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterEverything.echo was null. Expected Everything.');
          final Everything input = Everything.decode(message!);
          final Everything output = api.echo(input);
          return output.encode();
        });
      }
    }
  }
}
