// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.android_unit_tests;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.android_unit_tests.Primitive.PrimitiveFlutterApi;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.junit.Test;

public class PrimitiveTest {
  private static BinaryMessenger makeMockBinaryMessenger() {
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              reply.reply(message);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    return binaryMessenger;
  }

  @Test
  public void primitiveInt() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.anInt(
        1,
        (Integer result) -> {
          didCall[0] = true;
          assertEquals(result, (Integer) 1);
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveBool() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.aBool(
        true,
        (Boolean result) -> {
          didCall[0] = true;
          assertEquals(result, (Boolean) true);
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveString() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.aString(
        "hello",
        (String result) -> {
          didCall[0] = true;
          assertEquals(result, "hello");
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveDouble() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.aDouble(
        1.5,
        (Double result) -> {
          didCall[0] = true;
          assertEquals(result, 1.5, 0.01);
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveMap() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.aMap(
        Collections.singletonMap("hello", 1),
        (Map result) -> {
          didCall[0] = true;
          assertEquals(result, Collections.singletonMap("hello", 1));
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveList() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.aList(
        Collections.singletonList("hello"),
        (List result) -> {
          didCall[0] = true;
          assertEquals(result, Collections.singletonList("hello"));
        });
    assertTrue(didCall[0]);
  }
}
