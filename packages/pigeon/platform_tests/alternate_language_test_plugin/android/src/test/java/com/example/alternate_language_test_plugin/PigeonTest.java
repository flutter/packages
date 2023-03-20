// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import com.example.alternate_language_test_plugin.CoreTests.HostSmallApi;
import io.flutter.plugin.common.BinaryMessenger;
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
}
