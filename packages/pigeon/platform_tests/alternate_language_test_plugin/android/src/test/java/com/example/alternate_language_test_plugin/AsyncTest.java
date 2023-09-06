// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import androidx.annotation.NonNull;
import com.example.alternate_language_test_plugin.CoreTests.*;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class AsyncTest {
  class Success implements HostSmallApi {
    @Override
    public void echo(@NonNull String value, Result<String> result) {
      result.success(value);
    }

    @Override
    public void voidVoid(Result<Void> result) {
      result.success(null);
    }
  }

  class Error implements HostSmallApi {
    @Override
    public void echo(@NonNull String value, Result<String> result) {
      result.error(new Exception("error"));
    }

    @Override
    public void voidVoid(Result<Void> result) {
      result.error(new Exception("error"));
    }
  }

  @Test
  public void asyncSuccess() {
    Success api = new Success();
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    HostSmallApi.setup(binaryMessenger, api);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger)
        .setMessageHandler(
            eq("dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.echo"), any());
    verify(binaryMessenger)
        .setMessageHandler(
            eq("dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.voidVoid"),
            handler.capture());
    MessageCodec<Object> codec = HostSmallApi.getCodec();
    ByteBuffer message = codec.encodeMessage(null);
    Boolean[] didCall = {false};
    handler
        .getValue()
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              ArrayList<Object> wrapped = (ArrayList<Object>) codec.decodeMessage(bytes);
              assertTrue(wrapped.size() == 1);
              didCall[0] = true;
            });
    assertTrue(didCall[0]);
  }

  @Test
  public void asyncError() {
    Error api = new Error();
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    HostSmallApi.setup(binaryMessenger, api);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger)
        .setMessageHandler(
            eq("dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.echo"), any());
    verify(binaryMessenger)
        .setMessageHandler(
            eq("dev.flutter.pigeon.pigeon_integration_tests.HostSmallApi.voidVoid"),
            handler.capture());
    MessageCodec<Object> codec = HostSmallApi.getCodec();
    ByteBuffer message = codec.encodeMessage(null);
    Boolean[] didCall = {false};
    handler
        .getValue()
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              ArrayList<Object> wrapped = (ArrayList<Object>) codec.decodeMessage(bytes);
              assertTrue(wrapped.size() > 1);
              assertEquals("java.lang.Exception: error", (String) wrapped.get(0));
              didCall[0] = true;
            });
    assertTrue(didCall[0]);
  }
}
