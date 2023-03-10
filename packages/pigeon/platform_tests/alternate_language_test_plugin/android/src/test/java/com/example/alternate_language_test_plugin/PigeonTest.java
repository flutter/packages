// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.CoreTests.HostSmallApi;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class PigeonTest {
  @Test
  public void clearsHandler() {
    HostSmallApi mockApi = mock(HostSmallApi.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    HostSmallApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<String> channelName = ArgumentCaptor.forClass(String.class);
    verify(binaryMessenger, atLeast(1)).setMessageHandler(channelName.capture(), isNotNull());
    HostSmallApi.setup(binaryMessenger, null);
    verify(binaryMessenger, atLeast(1)).setMessageHandler(eq(channelName.getValue()), isNull());
  }

  /** Causes an exception in the handler by passing in null when a non-null value is expected. */
  @Test
  public void errorMessage() {
    HostSmallApi mockApi = mock(HostSmallApi.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    HostSmallApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger, atLeast(1)).setMessageHandler(anyString(), handler.capture());
    MessageCodec<Object> codec = HostSmallApi.getCodec();
    ByteBuffer message = codec.encodeMessage(null);
    handler
        .getAllValues()
        .get(0) // "echo" is the first method.
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              ArrayList<Object> error = (ArrayList<Object>) codec.decodeMessage(bytes);
              assertNotNull(error.get(0));
              assertNotNull(error.get(1));
              String details = (String) error.get(2);
              assertTrue(details.contains("Cause:"));
              assertTrue(details.contains("Stacktrace:"));
            });
  }
}
