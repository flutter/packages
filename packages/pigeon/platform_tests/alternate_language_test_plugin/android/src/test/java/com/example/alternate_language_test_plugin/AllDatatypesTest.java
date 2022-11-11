// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.AllDatatypes.*;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;

public class AllDatatypesTest {
  @Test
  public void nullValues() {
    Everything everything = new Everything();
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              ArrayList<Object> args =
                  (ArrayList<Object>) FlutterEverything.getCodec().decodeMessage(message);
              ByteBuffer replyData = FlutterEverything.getCodec().encodeMessage(args.get(0));
              replyData.position(0);
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    FlutterEverything api = new FlutterEverything(binaryMessenger);
    boolean[] didCall = {false};
    api.echo(
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
    Everything everything = new Everything();
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
                  (ArrayList<Object>) FlutterEverything.getCodec().decodeMessage(message);
              ByteBuffer replyData = FlutterEverything.getCodec().encodeMessage(args.get(0));
              replyData.position(0);
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    FlutterEverything api = new FlutterEverything(binaryMessenger);
    boolean[] didCall = {false};
    api.echo(
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
    Everything everything = new Everything();
    everything.setAnInt(123L);
    Map<String, Object> map = everything.toMap();
    assertTrue(map.containsKey("anInt"));
    map.put("anInt", 123);
    Everything readEverything = Everything.fromMap(map);
    assertEquals(readEverything.getAnInt(), everything.getAnInt());
  }
}
