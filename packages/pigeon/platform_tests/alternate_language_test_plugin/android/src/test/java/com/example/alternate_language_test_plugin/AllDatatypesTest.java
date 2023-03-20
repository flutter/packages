// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.CoreTests.AllNullableTypes;
import com.example.alternate_language_test_plugin.CoreTests.FlutterIntegrationCoreApi;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import org.junit.Test;

public class AllDatatypesTest {
  @Test
  public void nullValues() {
    AllNullableTypes everything = new AllNullableTypes();
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              @SuppressWarnings("unchecked")
              ArrayList<Object> args =
                  (ArrayList<Object>) FlutterIntegrationCoreApi.getCodec().decodeMessage(message);
              ByteBuffer replyData =
                  FlutterIntegrationCoreApi.getCodec().encodeMessage(args.get(0));
              replyData.position(0);
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    FlutterIntegrationCoreApi api = new FlutterIntegrationCoreApi(binaryMessenger);
    boolean[] didCall = {false};
    api.echoAllNullableTypes(
        everything,
        (result) -> {
          didCall[0] = true;
          assertNull(everything.getANullableBool());
          assertNull(everything.getANullableInt());
          assertNull(everything.getANullableDouble());
          assertNull(everything.getANullableString());
          assertNull(everything.getANullableByteArray());
          assertNull(everything.getANullable4ByteArray());
          assertNull(everything.getANullable8ByteArray());
          assertNull(everything.getANullableFloatArray());
          assertNull(everything.getANullableList());
          assertNull(everything.getANullableMap());
          assertNull(everything.getNullableMapWithObject());
        });
    assertTrue(didCall[0]);
  }

  private static HashMap<Object, Object> makeMap(String key, Integer value) {
    HashMap<Object, Object> result = new HashMap<Object, Object>();
    result.put(key, value);
    return result;
  }

  private static HashMap<String, Object> makeStringMap(String key, Integer value) {
    HashMap<String, Object> result = new HashMap<String, Object>();
    result.put(key, value);
    return result;
  }

  private static boolean floatArraysEqual(double[] x, double[] y) {
    if (x.length != y.length) {
      return false;
    }
    for (int i = 0; i < x.length; ++i) {
      if (x[i] != y[i]) {
        return false;
      }
    }
    return true;
  }

  @Test
  public void hasValues() {
    AllNullableTypes everything = new AllNullableTypes();
    everything.setANullableBool(false);
    everything.setANullableInt(1234L);
    everything.setANullableDouble(2.0);
    everything.setANullableString("hello");
    everything.setANullableByteArray(new byte[] {1, 2, 3, 4});
    everything.setANullable4ByteArray(new int[] {1, 2, 3, 4});
    everything.setANullable8ByteArray(new long[] {1, 2, 3, 4});
    everything.setANullableFloatArray(new double[] {0.5, 0.25, 1.5, 1.25});
    everything.setANullableList(Arrays.asList(new int[] {1, 2, 3}));
    everything.setANullableMap(makeMap("hello", 1234));
    everything.setNullableMapWithObject(makeStringMap("hello", 1234));
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              @SuppressWarnings("unchecked")
              ArrayList<Object> args =
                  (ArrayList<Object>) FlutterIntegrationCoreApi.getCodec().decodeMessage(message);
              ByteBuffer replyData =
                  FlutterIntegrationCoreApi.getCodec().encodeMessage(args.get(0));
              replyData.position(0);
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    FlutterIntegrationCoreApi api = new FlutterIntegrationCoreApi(binaryMessenger);
    boolean[] didCall = {false};
    api.echoAllNullableTypes(
        everything,
        (result) -> {
          didCall[0] = true;
          assertEquals(everything.getANullableBool(), result.getANullableBool());
          assertEquals(everything.getANullableInt(), result.getANullableInt());
          assertEquals(everything.getANullableDouble(), result.getANullableDouble());
          assertEquals(everything.getANullableString(), result.getANullableString());
          assertArrayEquals(everything.getANullableByteArray(), result.getANullableByteArray());
          assertArrayEquals(everything.getANullable4ByteArray(), result.getANullable4ByteArray());
          assertArrayEquals(everything.getANullable8ByteArray(), result.getANullable8ByteArray());
          assertTrue(
              floatArraysEqual(
                  everything.getANullableFloatArray(), result.getANullableFloatArray()));
          assertArrayEquals(
              everything.getANullableList().toArray(), result.getANullableList().toArray());
          assertArrayEquals(
              everything.getANullableMap().keySet().toArray(),
              result.getANullableMap().keySet().toArray());
          assertArrayEquals(
              everything.getANullableMap().values().toArray(),
              result.getANullableMap().values().toArray());
          assertArrayEquals(
              everything.getNullableMapWithObject().values().toArray(),
              result.getNullableMapWithObject().values().toArray());
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void integerToLong() {
    AllNullableTypes everything = new AllNullableTypes();
    everything.setANullableInt(123L);
    ArrayList<Object> list = everything.toList();
    assertNotNull(list);
    assertNull(list.get(0));
    assertNotNull(list.get(1));
    list.set(1, 123);
    AllNullableTypes readEverything = AllNullableTypes.fromList(list);
    assertEquals(readEverything.getANullableInt(), everything.getANullableInt());
  }
}
