// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.example.alternate_language_test_plugin.CoreTests.AllClassesWrapper;
import com.example.alternate_language_test_plugin.CoreTests.AllNullableTypes;
import com.example.alternate_language_test_plugin.CoreTests.AllNullableTypesWithoutRecursion;
import com.example.alternate_language_test_plugin.CoreTests.AllTypes;
import com.example.alternate_language_test_plugin.CoreTests.AnEnum;
import com.example.alternate_language_test_plugin.CoreTests.AnotherEnum;
import com.example.alternate_language_test_plugin.CoreTests.FlutterIntegrationCoreApi;
import com.example.alternate_language_test_plugin.CoreTests.FlutterSmallApi;
import com.example.alternate_language_test_plugin.CoreTests.HostIntegrationCoreApi;
import com.example.alternate_language_test_plugin.CoreTests.NullableResult;
import com.example.alternate_language_test_plugin.CoreTests.Result;
import com.example.alternate_language_test_plugin.CoreTests.VoidResult;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** This plugin handles the native side of the integration tests in example/integration_test/. */
public class AlternateLanguageTestPlugin implements FlutterPlugin, HostIntegrationCoreApi {
  @Nullable FlutterIntegrationCoreApi flutterApi = null;
  @Nullable FlutterSmallApi flutterSmallApiOne = null;
  @Nullable FlutterSmallApi flutterSmallApiTwo = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    HostIntegrationCoreApi.setUp(binding.getBinaryMessenger(), this);
    flutterApi = new FlutterIntegrationCoreApi(binding.getBinaryMessenger());
    flutterSmallApiOne = new FlutterSmallApi(binding.getBinaryMessenger(), "suffixOne");
    flutterSmallApiTwo = new FlutterSmallApi(binding.getBinaryMessenger(), "suffixTwo");
    TestPluginWithSuffix testSuffixApiOne = new TestPluginWithSuffix();
    testSuffixApiOne.setUp(binding, "suffixOne");
    TestPluginWithSuffix testSuffixApiTwo = new TestPluginWithSuffix();
    testSuffixApiTwo.setUp(binding, "suffixTwo");
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  // HostIntegrationCoreApi

  @Override
  public void noop() {}

  @Override
  public @NonNull AllTypes echoAllTypes(@NonNull AllTypes everything) {
    return everything;
  }

  @Override
  public @Nullable AllNullableTypes echoAllNullableTypes(@Nullable AllNullableTypes everything) {
    return everything;
  }

  @Override
  public @Nullable AllNullableTypesWithoutRecursion echoAllNullableTypesWithoutRecursion(
      @Nullable AllNullableTypesWithoutRecursion everything) {
    return everything;
  }

  @Override
  public @Nullable Object throwError() {
    throw new RuntimeException("An error");
  }

  @Override
  public void throwErrorFromVoid() {
    throw new RuntimeException("An error");
  }

  @Override
  public @Nullable Object throwFlutterError() {
    throw new CoreTests.FlutterError("code", "message", "details");
  }

  @Override
  public @NonNull Long echoInt(@NonNull Long anInt) {
    return anInt;
  }

  @Override
  public @NonNull Double echoDouble(@NonNull Double aDouble) {
    return aDouble;
  }

  @Override
  public @NonNull Boolean echoBool(@NonNull Boolean aBool) {
    return aBool;
  }

  @Override
  public @NonNull String echoString(@NonNull String aString) {
    return aString;
  }

  @Override
  public @NonNull byte[] echoUint8List(@NonNull byte[] aUint8List) {
    return aUint8List;
  }

  @Override
  public @NonNull Object echoObject(@NonNull Object anObject) {
    return anObject;
  }

  @Override
  public @NonNull List<Object> echoList(@NonNull List<Object> list) {
    return list;
  }

  @Override
  public @NonNull List<AnEnum> echoEnumList(@NonNull List<AnEnum> enumList) {
    return enumList;
  }

