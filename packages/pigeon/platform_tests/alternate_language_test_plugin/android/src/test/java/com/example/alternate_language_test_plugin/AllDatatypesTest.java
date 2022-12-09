// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.CoreTests.AllTypes;
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
    AllTypes everything = new AllTypes();
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
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
    api.echoAllTypes(
        everything,
        (result) -> {
          didCall[0] = true;
          assertNull(everything.getABool());
          assertNull(everything.getAnInt());
          assertNull(everything.getADouble());
          assertNull(everything.getAString());
          assertNull(everything.getAByteArray());
          assertNull(everything.getA4ByteArray());
          assertNull(everything.getA8ByteArray());
          assertNull(everything.getAFloatArray());
          assertNull(everything.getAList());
          assertNull(everything.getAMap());
          assertNull(everything.getMapWithObject());
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
    AllTypes everything = new AllTypes();
    everything.setABool(false);
    everything.setAnInt(1234L);
    everything.setADouble(2.0);
    everything.setAString("hello");
    everything.setAByteArray(new byte[] {1, 2, 3, 4});
    everything.setA4ByteArray(new int[] {1, 2, 3, 4});
    everything.setA8ByteArray(new long[] {1, 2, 3, 4});
    everything.setAFloatArray(new double[] {0.5, 0.25, 1.5, 1.25});
    everything.setAList(Arrays.asList(new int[] {1, 2, 3}));
    everything.setAMap(makeMap("hello", 1234));
    everything.setMapWithObject(makeStringMap("hello", 1234));
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
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
    api.echoAllTypes(
        everything,
        (result) -> {
          didCall[0] = true;
          assertEquals(everything.getABool(), result.getABool());
          assertEquals(everything.getAnInt(), result.getAnInt());
          assertEquals(everything.getADouble(), result.getADouble());
          assertEquals(everything.getAString(), result.getAString());
          assertArrayEquals(everything.getAByteArray(), result.getAByteArray());
          assertArrayEquals(everything.getA4ByteArray(), result.getA4ByteArray());
          assertArrayEquals(everything.getA8ByteArray(), result.getA8ByteArray());
          assertTrue(floatArraysEqual(everything.getAFloatArray(), result.getAFloatArray()));
          assertArrayEquals(everything.getAList().toArray(), result.getAList().toArray());
          assertArrayEquals(
              everything.getAMap().keySet().toArray(), result.getAMap().keySet().toArray());
          assertArrayEquals(
              everything.getAMap().values().toArray(), result.getAMap().values().toArray());
          assertArrayEquals(
              everything.getMapWithObject().values().toArray(),
              result.getMapWithObject().values().toArray());
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void integerToLong() {
    AllTypes everything = new AllTypes();
    everything.setAnInt(123L);
    ArrayList<Object> list = everything.toList();
    assertNotNull(list);
    assertNull(list.get(0));
    assertNotNull(list.get(1));
    list.set(1, 123);
    AllTypes readEverything = AllTypes.fromList(list);
    assertEquals(readEverything.getAnInt(), everything.getAnInt());
  }
}
