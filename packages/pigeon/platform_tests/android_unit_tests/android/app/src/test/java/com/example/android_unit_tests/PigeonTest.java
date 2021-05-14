// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.android_unit_tests;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import java.nio.ByteBuffer;
import java.util.Map;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class PigeonTest {
  private MessageCodec<Object> codec = StandardMessageCodec.INSTANCE;

  @Test
  public void toMapAndBack() {
    Pigeon.SetRequest request = new Pigeon.SetRequest();
    request.setValue(1234l);
    request.setState(Pigeon.LoadingState.complete);
    Map<String, Object> map = request.toMap();
    Pigeon.SetRequest readRequest = Pigeon.SetRequest.fromMap(map);
    assertEquals(request.getValue(), readRequest.getValue());
    assertEquals(request.getState(), readRequest.getState());
  }

  @Test
  public void toMapAndBackNested() {
    Pigeon.NestedRequest nested = new Pigeon.NestedRequest();
    Pigeon.SetRequest request = new Pigeon.SetRequest();
    request.setValue(1234l);
    request.setState(Pigeon.LoadingState.complete);
    nested.setRequest(request);
    Map<String, Object> map = nested.toMap();
    Pigeon.NestedRequest readNested = Pigeon.NestedRequest.fromMap(map);
    assertEquals(nested.getRequest().getValue(), readNested.getRequest().getValue());
    assertEquals(nested.getRequest().getState(), readNested.getRequest().getState());
  }

  @Test
  public void clearsHandler() {
    Pigeon.Api mockApi = mock(Pigeon.Api.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    Pigeon.Api.setup(binaryMessenger, mockApi);
    ArgumentCaptor<String> channelName = ArgumentCaptor.forClass(String.class);
    verify(binaryMessenger).setMessageHandler(channelName.capture(), isNotNull());
    Pigeon.Api.setup(binaryMessenger, null);
    verify(binaryMessenger).setMessageHandler(eq(channelName.getValue()), isNull());
  }

  /** Causes an exception in the handler by passing in null when a SetRequest is expected. */
  @Test
  public void errorMessage() {
    Pigeon.Api mockApi = mock(Pigeon.Api.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    Pigeon.Api.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger).setMessageHandler(anyString(), handler.capture());
    ByteBuffer message = codec.encodeMessage(null);
    handler
        .getValue()
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              Map<String, Object> wrapped = (Map<String, Object>) codec.decodeMessage(bytes);
              assertTrue(wrapped.containsKey("error"));
            });
  }

  @Test
  public void callsVoidMethod() {
    Pigeon.Api mockApi = mock(Pigeon.Api.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    Pigeon.Api.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger).setMessageHandler(anyString(), handler.capture());
    Pigeon.SetRequest request = new Pigeon.SetRequest();
    request.setValue(1234l);
    request.setState(Pigeon.LoadingState.complete);
    ByteBuffer message = codec.encodeMessage(request.toMap());
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
              assertNull(wrapped.get("result"));
            });
    ArgumentCaptor<Pigeon.SetRequest> receivedRequest =
        ArgumentCaptor.forClass(Pigeon.SetRequest.class);
    verify(mockApi).setValue(receivedRequest.capture());
    assertEquals(request.getValue(), receivedRequest.getValue().getValue());
  }
}
