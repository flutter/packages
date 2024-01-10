// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.CoreTests.AllNullableTypes;
import com.example.alternate_language_test_plugin.CoreTests.AllTypes;
import com.example.alternate_language_test_plugin.CoreTests.FlutterIntegrationCoreApi;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import org.junit.Test;

public class AllDatatypesTest {

  void compareAllTypes(AllTypes firstTypes, AllTypes secondTypes) {
    assertEquals(firstTypes == null, secondTypes == null);
    if (firstTypes == null || secondTypes == null) {
      return;
    }
    assertEquals(firstTypes.getABool(), secondTypes.getABool());
    assertEquals(firstTypes.getAnInt(), secondTypes.getAnInt());
    assertEquals(firstTypes.getAnInt64(), secondTypes.getAnInt64());

    assertEquals(firstTypes.getADouble(), secondTypes.getADouble());
    assertArrayEquals(firstTypes.getAByteArray(), secondTypes.getAByteArray());
    assertArrayEquals(firstTypes.getA4ByteArray(), secondTypes.getA4ByteArray());
    assertArrayEquals(firstTypes.getA8ByteArray(), secondTypes.getA8ByteArray());
    assertTrue(floatArraysEqual(firstTypes.getAFloatArray(), secondTypes.getAFloatArray()));
    assertArrayEquals(firstTypes.getAList().toArray(), secondTypes.getAList().toArray());
    assertArrayEquals(
        firstTypes.getAMap().keySet().toArray(), secondTypes.getAMap().keySet().toArray());
    assertArrayEquals(
        firstTypes.getAMap().values().toArray(), secondTypes.getAMap().values().toArray());
    assertEquals(firstTypes.getAnEnum(), secondTypes.getAnEnum());
    assertEquals(firstTypes.getAnObject(), secondTypes.getAnObject());
  }

  void compareAllNullableTypes(AllNullableTypes firstTypes, AllNullableTypes secondTypes) {
    assertEquals(firstTypes == null, secondTypes == null);
    if (firstTypes == null || secondTypes == null) {
      return;
    }
    assertEquals(firstTypes.getANullableBool(), secondTypes.getANullableBool());
    assertEquals(firstTypes.getANullableInt(), secondTypes.getANullableInt());
    assertEquals(firstTypes.getANullableDouble(), secondTypes.getANullableDouble());
    assertEquals(firstTypes.getANullableString(), secondTypes.getANullableString());
    assertArrayEquals(firstTypes.getANullableByteArray(), secondTypes.getANullableByteArray());
    assertArrayEquals(firstTypes.getANullable4ByteArray(), secondTypes.getANullable4ByteArray());
    assertArrayEquals(firstTypes.getANullable8ByteArray(), secondTypes.getANullable8ByteArray());
    assertTrue(
        floatArraysEqual(
            firstTypes.getANullableFloatArray(), secondTypes.getANullableFloatArray()));
    assertArrayEquals(
        firstTypes.getANullableList().toArray(), secondTypes.getANullableList().toArray());
    assertArrayEquals(
        firstTypes.getANullableMap().keySet().toArray(),
        secondTypes.getANullableMap().keySet().toArray());
    assertArrayEquals(
        firstTypes.getANullableMap().values().toArray(),
        secondTypes.getANullableMap().values().toArray());
    assertArrayEquals(
        firstTypes.getNullableMapWithObject().values().toArray(),
        secondTypes.getNullableMapWithObject().values().toArray());
    assertEquals(firstTypes.getANullableObject(), secondTypes.getANullableObject());
  }

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
              ByteBuffer replyData = FlutterIntegrationCoreApi.getCodec().encodeMessage(args);
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
        new CoreTests.NullableResult<AllNullableTypes>() {
          public void success(AllNullableTypes result) {
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
          }

          public void error(Throwable error) {
            assertEquals(error, null);
          }
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
    AllTypes allEverything =
        new AllTypes.Builder()
            .setABool(false)
            .setAnInt(1234L)
            .setAnInt64(4321L)
            .setADouble(2.0)
            .setAString("hello")
            .setAByteArray(new byte[] {1, 2, 3, 4})
            .setA4ByteArray(new int[] {1, 2, 3, 4})
            .setA8ByteArray(new long[] {1, 2, 3, 4})
            .setAFloatArray(new double[] {0.5, 0.25, 1.5, 1.25})
            .setAList(Arrays.asList(new int[] {1, 2, 3}))
            .setAMap(makeMap("hello", 1234))
            .setAnEnum(CoreTests.AnEnum.ONE)
            .setAnObject(0)
            .build();

    AllNullableTypes everything =
        new AllNullableTypes.Builder()
            .setANullableBool(false)
            .setANullableInt(1234L)
            .setANullableDouble(2.0)
            .setANullableString("hello")
            .setANullableByteArray(new byte[] {1, 2, 3, 4})
            .setANullable4ByteArray(new int[] {1, 2, 3, 4})
            .setANullable8ByteArray(new long[] {1, 2, 3, 4})
            .setANullableFloatArray(new double[] {0.5, 0.25, 1.5, 1.25})
            .setANullableList(Arrays.asList(new int[] {1, 2, 3}))
            .setANullableMap(makeMap("hello", 1234))
            .setNullableMapWithObject(makeStringMap("hello", 1234))
            .setANullableObject(0)
            .build();

    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              @SuppressWarnings("unchecked")
              ArrayList<Object> args =
                  (ArrayList<Object>) FlutterIntegrationCoreApi.getCodec().decodeMessage(message);
              ByteBuffer replyData = FlutterIntegrationCoreApi.getCodec().encodeMessage(args);
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
        new CoreTests.NullableResult<AllNullableTypes>() {
          public void success(AllNullableTypes result) {
            didCall[0] = true;
            compareAllNullableTypes(everything, result);
          }

          public void error(Throwable error) {
            assertEquals(error, null);
          }
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