  @Override
  public @NonNull List<AllNullableTypes> echoClassList(@NonNull List<AllNullableTypes> classList) {
    return classList;
  }

  @NonNull
  @Override
  public List<AnEnum> echoNonNullEnumList(@NonNull List<AnEnum> enumList) {
    return enumList;
  }

  @NonNull
  @Override
  public List<AllNullableTypes> echoNonNullClassList(@NonNull List<AllNullableTypes> classList) {
    return classList;
  }

  @Override
  public @NonNull Map<Object, Object> echoMap(@NonNull Map<Object, Object> map) {
    return map;
  }

  @Override
  public @NonNull Map<String, String> echoStringMap(@NonNull Map<String, String> stringMap) {
    return stringMap;
  }

  @Override
  public @NonNull Map<Long, Long> echoIntMap(@NonNull Map<Long, Long> intMap) {
    return intMap;
  }

  @Override
  public @NonNull Map<AnEnum, AnEnum> echoEnumMap(@NonNull Map<AnEnum, AnEnum> enumMap) {
    return enumMap;
  }

  @Override
  public @NonNull Map<Long, AllNullableTypes> echoClassMap(
      @NonNull Map<Long, AllNullableTypes> classMap) {
    return classMap;
  }

  @NonNull
  @Override
  public Map<String, String> echoNonNullStringMap(@NonNull Map<String, String> stringMap) {
    return stringMap;
  }

  @NonNull
  @Override
  public Map<Long, Long> echoNonNullIntMap(@NonNull Map<Long, Long> intMap) {
    return intMap;
  }

  @NonNull
  @Override
  public Map<AnEnum, AnEnum> echoNonNullEnumMap(@NonNull Map<AnEnum, AnEnum> enumMap) {
    return enumMap;
  }

  @NonNull
  @Override
  public Map<Long, AllNullableTypes> echoNonNullClassMap(
      @NonNull Map<Long, AllNullableTypes> classMap) {
    return classMap;
  }

  @Override
  public @NonNull AllClassesWrapper echoClassWrapper(@NonNull AllClassesWrapper wrapper) {
    return wrapper;
  }

  @Override
  public @NonNull AnEnum echoEnum(@NonNull AnEnum anEnum) {
    return anEnum;
  }

  @Override
  public @NonNull AnotherEnum echoAnotherEnum(@NonNull AnotherEnum anotherEnum) {
    return anotherEnum;
  }

  @Override
  public @NonNull String echoNamedDefaultString(@NonNull String aString) {
    return aString;
  }

  @Override
  public @NonNull Double echoOptionalDefaultDouble(@NonNull Double aDouble) {
    return aDouble;
  }

  @Override
  public @NonNull Long echoRequiredInt(@NonNull Long anInt) {
    return anInt;
  }

  @Override
  public @Nullable String extractNestedNullableString(@NonNull AllClassesWrapper wrapper) {
    return wrapper.getAllNullableTypes().getANullableString();
  }

  @Override
  public @NonNull AllClassesWrapper createNestedNullableString(@Nullable String nullableString) {
    AllNullableTypes innerObject =
        new AllNullableTypes.Builder().setANullableString(nullableString).build();
    return new AllClassesWrapper.Builder()
        .setAllNullableTypes(innerObject)
        .setClassList(new ArrayList<AllTypes>())
        .setClassMap(new HashMap<Long, AllTypes>())
        .build();
  }

  @Override
  public @NonNull AllNullableTypes sendMultipleNullableTypes(
      @Nullable Boolean aNullableBool,
      @Nullable Long aNullableInt,
      @Nullable String aNullableString) {
    return new AllNullableTypes.Builder()
        .setANullableBool(aNullableBool)
        .setANullableInt(aNullableInt)
        .setANullableString(aNullableString)
        .build();
  }

