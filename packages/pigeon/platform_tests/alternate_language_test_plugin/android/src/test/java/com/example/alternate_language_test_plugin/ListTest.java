// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.CoreTests.FlutterSmallApi;
import com.example.alternate_language_test_plugin.CoreTests.TestMessage;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import org.junit.Test;

public class ListTest {
  @Test
  public void listInList() {
    TestMessage top = new TestMessage();
    TestMessage inside = new TestMessage();
    inside.setTestList(Arrays.asList(1, 2, 3));
    top.setTestList(Arrays.asList(inside));
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    doAnswer(
            invocation -> {
              ByteBuffer message = invocation.getArgument(1);
              BinaryMessenger.BinaryReply reply = invocation.getArgument(2);
              message.position(0);
              ArrayList args = (ArrayList) FlutterSmallApi.getCodec().decodeMessage(message);
              ByteBuffer replyData = FlutterSmallApi.getCodec().encodeMessage(args.get(0));
              replyData.position(0);
              reply.reply(replyData);
              return null;
            })
        .when(binaryMessenger)
        .send(anyString(), any(), any());
    FlutterSmallApi api = new FlutterSmallApi(binaryMessenger);
    boolean[] didCall = {false};
    api.echoWrappedList(
        top,
        (result) -> {
          didCall[0] = true;
          assertEquals(result.getTestList().size(), 1);
          assertTrue(result.getTestList().get(0) instanceof TestMessage);
          TestMessage readInside = (TestMessage) result.getTestList().get(0);
          assertEquals(readInside.getTestList().size(), 3);
        });
    assertTrue(didCall[0]);
  }
}
