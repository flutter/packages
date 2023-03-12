// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.example.alternate_language_test_plugin.CoreTests.AllNullableTypes;
import com.example.alternate_language_test_plugin.CoreTests.AllNullableTypesWrapper;
import com.example.alternate_language_test_plugin.CoreTests.AllTypes;
import com.example.alternate_language_test_plugin.CoreTests.FlutterIntegrationCoreApi;
import com.example.alternate_language_test_plugin.CoreTests.HostIntegrationCoreApi;
import com.example.alternate_language_test_plugin.CoreTests.Result;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import java.util.List;
import java.util.Map;

/** This plugin handles the native side of the integration tests in example/integration_test/. */
public class AlternateLanguageTestPlugin implements FlutterPlugin, HostIntegrationCoreApi {
  @Nullable FlutterIntegrationCoreApi flutterApi = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    HostIntegrationCoreApi.setup(binding.getBinaryMessenger(), this);
    flutterApi = new FlutterIntegrationCoreApi(binding.getBinaryMessenger());
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
  public Long echoInt(@NonNull Long anInt) {
    return anInt;
  }

  @Override
  public Double echoDouble(@NonNull Double aDouble) {
    return aDouble;
  }

  @Override
  public Boolean echoBool(@NonNull Boolean aBool) {
    return aBool;
  }

  @Override
  public String echoString(@NonNull String aString) {
    return aString;
  }

  @Override
  public byte[] echoUint8List(@NonNull byte[] aUint8List) {
    return aUint8List;
  }

  @Override
  public @NonNull Object echoObject(@NonNull Object anObject) {
    return anObject;
  }

  @Override
  public List<Object> echoList(@NonNull List<Object> aList) {
    return aList;
  }

  @Override
  public Map<String, Object> echoMap(@NonNull Map<String, Object> aMap) {
    return aMap;
  }

  @Override
  public @Nullable String extractNestedNullableString(@NonNull AllNullableTypesWrapper wrapper) {
    return wrapper.getValues().getANullableString();
  }

  @Override
  public @NonNull AllNullableTypesWrapper createNestedNullableString(
      @Nullable String nullableString) {
    AllNullableTypes innerObject =
        new AllNullableTypes.Builder().setANullableString(nullableString).build();
    return new AllNullableTypesWrapper.Builder().setValues(innerObject).build();
  }

