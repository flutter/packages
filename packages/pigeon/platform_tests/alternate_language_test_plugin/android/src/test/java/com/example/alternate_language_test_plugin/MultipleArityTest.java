// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.MultipleArity.MultipleArityFlutterApi;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import org.junit.Test;

public class MultipleArityTest {
  @Test
  public void subtract() {
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              ArrayList<Object> args =
                  (ArrayList<Object>) MultipleArityFlutterApi.getCodec().decodeMessage(message);
              Long arg0 = (Long) args.get(0);
              Long arg1 = (Long) args.get(1);
              ByteBuffer replyData = MultipleArityFlutterApi.getCodec().encodeMessage(arg0 - arg1);
              replyData.position(0);
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());

    MultipleArityFlutterApi api = new MultipleArityFlutterApi(binaryMessenger);
    api.subtract(
        30L,
        20L,
        (Long result) -> {
          assertEquals(10L, (long) result);
        });
  }
}
