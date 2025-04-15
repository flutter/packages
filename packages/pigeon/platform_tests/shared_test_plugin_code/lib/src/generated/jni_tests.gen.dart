// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';
import 'package:jni/jni.dart';
import './jni_tests.gen.jni.dart' as bridge;

Object? convertObject(JObject? object) {
  if (object == null) {
    return null;
  }
  if (object.isA<JLong>(JLong.type)) {
    return (object.as(JLong.type)).intValue();
  }
  if (object.isA<JDouble>(JDouble.type)) {
    return (object.as(JDouble.type)).doubleValue();
  }
  if (object.isA<JString>(JString.type)) {
    return (object.as(JString.type)).toDartString();
  }
  if (object.isA<JBoolean>(JBoolean.type)) {
    return (object.as(JBoolean.type)).booleanValue();
  }
  if (object.isA<JList<JObject>>(JList.type<JObject>(JObject.type))) {
    final JList<JObject> list = (object.as(JList.type<JObject>(JObject.type)));
    final List<Object?> res = <Object?>[];
    for (int i = 0; i < list.length; i++) {
      res.add(convertObject(list[i]));
    }
    return res;
  }
  if (object.isA<JMap<JObject, JObject>>(
      JMap.type<JObject, JObject>(JObject.type, JObject.type))) {
    final JMap<JObject, JObject> map =
        (object.as(JMap.type<JObject, JObject>(JObject.type, JObject.type)));
    final Map<Object?, Object?> res = <Object, Object>{};
    for (final MapEntry<JObject?, JObject?> entry in map.entries) {
      res[convertObject(entry.key)] = convertObject(entry.value);
    }
    return res;
  }
  return object;
}

class SomeTypes {
  SomeTypes({
    required this.aString,
    required this.anInt,
    required this.aDouble,
    required this.aBool,
  });

  String aString;

  int anInt;

  double aDouble;

  bool aBool;

  List<Object?> _toList() {
    return <Object?>[
      aString,
      anInt,
      aDouble,
      aBool,
    ];
  }

  bridge.SomeTypes toJni() {
    return bridge.SomeTypes(
      JString.fromString(aString),
      anInt,
      aDouble,
      aBool,
    );
  }

  Object encode() {
    return _toList();
  }

  static SomeTypes? fromJni(bridge.SomeTypes? jniClass) {
    return jniClass == null
        ? null
        : SomeTypes(
            aString: jniClass.getAString().toDartString(releaseOriginal: true),
            anInt: jniClass.getAnInt(),
            aDouble: jniClass.getADouble(),
            aBool: jniClass.getABool(),
          );
  }

