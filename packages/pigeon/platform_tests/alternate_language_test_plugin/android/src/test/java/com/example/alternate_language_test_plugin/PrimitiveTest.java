// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.Primitive.PrimitiveFlutterApi;
import com.example.alternate_language_test_plugin.Primitive.PrimitiveHostApi;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class PrimitiveTest {
  private static BinaryMessenger makeMockBinaryMessenger() {
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              ArrayList<Object> args =
                  (ArrayList<Object>) PrimitiveFlutterApi.getCodec().decodeMessage(message);
              Object arg = args.get(0);
              if (arg instanceof Long) {
                Long longArg = (Long) arg;
                if (longArg.intValue() == longArg.longValue()) {
                  // Value fits in the Integer so gets sent as such
                  // https://docs.flutter.dev/development/platform-integration/platform-channels?tab=type-mappings-java-tab#codec
                  arg = Integer.valueOf(longArg.intValue());
                }
              }
              ByteBuffer replyData = PrimitiveFlutterApi.getCodec().encodeMessage(arg);
              replyData.position(0);
              reply.reply(replyData);
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
        1L,
        (Long result) -> {
          didCall[0] = true;
          assertEquals(result, (Long) 1L);
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveLongInt() {
    BinaryMessenger binaryMessenger = makeMockBinaryMessenger();
    PrimitiveFlutterApi api = new PrimitiveFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.anInt(
        1L << 50,
        (Long result) -> {
          didCall[0] = true;
          assertEquals(result.longValue(), 1L << 50);
        });
    assertTrue(didCall[0]);
  }

  @Test
  public void primitiveIntHostApi() {
    PrimitiveHostApi mockApi = mock(PrimitiveHostApi.class);
    when(mockApi.anInt(1L)).thenReturn(1L);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    PrimitiveHostApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger)
        .setMessageHandler(eq("dev.flutter.pigeon.PrimitiveHostApi.anInt"), handler.capture());
    MessageCodec<Object> codec = PrimitiveHostApi.getCodec();
    ByteBuffer message = codec.encodeMessage(new ArrayList<Object>(Arrays.asList((Integer) 1)));
    message.rewind();
    handler
        .getValue()
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              Map<String, Object> wrapped = (Map<String, Object>) codec.decodeMessage(bytes);
              assertTrue(wrapped.containsKey("result"));
              assertEquals(1L, ((Long) wrapped.get("result")).longValue());
            });
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
        (Map<Object, Object> result) -> {
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
        (List<Object> result) -> {
          didCall[0] = true;
          assertEquals(result, Collections.singletonList("hello"));
        });
    assertTrue(didCall[0]);
  }
}
