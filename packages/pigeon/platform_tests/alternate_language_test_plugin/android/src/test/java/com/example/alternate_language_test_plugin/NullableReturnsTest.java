// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Map;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class NullableReturnsTest {
  @Test
  public void nullArgHostApi() {
    NullableReturns.NullableArgHostApi mockApi = mock(NullableReturns.NullableArgHostApi.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    NullableReturns.NullableArgHostApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger).setMessageHandler(anyString(), handler.capture());
    MessageCodec<Object> codec = NullableReturns.NullableArgHostApi.getCodec();
    ByteBuffer message =
        codec.encodeMessage(
            new ArrayList<Object>() {
              {
                add(null);
              }
            });
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
            });
  }

  @Test
  public void nullArgFlutterApi() {
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              ArrayList<Object> args =
                  (ArrayList<Object>)
                      NullableReturns.NullableArgFlutterApi.getCodec().decodeMessage(message);
              assertNull(args.get(0));
              ByteBuffer replyData =
                  NullableReturns.NullableArgFlutterApi.getCodec().encodeMessage(args.get(0));
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    NullableReturns.NullableArgFlutterApi api =
        new NullableReturns.NullableArgFlutterApi(binaryMessenger);
    boolean[] didCall = {false};
    api.doit(
        null,
        (Long result) -> {
          didCall[0] = true;
          assertNull(result);
        });
    assertTrue(didCall[0]);
  }
}