  static SomeTypes decode(Object result) {
    result as List<Object?>;
    return SomeTypes(
      aString: result[0]! as String,
      anInt: result[1]! as int,
      aDouble: result[2]! as double,
      aBool: result[3]! as bool,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! SomeTypes || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return aString == other.aString &&
        anInt == other.anInt &&
        aDouble == other.aDouble &&
        aBool == other.aBool;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(_toList());
}

class SomeNullableTypes {
  SomeNullableTypes({
    this.aString,
    this.anInt,
    this.aDouble,
    this.aBool,
  });

  String? aString;

  int? anInt;

  double? aDouble;

  bool? aBool;

  List<Object?> _toList() {
    return <Object?>[
      aString,
      anInt,
      aDouble,
      aBool,
    ];
  }

  bridge.SomeNullableTypes toJni() {
    return bridge.SomeNullableTypes(
      aString != null ? JString.fromString(aString!) : null,
      anInt != null ? JLong(anInt!) : null,
      aDouble != null ? JDouble(aDouble!) : null,
      aBool != null ? JBoolean(aBool!) : null,
    );
  }

  Object encode() {
    return _toList();
  }

  static SomeNullableTypes? fromJni(bridge.SomeNullableTypes? jniClass) {
    return jniClass == null
        ? null
        : SomeNullableTypes(
            aString: jniClass.getAString()?.toDartString(releaseOriginal: true),
            anInt: jniClass.getAnInt()?.intValue(releaseOriginal: true),
            aDouble: jniClass.getADouble()?.doubleValue(releaseOriginal: true),
            aBool: jniClass.getABool()?.booleanValue(releaseOriginal: true),
          );
  }

  static SomeNullableTypes decode(Object result) {
    result as List<Object?>;
    return SomeNullableTypes(
      aString: result[0] as String?,
      anInt: result[1] as int?,
      aDouble: result[2] as double?,
      aBool: result[3] as bool?,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! SomeNullableTypes || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return aString == other.aString &&
        anInt == other.anInt &&
        aDouble == other.aDouble &&
        aBool == other.aBool;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(_toList());
}

const String defaultInstanceName =
    'PigeonDefaultClassName32uh4ui3lh445uh4h3l2l455g4y34u';

class JniMessageApi {
  JniMessageApi._withRegistrar(bridge.JniMessageApiRegistrar api) : _api = api;

  /// Returns instance of JniMessageApi with specified [channelName] if one has been registered.
  static JniMessageApi? getInstance(
      {String channelName = defaultInstanceName}) {
    final bridge.JniMessageApiRegistrar? link = bridge.JniMessageApiRegistrar()
        .getInstance(JString.fromString(channelName));
    if (link == null) {
      String nameString = 'named $channelName';
      if (channelName == defaultInstanceName) {
        nameString = 'with no name';
      }
      final String error = 'No instance $nameString has been registered.';
      throw ArgumentError(error);
    }
    final JniMessageApi res = JniMessageApi._withRegistrar(link);
    return res;
  }

  late final bridge.JniMessageApiRegistrar _api;

  void doNothing() {
    return _api.doNothing();
  }

  String echoString(String request) {
    final JString res = _api.echoString(JString.fromString(request));
    final String dartTypeRes = res.toDartString(releaseOriginal: true);
    return dartTypeRes;
  }

  int echoInt(int request) {
    return _api.echoInt(request);
  }

  double echoDouble(double request) {
    return _api.echoDouble(request);
  }

  bool echoBool(bool request) {
    return _api.echoBool(request);
  }

  SomeTypes sendSomeTypes(SomeTypes someTypes) {
    final bridge.SomeTypes res = _api.sendSomeTypes(someTypes.toJni());
    final SomeTypes dartTypeRes = SomeTypes.fromJni(res)!;
    return dartTypeRes;
  }
}

class JniMessageApiNullable {
  JniMessageApiNullable._withRegistrar(
      bridge.JniMessageApiNullableRegistrar api)
      : _api = api;

  /// Returns instance of JniMessageApiNullable with specified [channelName] if one has been registered.
  static JniMessageApiNullable? getInstance(
      {String channelName = defaultInstanceName}) {
    final bridge.JniMessageApiNullableRegistrar? link =
        bridge.JniMessageApiNullableRegistrar()
            .getInstance(JString.fromString(channelName));
    if (link == null) {
      String nameString = 'named $channelName';
      if (channelName == defaultInstanceName) {
        nameString = 'with no name';
      }
      final String error = 'No instance $nameString has been registered.';
      throw ArgumentError(error);
    }
    final JniMessageApiNullable res =
        JniMessageApiNullable._withRegistrar(link);
    return res;
  }

  late final bridge.JniMessageApiNullableRegistrar _api;

  String? echoString(String? request) {
    final JString? res =
        _api.echoString(request != null ? JString.fromString(request) : null);
    final String? dartTypeRes = res?.toDartString(releaseOriginal: true);
    return dartTypeRes;
  }

  int? echoInt(int? request) {
    final JLong? res = _api.echoInt(request != null ? JLong(request) : null);
    final int? dartTypeRes = res?.intValue(releaseOriginal: true);
    return dartTypeRes;
  }

  double? echoDouble(double? request) {
    final JDouble? res =
        _api.echoDouble(request != null ? JDouble(request) : null);
    final double? dartTypeRes = res?.doubleValue(releaseOriginal: true);
    return dartTypeRes;
  }

  bool? echoBool(bool? request) {
    final JBoolean? res =
        _api.echoBool(request != null ? JBoolean(request) : null);
    final bool? dartTypeRes = res?.booleanValue(releaseOriginal: true);
    return dartTypeRes;
  }

  SomeNullableTypes? sendSomeNullableTypes(SomeNullableTypes? someTypes) {
    final bridge.SomeNullableTypes? res =
        _api.sendSomeNullableTypes(someTypes?.toJni());
    final SomeNullableTypes? dartTypeRes = SomeNullableTypes.fromJni(res);
    return dartTypeRes;
  }
}

class JniMessageApiAsync {
  JniMessageApiAsync._withRegistrar(bridge.JniMessageApiAsyncRegistrar api)
      : _api = api;

  /// Returns instance of JniMessageApiAsync with specified [channelName] if one has been registered.
  static JniMessageApiAsync? getInstance(
      {String channelName = defaultInstanceName}) {
    final bridge.JniMessageApiAsyncRegistrar? link =
        bridge.JniMessageApiAsyncRegistrar()
            .getInstance(JString.fromString(channelName));
    if (link == null) {
      String nameString = 'named $channelName';
      if (channelName == defaultInstanceName) {
        nameString = 'with no name';
      }
      final String error = 'No instance $nameString has been registered.';
      throw ArgumentError(error);
    }
    final JniMessageApiAsync res = JniMessageApiAsync._withRegistrar(link);
    return res;
  }

  late final bridge.JniMessageApiAsyncRegistrar _api;

  Future<void> doNothing() async {
    await _api.doNothing();
  }

  Future<String> echoString(String request) async {
    final JString res = await _api.echoString(JString.fromString(request));
    final String dartTypeRes = res.toDartString(releaseOriginal: true);
    return dartTypeRes;
  }

  Future<int> echoInt(int request) async {
    final JLong res = await _api.echoInt(request);
    final int dartTypeRes = res.intValue(releaseOriginal: true);
    return dartTypeRes;
  }

  Future<double> echoDouble(double request) async {
    final JDouble res = await _api.echoDouble(request);
    final double dartTypeRes = res.doubleValue(releaseOriginal: true);
    return dartTypeRes;
  }

  Future<bool> echoBool(bool request) async {
    final JBoolean res = await _api.echoBool(request);
    final bool dartTypeRes = res.booleanValue(releaseOriginal: true);
    return dartTypeRes;
  }

  Future<SomeTypes> sendSomeTypes(SomeTypes someTypes) async {
    final bridge.SomeTypes res = await _api.sendSomeTypes(someTypes.toJni());
    final SomeTypes dartTypeRes = SomeTypes.fromJni(res)!;
    return dartTypeRes;
  }
}
