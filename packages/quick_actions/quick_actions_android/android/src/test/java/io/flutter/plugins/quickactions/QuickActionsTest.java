// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import static io.flutter.plugins.quickactions.QuickActions.EXTRA_ACTION;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;
import org.junit.Test;

public class QuickActionsTest {
  private static class TestBinaryMessenger implements BinaryMessenger {
    public boolean launchActionCalled;

    @Override
    public void send(@NonNull String channel, @Nullable ByteBuffer message) {
      send(channel, message, null);
    }

    @Override
    public void send(
        @NonNull String channel,
        @Nullable ByteBuffer message,
        @Nullable final BinaryReply callback) {
      if (channel.contains("launchAction")) {
        launchActionCalled = true;
      }
    }

    @Override
    public void setMessageHandler(@NonNull String channel, @Nullable BinaryMessageHandler handler) {
      // Do nothing.
    }
  }

  static final int SUPPORTED_BUILD = 25;
  static final int UNSUPPORTED_BUILD = 24;
  static final String SHORTCUT_TYPE = "action_one";

  @Test
  public void canAttachToEngine() {
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(testBinaryMessenger);

    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    plugin.onAttachedToEngine(mockPluginBinding);
  }

  @Test
  public void onAttachedToActivity_buildVersionSupported_invokesLaunchMethod()
      throws NoSuchFieldException, IllegalAccessException {
    // Arrange
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final QuickActionsPlugin plugin =
        new QuickActionsPlugin((version) -> SUPPORTED_BUILD >= version);
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin);
    final Intent mockIntent = createMockIntentWithQuickActionExtra();
    final Activity mockMainActivity = mock(Activity.class);
    when(mockMainActivity.getIntent()).thenReturn(mockIntent);
    final ActivityPluginBinding mockActivityPluginBinding = mock(ActivityPluginBinding.class);
    when(mockActivityPluginBinding.getActivity()).thenReturn(mockMainActivity);
    final Context mockContext = mock(Context.class);
    when(mockMainActivity.getApplicationContext()).thenReturn(mockContext);
    plugin.onAttachedToActivity(mockActivityPluginBinding);

    // Act
    plugin.onAttachedToActivity(mockActivityPluginBinding);

    // Assert
    assertTrue(testBinaryMessenger.launchActionCalled);
  }

  @Test
  public void onNewIntent_buildVersionUnsupported_doesNotInvokeMethod() {
    // Arrange
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final QuickActionsPlugin plugin =
        new QuickActionsPlugin((version) -> UNSUPPORTED_BUILD >= version);
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin);
    final Intent mockIntent = createMockIntentWithQuickActionExtra();

    // Act
    final boolean onNewIntentReturn = plugin.onNewIntent(mockIntent);

    // Assert
    assertFalse(testBinaryMessenger.launchActionCalled);
    assertFalse(onNewIntentReturn);
  }

  @Test
  public void onNewIntent_buildVersionSupported_invokesLaunchMethod() {
    // Arrange
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final QuickActionsPlugin plugin =
        new QuickActionsPlugin((version) -> SUPPORTED_BUILD >= version);
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin);
    final Intent mockIntent = createMockIntentWithQuickActionExtra();
    final Activity mockMainActivity = mock(Activity.class);
    when(mockMainActivity.getIntent()).thenReturn(mockIntent);
    final ActivityPluginBinding mockActivityPluginBinding = mock(ActivityPluginBinding.class);
    when(mockActivityPluginBinding.getActivity()).thenReturn(mockMainActivity);
    final Context mockContext = mock(Context.class);
    when(mockMainActivity.getApplicationContext()).thenReturn(mockContext);
    plugin.onAttachedToActivity(mockActivityPluginBinding);

    // Act
    final boolean onNewIntentReturn = plugin.onNewIntent(mockIntent);

    // Assert
    assertTrue(testBinaryMessenger.launchActionCalled);
    assertFalse(onNewIntentReturn);
  }

  private void setUpMessengerAndFlutterPluginBinding(
      TestBinaryMessenger testBinaryMessenger, QuickActionsPlugin plugin) {
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(testBinaryMessenger);
    plugin.onAttachedToEngine(mockPluginBinding);
  }

  private Intent createMockIntentWithQuickActionExtra() {
    final Intent mockIntent = mock(Intent.class);
    when(mockIntent.hasExtra(EXTRA_ACTION)).thenReturn(true);
    when(mockIntent.getStringExtra(EXTRA_ACTION)).thenReturn(QuickActionsTest.SHORTCUT_TYPE);
    return mockIntent;
  }
}