  @Override
  public @NonNull AllNullableTypes sendMultipleNullableTypes(
      @Nullable Boolean aNullableBool,
      @Nullable Long aNullableInt,
      @Nullable String aNullableString) {
    AllNullableTypes someThings =
        new AllNullableTypes.Builder()
            .setANullableBool(aNullableBool)
            .setANullableInt(aNullableInt)
            .setANullableString(aNullableString)
            .build();
    return someThings;
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
  public List<Object> echoNullableList(@Nullable List<Object> aNullableList) {
    return aNullableList;
  }

  @Override
  public Map<String, Object> echoNullableMap(@Nullable Map<String, Object> aNullableMap) {
    return aNullableMap;
  }

  @Override
  public void noopAsync(Result<Void> result) {
    result.success(null);
  }

  @Override
  public void throwAsyncError(Result<Object> result) {
    result.error(new RuntimeException("An error"));
  }

  @Override
  public void throwAsyncErrorFromVoid(Result<Void> result) {
    result.error(new RuntimeException("An error"));
  }

  @Override
  public void throwAsyncFlutterError(Result<Object> result) {
    result.error(new CoreTests.FlutterError("code", "message", "details"));
  }

  @Override
  public void echoAsyncAllTypes(@NonNull AllTypes everything, Result<AllTypes> result) {
    result.success(everything);
  }

  @Override
  public void echoAsyncNullableAllNullableTypes(
      @Nullable AllNullableTypes everything, Result<AllNullableTypes> result) {
    result.success(everything);
  }

  @Override
  public void echoAsyncInt(@NonNull Long anInt, Result<Long> result) {
    result.success(anInt);
  }

  @Override
  public void echoAsyncDouble(@NonNull Double aDouble, Result<Double> result) {
    result.success(aDouble);
  }

  @Override
  public void echoAsyncBool(@NonNull Boolean aBool, Result<Boolean> result) {
    result.success(aBool);
  }

  @Override
  public void echoAsyncString(@NonNull String aString, Result<String> result) {
    result.success(aString);
  }

  @Override
  public void echoAsyncUint8List(@NonNull byte[] aUint8List, Result<byte[]> result) {
    result.success(aUint8List);
  }

  @Override
  public void echoAsyncObject(@NonNull Object anObject, Result<Object> result) {
    result.success(anObject);
  }

  @Override
  public void echoAsyncList(@NonNull List<Object> aList, Result<List<Object>> result) {
    result.success(aList);
  }

  @Override
  public void echoAsyncMap(@NonNull Map<String, Object> aMap, Result<Map<String, Object>> result) {
    result.success(aMap);
  }

  @Override
  public void echoAsyncNullableInt(@Nullable Long anInt, Result<Long> result) {
    result.success(anInt);
  }

  @Override
  public void echoAsyncNullableDouble(@Nullable Double aDouble, Result<Double> result) {
    result.success(aDouble);
  }

  @Override
  public void echoAsyncNullableBool(@Nullable Boolean aBool, Result<Boolean> result) {
    result.success(aBool);
  }

  @Override
  public void echoAsyncNullableString(@Nullable String aString, Result<String> result) {
    result.success(aString);
  }

  @Override
  public void echoAsyncNullableUint8List(@Nullable byte[] aUint8List, Result<byte[]> result) {
    result.success(aUint8List);
  }

  @Override
  public void echoAsyncNullableObject(@Nullable Object anObject, Result<Object> result) {
    result.success(anObject);
  }

  @Override
  public void echoAsyncNullableList(@Nullable List<Object> aList, Result<List<Object>> result) {
    result.success(aList);
  }

  @Override
  public void echoAsyncNullableMap(
      @Nullable Map<String, Object> aMap, Result<Map<String, Object>> result) {
    result.success(aMap);
  }

  @Override
  public void callFlutterNoop(Result<Void> result) {
    flutterApi.noop(
        new FlutterIntegrationCoreApi.Reply<Void>() {
          public void reply(Void value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterThrowError(Result<Object> result) {
    flutterApi.throwError(
        new FlutterIntegrationCoreApi.Reply<Object>() {
          public void reply(Object value) {
            // TODO: (tarrinneal) Once flutter api error handling is added,
            // update error handling tests to properly recieve and handle errors.
            // See issue https://github.com/flutter/flutter/issues/118243
          }
        });
  }

  @Override
  public void callFlutterThrowErrorFromVoid(Result<Void> result) {
    flutterApi.throwErrorFromVoid(
        new FlutterIntegrationCoreApi.Reply<Void>() {
          public void reply(Void value) {
            // TODO: (tarrinneal) Once flutter api error handling is added,
            // update error handling tests to properly recieve and handle errors.
            // See issue https://github.com/flutter/flutter/issues/118243
          }
        });
  }

  @Override
  public void callFlutterEchoAllTypes(@NonNull AllTypes everything, Result<AllTypes> result) {
    flutterApi.echoAllTypes(
        everything,
        new FlutterIntegrationCoreApi.Reply<AllTypes>() {
          public void reply(AllTypes value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterSendMultipleNullableTypes(
      @Nullable Boolean aNullableBool,
      @Nullable Long aNullableInt,
      @Nullable String aNullableString,
      Result<AllNullableTypes> result) {
    flutterApi.sendMultipleNullableTypes(
        aNullableBool,
        aNullableInt,
        aNullableString,
        new FlutterIntegrationCoreApi.Reply<AllNullableTypes>() {
          public void reply(AllNullableTypes value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoBool(@NonNull Boolean aBool, Result<Boolean> result) {
    flutterApi.echoBool(
        aBool,
        new FlutterIntegrationCoreApi.Reply<Boolean>() {
          public void reply(Boolean value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoInt(@NonNull Long anInt, Result<Long> result) {
    flutterApi.echoInt(
        anInt,
        new FlutterIntegrationCoreApi.Reply<Long>() {
          public void reply(Long value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoDouble(@NonNull Double aDouble, Result<Double> result) {
    flutterApi.echoDouble(
        aDouble,
        new FlutterIntegrationCoreApi.Reply<Double>() {
          public void reply(Double value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoString(@NonNull String aString, Result<String> result) {
    flutterApi.echoString(
        aString,
        new FlutterIntegrationCoreApi.Reply<String>() {
          public void reply(String value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoUint8List(@NonNull byte[] aList, Result<byte[]> result) {
    flutterApi.echoUint8List(
        aList,
        new FlutterIntegrationCoreApi.Reply<byte[]>() {
          public void reply(byte[] value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoList(@NonNull List<Object> aList, Result<List<Object>> result) {
    flutterApi.echoList(
        aList,
        new FlutterIntegrationCoreApi.Reply<List<Object>>() {
          public void reply(List<Object> value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoMap(
      @NonNull Map<String, Object> aMap, Result<Map<String, Object>> result) {
    flutterApi.echoMap(
        aMap,
        new FlutterIntegrationCoreApi.Reply<Map<String, Object>>() {
          public void reply(Map<String, Object> value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableBool(@Nullable Boolean aBool, Result<Boolean> result) {
    flutterApi.echoNullableBool(
        aBool,
        new FlutterIntegrationCoreApi.Reply<Boolean>() {
          public void reply(Boolean value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableInt(@Nullable Long anInt, Result<Long> result) {
    flutterApi.echoNullableInt(
        anInt,
        new FlutterIntegrationCoreApi.Reply<Long>() {
          public void reply(Long value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableDouble(@Nullable Double aDouble, Result<Double> result) {
    flutterApi.echoNullableDouble(
        aDouble,
        new FlutterIntegrationCoreApi.Reply<Double>() {
          public void reply(Double value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableString(@Nullable String aString, Result<String> result) {
    flutterApi.echoNullableString(
        aString,
        new FlutterIntegrationCoreApi.Reply<String>() {
          public void reply(String value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableUint8List(@Nullable byte[] aList, Result<byte[]> result) {
    flutterApi.echoNullableUint8List(
        aList,
        new FlutterIntegrationCoreApi.Reply<byte[]>() {
          public void reply(byte[] value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableList(
      @Nullable List<Object> aList, Result<List<Object>> result) {
    flutterApi.echoNullableList(
        aList,
        new FlutterIntegrationCoreApi.Reply<List<Object>>() {
          public void reply(List<Object> value) {
            result.success(value);
          }
        });
  }

  @Override
  public void callFlutterEchoNullableMap(
      @Nullable Map<String, Object> aMap, Result<Map<String, Object>> result) {
    flutterApi.echoNullableMap(
        aMap,
        new FlutterIntegrationCoreApi.Reply<Map<String, Object>>() {
          public void reply(Map<String, Object> value) {
            result.success(value);
          }
        });
  }
}
