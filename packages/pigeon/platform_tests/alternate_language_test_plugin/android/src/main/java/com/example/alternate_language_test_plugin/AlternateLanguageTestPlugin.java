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
  public void throwError() {
    throw new RuntimeException("An error");
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
  public void noopAsync(Result<Void> result) {
    result.success(null);
  }

  @Override
  public void echoAsyncString(@NonNull String aString, Result<String> result) {
    result.success(aString);
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
  public void callFlutterEchoString(@NonNull String aString, Result<String> result) {
    flutterApi.echoString(
        aString,
        new FlutterIntegrationCoreApi.Reply<String>() {
          public void reply(String value) {
            result.success(value);
          }
        });
  }
}
