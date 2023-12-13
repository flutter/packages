// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.HttpAuthHandler;
import io.flutter.plugin.common.BinaryMessenger;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class HttpAuthHandlerTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock HttpAuthHandler mockAuthHandler;

  @Mock BinaryMessenger mockBinaryMessenger;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void proceed() {
    final HttpAuthHandlerHostApiImpl hostApi =
        new HttpAuthHandlerHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 65L;
    final String username = "username";
    final String password = "password";
    instanceManager.addDartCreatedInstance(mockAuthHandler, instanceIdentifier);

    hostApi.proceed(instanceIdentifier, username, password);

    verify(mockAuthHandler).proceed(eq(username), eq(password));
  }

  @Test
  public void cancel() {
    final HttpAuthHandlerHostApiImpl hostApi =
        new HttpAuthHandlerHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 65L;
    instanceManager.addDartCreatedInstance(mockAuthHandler, instanceIdentifier);

    hostApi.cancel(instanceIdentifier);

    verify(mockAuthHandler).cancel();
  }

  @Test
  public void useHttpAuthUsernamePassword() {
    final HttpAuthHandlerHostApiImpl hostApi =
        new HttpAuthHandlerHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 65L;
    instanceManager.addDartCreatedInstance(mockAuthHandler, instanceIdentifier);

    hostApi.useHttpAuthUsernamePassword(instanceIdentifier);

    verify(mockAuthHandler).useHttpAuthUsernamePassword();
  }
}