  @Override
  public @NonNull AllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
      @Nullable Boolean aNullableBool,
      @Nullable Long aNullableInt,
      @Nullable String aNullableString) {
    return new AllNullableTypesWithoutRecursion.Builder()
        .setANullableBool(aNullableBool)
        .setANullableInt(aNullableInt)
        .setANullableString(aNullableString)
        .build();
  }

  @Override
  public @Nullable Long echoNullableInt(@Nullable Long aNullableInt) {
    return aNullableInt;
  }

  @Override
  public @Nullable Double echoNullableDouble(@Nullable Double aNullableDouble) {
    return aNullableDouble;
  }

  @Override
  public @Nullable Boolean echoNullableBool(@Nullable Boolean aNullableBool) {
    return aNullableBool;
  }

  @Override
  public @Nullable String echoNullableString(@Nullable String aNullableString) {
    return aNullableString;
  }

  @Override
  public @Nullable byte[] echoNullableUint8List(@Nullable byte[] aNullableUint8List) {
    return aNullableUint8List;
  }

  @Override
  public @Nullable Object echoNullableObject(@Nullable Object aNullableObject) {
    return aNullableObject;
  }

  @Override
  public @Nullable List<Object> echoNullableList(@Nullable List<Object> aNullableList) {
    return aNullableList;
  }

  @Override
  public @Nullable List<AnEnum> echoNullableEnumList(@Nullable List<AnEnum> enumList) {
    return enumList;
  }

  @Override
  public @Nullable List<AllNullableTypes> echoNullableClassList(
      @Nullable List<AllNullableTypes> classList) {
    return classList;
  }

  @Nullable
  @Override
  public List<AnEnum> echoNullableNonNullEnumList(@Nullable List<AnEnum> enumList) {
    return enumList;
  }

  @Nullable
  @Override
  public List<AllNullableTypes> echoNullableNonNullClassList(
      @Nullable List<AllNullableTypes> classList) {
    return classList;
  }

  @Override
  public @Nullable Map<Object, Object> echoNullableMap(@Nullable Map<Object, Object> map) {
    return map;
  }

  @Override
  public @Nullable Map<String, String> echoNullableStringMap(
      @Nullable Map<String, String> stringMap) {
    return stringMap;
  }

  @Override
  public @Nullable Map<Long, Long> echoNullableIntMap(@Nullable Map<Long, Long> intMap) {
    return intMap;
  }

  @Override
  public @Nullable Map<AnEnum, AnEnum> echoNullableEnumMap(@Nullable Map<AnEnum, AnEnum> enumMap) {
    return enumMap;
  }

  @Override
  public @Nullable Map<Long, AllNullableTypes> echoNullableClassMap(
      @Nullable Map<Long, AllNullableTypes> classMap) {
    return classMap;
  }

  @Nullable
  @Override
  public Map<String, String> echoNullableNonNullStringMap(@Nullable Map<String, String> stringMap) {
    return stringMap;
  }

  @Nullable
  @Override
  public Map<Long, Long> echoNullableNonNullIntMap(@Nullable Map<Long, Long> intMap) {
    return intMap;
  }

  @Nullable
  @Override
  public Map<AnEnum, AnEnum> echoNullableNonNullEnumMap(@Nullable Map<AnEnum, AnEnum> enumMap) {
    return enumMap;
  }

  @Nullable
  @Override
  public Map<Long, AllNullableTypes> echoNullableNonNullClassMap(
      @Nullable Map<Long, AllNullableTypes> classMap) {
    return classMap;
  }

  @Override
  public @Nullable AnEnum echoNullableEnum(@Nullable AnEnum anEnum) {
    return anEnum;
  }

  @Override
  public @Nullable AnotherEnum echoAnotherNullableEnum(@Nullable AnotherEnum anotherEnum) {
    return anotherEnum;
  }

  @Override
  public @Nullable Long echoOptionalNullableInt(@Nullable Long aNullableInt) {
    return aNullableInt;
  }

  @Override
  public @Nullable String echoNamedNullableString(@Nullable String aNullableString) {
    return aNullableString;
  }

  @Override
  public void noopAsync(@NonNull VoidResult result) {
    result.success();
  }

  @Override
  public void throwAsyncError(@NonNull NullableResult<Object> result) {
    result.error(new RuntimeException("An error"));
  }

  @Override
  public void throwAsyncErrorFromVoid(@NonNull VoidResult result) {
    result.error(new RuntimeException("An error"));
  }

  @Override
  public void throwAsyncFlutterError(@NonNull NullableResult<Object> result) {
    result.error(new CoreTests.FlutterError("code", "message", "details"));
  }

  @Override
  public void echoAsyncAllTypes(@NonNull AllTypes everything, @NonNull Result<AllTypes> result) {
    result.success(everything);
  }

  @Override
  public void echoAsyncNullableAllNullableTypes(
      @Nullable AllNullableTypes everything, @NonNull NullableResult<AllNullableTypes> result) {
    result.success(everything);
  }

  @Override
  public void echoAsyncNullableAllNullableTypesWithoutRecursion(
      @Nullable AllNullableTypesWithoutRecursion everything,
      @NonNull NullableResult<AllNullableTypesWithoutRecursion> result) {
    result.success(everything);
  }

  @Override
  public void echoAsyncInt(@NonNull Long anInt, @NonNull Result<Long> result) {
    result.success(anInt);
  }

  @Override
  public void echoAsyncDouble(@NonNull Double aDouble, @NonNull Result<Double> result) {
    result.success(aDouble);
  }

  @Override
  public void echoAsyncBool(@NonNull Boolean aBool, @NonNull Result<Boolean> result) {
    result.success(aBool);
  }

  @Override
  public void echoAsyncString(@NonNull String aString, @NonNull Result<String> result) {
    result.success(aString);
  }

  @Override
  public void echoAsyncUint8List(@NonNull byte[] aUint8List, @NonNull Result<byte[]> result) {
    result.success(aUint8List);
  }

  @Override
  public void echoAsyncObject(@NonNull Object anObject, @NonNull Result<Object> result) {
    result.success(anObject);
  }

  @Override
  public void echoAsyncList(@NonNull List<Object> list, @NonNull Result<List<Object>> result) {
    result.success(list);
  }

  @Override
  public void echoAsyncEnumList(
      @NonNull List<AnEnum> enumList, @NonNull Result<List<AnEnum>> result) {
    result.success(enumList);
  }

  @Override
  public void echoAsyncClassList(
      @NonNull List<AllNullableTypes> classList, @NonNull Result<List<AllNullableTypes>> result) {
    result.success(classList);
  }

  @Override
  public void echoAsyncMap(
      @NonNull Map<Object, Object> map, @NonNull Result<Map<Object, Object>> result) {
    result.success(map);
  }

  @Override
  public void echoAsyncStringMap(
      @NonNull Map<String, String> stringMap, @NonNull Result<Map<String, String>> result) {
    result.success(stringMap);
  }

  @Override
  public void echoAsyncIntMap(
      @NonNull Map<Long, Long> intMap, @NonNull Result<Map<Long, Long>> result) {
    result.success(intMap);
  }

  @Override
  public void echoAsyncEnumMap(
      @NonNull Map<AnEnum, AnEnum> enumMap, @NonNull Result<Map<AnEnum, AnEnum>> result) {
    result.success(enumMap);
  }

  @Override
  public void echoAsyncClassMap(
      @NonNull Map<Long, AllNullableTypes> classMap,
      @NonNull Result<Map<Long, AllNullableTypes>> result) {
    result.success(classMap);
  }

  @Override
  public void echoAsyncEnum(@NonNull AnEnum anEnum, @NonNull Result<AnEnum> result) {
    result.success(anEnum);
  }

  @Override
  public void echoAnotherAsyncEnum(
      @NonNull AnotherEnum anotherEnum, @NonNull Result<AnotherEnum> result) {
    result.success(anotherEnum);
  }

  @Override
  public void echoAsyncNullableInt(@Nullable Long anInt, @NonNull NullableResult<Long> result) {
    result.success(anInt);
  }

  @Override
  public void echoAsyncNullableDouble(
      @Nullable Double aDouble, @NonNull NullableResult<Double> result) {
    result.success(aDouble);
  }

  @Override
  public void echoAsyncNullableBool(
      @Nullable Boolean aBool, @NonNull NullableResult<Boolean> result) {
    result.success(aBool);
  }

  @Override
  public void echoAsyncNullableString(
      @Nullable String aString, @NonNull NullableResult<String> result) {
    result.success(aString);
  }

  @Override
  public void echoAsyncNullableUint8List(
      @Nullable byte[] aUint8List, @NonNull NullableResult<byte[]> result) {
    result.success(aUint8List);
  }

  @Override
  public void echoAsyncNullableObject(
      @Nullable Object anObject, @NonNull NullableResult<Object> result) {
    result.success(anObject);
  }

  @Override
  public void echoAsyncNullableList(
      @Nullable List<Object> list, @NonNull NullableResult<List<Object>> result) {
    result.success(list);
  }

  @Override
  public void echoAsyncNullableEnumList(
      @Nullable List<AnEnum> enumList, @NonNull NullableResult<List<AnEnum>> result) {
    result.success(enumList);
  }

  @Override
  public void echoAsyncNullableClassList(
      @Nullable List<AllNullableTypes> classList,
      @NonNull NullableResult<List<AllNullableTypes>> result) {
    result.success(classList);
  }

  @Override
  public void echoAsyncNullableMap(
      @Nullable Map<Object, Object> map, @NonNull NullableResult<Map<Object, Object>> result) {
    result.success(map);
  }

  @Override
  public void echoAsyncNullableStringMap(
      @Nullable Map<String, String> stringMap,
      @NonNull NullableResult<Map<String, String>> result) {
    result.success(stringMap);
  }

  @Override
  public void echoAsyncNullableIntMap(
      @Nullable Map<Long, Long> intMap, @NonNull NullableResult<Map<Long, Long>> result) {
    result.success(intMap);
  }

  @Override
  public void echoAsyncNullableEnumMap(
      @Nullable Map<AnEnum, AnEnum> enumMap, @NonNull NullableResult<Map<AnEnum, AnEnum>> result) {
    result.success(enumMap);
  }

  @Override
  public void echoAsyncNullableClassMap(
      @Nullable Map<Long, AllNullableTypes> classMap,
      @NonNull NullableResult<Map<Long, AllNullableTypes>> result) {
    result.success(classMap);
  }

  @Override
  public void echoAsyncNullableEnum(
      @Nullable AnEnum anEnum, @NonNull NullableResult<AnEnum> result) {
    result.success(anEnum);
  }

  @Override
  public void echoAnotherAsyncNullableEnum(
      @Nullable AnotherEnum anotherEnum, @NonNull NullableResult<AnotherEnum> result) {
    result.success(anotherEnum);
  }

  @Override
  public void callFlutterNoop(@NonNull VoidResult result) {
    assert flutterApi != null;
    flutterApi.noop(result);
  }

  @Override
  public void callFlutterThrowError(@NonNull NullableResult<Object> result) {
    assert flutterApi != null;
    flutterApi.throwError(result);
  }

  @Override
  public void callFlutterThrowErrorFromVoid(@NonNull VoidResult result) {
    assert flutterApi != null;
    flutterApi.throwErrorFromVoid(result);
  }

  @Override
  public void callFlutterEchoAllTypes(
      @NonNull AllTypes everything, @NonNull Result<AllTypes> result) {
    assert flutterApi != null;
    flutterApi.echoAllTypes(everything, result);
  }

  @Override
  public void callFlutterEchoAllNullableTypes(
      @Nullable AllNullableTypes everything, @NonNull NullableResult<AllNullableTypes> result) {
    assert flutterApi != null;
    flutterApi.echoAllNullableTypes(everything, result);
  }

  @Override
  public void callFlutterSendMultipleNullableTypes(
      @Nullable Boolean aNullableBool,
      @Nullable Long aNullableInt,
      @Nullable String aNullableString,
      @NonNull Result<AllNullableTypes> result) {
    assert flutterApi != null;
    flutterApi.sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString, result);
  }

  @Override
  public void callFlutterEchoAllNullableTypesWithoutRecursion(
      @Nullable AllNullableTypesWithoutRecursion everything,
      @NonNull NullableResult<AllNullableTypesWithoutRecursion> result) {
    assert flutterApi != null;
    flutterApi.echoAllNullableTypesWithoutRecursion(everything, result);
  }

  @Override
  public void callFlutterSendMultipleNullableTypesWithoutRecursion(
      @Nullable Boolean aNullableBool,
      @Nullable Long aNullableInt,
      @Nullable String aNullableString,
      @NonNull Result<AllNullableTypesWithoutRecursion> result) {
    assert flutterApi != null;
    flutterApi.sendMultipleNullableTypesWithoutRecursion(
        aNullableBool, aNullableInt, aNullableString, result);
  }

  @Override
  public void callFlutterEchoBool(@NonNull Boolean aBool, @NonNull Result<Boolean> result) {
    assert flutterApi != null;
    flutterApi.echoBool(aBool, result);
  }

  @Override
  public void callFlutterEchoInt(@NonNull Long anInt, @NonNull Result<Long> result) {
    assert flutterApi != null;
    flutterApi.echoInt(anInt, result);
  }

  @Override
  public void callFlutterEchoDouble(@NonNull Double aDouble, @NonNull Result<Double> result) {
    assert flutterApi != null;
    flutterApi.echoDouble(aDouble, result);
  }

  @Override
  public void callFlutterEchoString(@NonNull String aString, @NonNull Result<String> result) {
    assert flutterApi != null;
    flutterApi.echoString(aString, result);
  }

  @Override
  public void callFlutterEchoUint8List(@NonNull byte[] list, @NonNull Result<byte[]> result) {
    assert flutterApi != null;
    flutterApi.echoUint8List(list, result);
  }

  @Override
  public void callFlutterEchoList(
      @NonNull List<Object> list, @NonNull Result<List<Object>> result) {
    assert flutterApi != null;
    flutterApi.echoList(list, result);
  }

  @Override
  public void callFlutterEchoEnumList(
      @NonNull List<AnEnum> enumList, @NonNull Result<List<AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoEnumList(enumList, result);
  }

  @Override
  public void callFlutterEchoClassList(
      @NonNull List<AllNullableTypes> classNullableTypes,
      @NonNull Result<List<AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoClassList(classNullableTypes, result);
  }

  @Override
  public void callFlutterEchoNonNullEnumList(
      @NonNull List<AnEnum> enumList, @NonNull Result<List<AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoNonNullEnumList(enumList, result);
  }

  @Override
  public void callFlutterEchoNonNullClassList(
      @NonNull List<AllNullableTypes> classList, @NonNull Result<List<AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoNonNullClassList(classList, result);
  }

  @Override
  public void callFlutterEchoMap(
      @NonNull Map<Object, Object> map, @NonNull Result<Map<Object, Object>> result) {
    assert flutterApi != null;
    flutterApi.echoMap(map, result);
  }

  @Override
  public void callFlutterEchoStringMap(
      @NonNull Map<String, String> stringMap, @NonNull Result<Map<String, String>> result) {
    assert flutterApi != null;
    flutterApi.echoStringMap(stringMap, result);
  }

  @Override
  public void callFlutterEchoIntMap(
      @NonNull Map<Long, Long> intMap, @NonNull Result<Map<Long, Long>> result) {
    assert flutterApi != null;
    flutterApi.echoIntMap(intMap, result);
  }

  @Override
  public void callFlutterEchoEnumMap(
      @NonNull Map<AnEnum, AnEnum> enumMap, @NonNull Result<Map<AnEnum, AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoEnumMap(enumMap, result);
  }

  @Override
  public void callFlutterEchoClassMap(
      @NonNull Map<Long, AllNullableTypes> classMap,
      @NonNull Result<Map<Long, AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoClassMap(classMap, result);
  }

  @Override
  public void callFlutterEchoNonNullStringMap(
      @NonNull Map<String, String> stringMap, @NonNull Result<Map<String, String>> result) {
    assert flutterApi != null;
    flutterApi.echoNonNullStringMap(stringMap, result);
  }

  @Override
  public void callFlutterEchoNonNullIntMap(
      @NonNull Map<Long, Long> intMap, @NonNull Result<Map<Long, Long>> result) {
    assert flutterApi != null;
    flutterApi.echoNonNullIntMap(intMap, result);
  }

  @Override
  public void callFlutterEchoNonNullEnumMap(
      @NonNull Map<AnEnum, AnEnum> enumMap, @NonNull Result<Map<AnEnum, AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoNonNullEnumMap(enumMap, result);
  }

  @Override
  public void callFlutterEchoNonNullClassMap(
      @NonNull Map<Long, AllNullableTypes> classMap,
      @NonNull Result<Map<Long, AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoNonNullClassMap(classMap, result);
  }

  @Override
  public void callFlutterEchoEnum(@NonNull AnEnum anEnum, @NonNull Result<AnEnum> result) {
    assert flutterApi != null;
    flutterApi.echoEnum(anEnum, result);
  }

  @Override
  public void callFlutterEchoAnotherEnum(
      @NonNull AnotherEnum anotherEnum, @NonNull Result<AnotherEnum> result) {
    assert flutterApi != null;
    flutterApi.echoAnotherEnum(anotherEnum, result);
  }

  @Override
  public void callFlutterEchoNullableBool(
      @Nullable Boolean aBool, @NonNull NullableResult<Boolean> result) {
    assert flutterApi != null;
    flutterApi.echoNullableBool(aBool, result);
  }

  @Override
  public void callFlutterEchoNullableInt(
      @Nullable Long anInt, @NonNull NullableResult<Long> result) {
    assert flutterApi != null;
    flutterApi.echoNullableInt(anInt, result);
  }

  @Override
  public void callFlutterEchoNullableDouble(
      @Nullable Double aDouble, @NonNull NullableResult<Double> result) {
    assert flutterApi != null;
    flutterApi.echoNullableDouble(aDouble, result);
  }

  @Override
  public void callFlutterEchoNullableString(
      @Nullable String aString, @NonNull NullableResult<String> result) {
    assert flutterApi != null;
    flutterApi.echoNullableString(aString, result);
  }

  @Override
  public void callFlutterEchoNullableUint8List(
      @Nullable byte[] list, @NonNull NullableResult<byte[]> result) {
    assert flutterApi != null;
    flutterApi.echoNullableUint8List(list, result);
  }

  @Override
  public void callFlutterEchoNullableList(
      @Nullable List<Object> list, @NonNull NullableResult<List<Object>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableList(list, result);
  }

  @Override
  public void callFlutterEchoNullableEnumList(
      @Nullable List<AnEnum> enumList, @NonNull NullableResult<List<AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableEnumList(enumList, result);
  }

  @Override
  public void callFlutterEchoNullableClassList(
      @Nullable List<AllNullableTypes> classList,
      @NonNull NullableResult<List<AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableClassList(classList, result);
  }

  @Override
  public void callFlutterEchoNullableNonNullEnumList(
      @Nullable List<AnEnum> enumList, @NonNull NullableResult<List<AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableNonNullEnumList(enumList, result);
  }

  @Override
  public void callFlutterEchoNullableNonNullClassList(
      @Nullable List<AllNullableTypes> classList,
      @NonNull NullableResult<List<AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableNonNullClassList(classList, result);
  }

  @Override
  public void callFlutterEchoNullableMap(
      @Nullable Map<Object, Object> map, @NonNull NullableResult<Map<Object, Object>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableMap(map, result);
  }

  @Override
  public void callFlutterEchoNullableStringMap(
      @Nullable Map<String, String> stringMap,
      @NonNull NullableResult<Map<String, String>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableStringMap(stringMap, result);
  }

  @Override
  public void callFlutterEchoNullableIntMap(
      @Nullable Map<Long, Long> intMap, @NonNull NullableResult<Map<Long, Long>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableIntMap(intMap, result);
  }

  @Override
  public void callFlutterEchoNullableEnumMap(
      @Nullable Map<AnEnum, AnEnum> enumMap, @NonNull NullableResult<Map<AnEnum, AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableEnumMap(enumMap, result);
  }

  @Override
  public void callFlutterEchoNullableClassMap(
      @Nullable Map<Long, AllNullableTypes> classMap,
      @NonNull NullableResult<Map<Long, AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableClassMap(classMap, result);
  }

  @Override
  public void callFlutterEchoNullableNonNullStringMap(
      @Nullable Map<String, String> stringMap,
      @NonNull NullableResult<Map<String, String>> result) {

    assert flutterApi != null;
    flutterApi.echoNullableNonNullStringMap(stringMap, result);
  }

  @Override
  public void callFlutterEchoNullableNonNullIntMap(
      @Nullable Map<Long, Long> intMap, @NonNull NullableResult<Map<Long, Long>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableNonNullIntMap(intMap, result);
  }

  @Override
  public void callFlutterEchoNullableNonNullEnumMap(
      @Nullable Map<AnEnum, AnEnum> enumMap, @NonNull NullableResult<Map<AnEnum, AnEnum>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableNonNullEnumMap(enumMap, result);
  }

  @Override
  public void callFlutterEchoNullableNonNullClassMap(
      @Nullable Map<Long, AllNullableTypes> classMap,
      @NonNull NullableResult<Map<Long, AllNullableTypes>> result) {
    assert flutterApi != null;
    flutterApi.echoNullableNonNullClassMap(classMap, result);
  }

  @Override
  public void callFlutterEchoNullableEnum(
      @Nullable AnEnum anEnum, @NonNull NullableResult<AnEnum> result) {
    assert flutterApi != null;
    flutterApi.echoNullableEnum(anEnum, result);
  }

  @Override
  public void callFlutterEchoAnotherNullableEnum(
      @Nullable AnotherEnum anotherEnum, @NonNull NullableResult<AnotherEnum> result) {
    assert flutterApi != null;
    flutterApi.echoAnotherNullableEnum(anotherEnum, result);
  }

  @Override
  public void callFlutterSmallApiEchoString(
      @NonNull String aString, @NonNull Result<String> result) {
    final String[] resultOne = {""};

    Result<String> resultCallbackTwo =
        new Result<String>() {
          public void success(String res) {
            String resOne = resultOne[0];
            if (res.equals(resOne)) {
              result.success(res);
            } else {
              result.error(
                  new CoreTests.FlutterError(
                      "Responses do not match",
                      "Multi-instance responses were not matching: " + resultOne[0] + ", " + res,
                      ""));
            }
          }

          public void error(Throwable error) {
            result.error(error);
          }
        };

    Result<String> resultCallbackOne =
        new Result<String>() {
          public void success(String res) {
            resultOne[0] = res;
            flutterSmallApiTwo.echoString(aString, resultCallbackTwo);
          }

          public void error(Throwable error) {
            result.error(error);
          }
        };
    flutterSmallApiOne.echoString(aString, resultCallbackOne);
  }

  public @NonNull CoreTests.UnusedClass testIfUnusedClassIsGenerated() {
    return new CoreTests.UnusedClass();
  }
}

class TestPluginWithSuffix implements CoreTests.HostSmallApi {

  public void setUp(FlutterPlugin.FlutterPluginBinding binding, String suffix) {
    CoreTests.HostSmallApi.setUp(binding.getBinaryMessenger(), suffix, this);
  }

  @Override
  public void echo(@NonNull String aString, @NonNull Result<String> result) {
    result.success(aString);
  }

  @Override
  public void voidVoid(@NonNull VoidResult result) {
    result.success();
  }
}
