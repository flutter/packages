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
import java.util.Arrays;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class PigeonTest {
  @Test
  public void toListAndBack() {
    Pigeon.AndroidSetRequest request = new Pigeon.AndroidSetRequest();
    request.setValue(1234l);
    request.setState(Pigeon.AndroidLoadingState.COMPLETE);
    ArrayList<Object> list = request.toList();
    Pigeon.AndroidSetRequest readRequest = Pigeon.AndroidSetRequest.fromList(list);
    assertEquals(request.getValue(), readRequest.getValue());
    assertEquals(request.getState(), readRequest.getState());
  }

  @Test
  public void toListAndBackNested() {
    Pigeon.AndroidNestedRequest nested = new Pigeon.AndroidNestedRequest();
    Pigeon.AndroidSetRequest request = new Pigeon.AndroidSetRequest();
    request.setValue(1234l);
    request.setState(Pigeon.AndroidLoadingState.COMPLETE);
    nested.setRequest(request);
    ArrayList<Object> list = nested.toList();
    Pigeon.AndroidNestedRequest readNested = Pigeon.AndroidNestedRequest.fromList(list);
    assertEquals(nested.getRequest().getValue(), readNested.getRequest().getValue());
    assertEquals(nested.getRequest().getState(), readNested.getRequest().getState());
  }

  @Test
  public void clearsHandler() {
    Pigeon.AndroidApi mockApi = mock(Pigeon.AndroidApi.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    Pigeon.AndroidApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<String> channelName = ArgumentCaptor.forClass(String.class);
    verify(binaryMessenger).setMessageHandler(channelName.capture(), isNotNull());
    Pigeon.AndroidApi.setup(binaryMessenger, null);
    verify(binaryMessenger).setMessageHandler(eq(channelName.getValue()), isNull());
  }

  /** Causes an exception in the handler by passing in null when a AndroidSetRequest is expected. */
  @Test
  public void errorMessage() {
    Pigeon.AndroidApi mockApi = mock(Pigeon.AndroidApi.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    Pigeon.AndroidApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger).setMessageHandler(anyString(), handler.capture());
    MessageCodec<Object> codec = Pigeon.AndroidApi.getCodec();
    ByteBuffer message = codec.encodeMessage(null);
    handler
        .getValue()
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              ArrayList error = (ArrayList) codec.decodeMessage(bytes);
              assertNotNull(error.get(0));
              assertNotNull(error.get(1));
              String details = (String) error.get(2);
              assertTrue(details.contains("Cause:"));
              assertTrue(details.contains("Stacktrace:"));
            });
  }

  @Test
  public void callsVoidMethod() {
    Pigeon.AndroidApi mockApi = mock(Pigeon.AndroidApi.class);
    BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    Pigeon.AndroidApi.setup(binaryMessenger, mockApi);
    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
        ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(binaryMessenger).setMessageHandler(anyString(), handler.capture());
    Pigeon.AndroidSetRequest request = new Pigeon.AndroidSetRequest();
    request.setValue(1234l);
    request.setState(Pigeon.AndroidLoadingState.COMPLETE);
    MessageCodec<Object> codec = Pigeon.AndroidApi.getCodec();
    ByteBuffer message = codec.encodeMessage(new ArrayList<Object>(Arrays.asList(request)));
    message.rewind();
    handler
        .getValue()
        .onMessage(
            message,
            (bytes) -> {
              bytes.rewind();
              @SuppressWarnings("unchecked")
              ArrayList wrapped = (ArrayList) codec.decodeMessage(bytes);
              assertTrue(wrapped.size() == 1);
              assertNull(wrapped.get(0));
            });
    ArgumentCaptor<Pigeon.AndroidSetRequest> receivedRequest =
        ArgumentCaptor.forClass(Pigeon.AndroidSetRequest.class);
    verify(mockApi).setValue(receivedRequest.capture());
    assertEquals(request.getValue(), receivedRequest.getValue().getValue());
  }

  @Test
  public void encodeWithNullField() {
    Pigeon.AndroidNestedRequest request = new Pigeon.AndroidNestedRequest();
    request.setContext("hello");
    MessageCodec<Object> codec = Pigeon.AndroidNestedApi.getCodec();
    ByteBuffer message = codec.encodeMessage(request);
    assertNotNull(message);
  }
}
