// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.quickactions

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler
import io.flutter.plugin.common.BinaryMessenger.BinaryReply
import java.nio.ByteBuffer
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class QuickActionsTest {
  private class TestBinaryMessenger : BinaryMessenger {
    var launchActionCalled = false

    override fun send(channel: String, message: ByteBuffer?) {
      send(channel, message, null)
    }

    override fun send(channel: String, message: ByteBuffer?, callback: BinaryReply?) {
      if (channel.contains("launchAction")) {
        launchActionCalled = true
      }
    }

    override fun setMessageHandler(channel: String, handler: BinaryMessageHandler?) {
      // Do nothing.
    }
  }

  @Test
  fun canAttachToEngine() {
    val testBinaryMessenger = TestBinaryMessenger()
    val mockPluginBinding =
        mock<FlutterPluginBinding> { on { binaryMessenger } doReturn testBinaryMessenger }

    val plugin = QuickActionsPlugin()
    plugin.onAttachedToEngine(mockPluginBinding)
  }

  @Test
  fun onAttachedToActivity_buildVersionSupported_invokesLaunchMethod() {
    // Arrange
    val testBinaryMessenger = TestBinaryMessenger()
    val plugin = QuickActionsPlugin { version -> SUPPORTED_BUILD >= version }
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin)
    val mockIntent = createMockIntentWithQuickActionExtra()
    val mockMainActivity = mock<Activity> { on { intent } doReturn mockIntent }
    val mockActivityPluginBinding =
        mock<ActivityPluginBinding> { on { activity } doReturn mockMainActivity }
    val mockContext = mock<Context>()
    whenever(mockMainActivity.applicationContext).thenReturn(mockContext)

    // Act
    plugin.onAttachedToActivity(mockActivityPluginBinding)

    // Assert
    assertTrue(testBinaryMessenger.launchActionCalled)
  }

  @Test
  fun onNewIntent_buildVersionUnsupported_doesNotInvokeMethod() {
    // Arrange
    val testBinaryMessenger = TestBinaryMessenger()
    val plugin = QuickActionsPlugin { version -> UNSUPPORTED_BUILD >= version }
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin)
    val mockIntent = createMockIntentWithQuickActionExtra()

    // Act
    val onNewIntentReturn = plugin.onNewIntent(mockIntent)

    // Assert
    assertFalse(testBinaryMessenger.launchActionCalled)
    assertFalse(onNewIntentReturn)
  }

  @Test
  fun onNewIntent_buildVersionSupported_invokesLaunchMethod() {
    // Arrange
    val testBinaryMessenger = TestBinaryMessenger()
    val plugin = QuickActionsPlugin { version -> SUPPORTED_BUILD >= version }
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin)
    val mockIntent = createMockIntentWithQuickActionExtra()
    val mockMainActivity = mock<Activity> { on { intent } doReturn mockIntent }
    val mockActivityPluginBinding =
        mock<ActivityPluginBinding> { on { activity } doReturn mockMainActivity }
    val mockContext = mock<Context>()
    whenever(mockMainActivity.applicationContext).thenReturn(mockContext)
    plugin.onAttachedToActivity(mockActivityPluginBinding)

    // Act
    val onNewIntentReturn = plugin.onNewIntent(mockIntent)

    // Assert
    assertTrue(testBinaryMessenger.launchActionCalled)
    assertFalse(onNewIntentReturn)
  }

  private fun setUpMessengerAndFlutterPluginBinding(
      testBinaryMessenger: TestBinaryMessenger,
      plugin: QuickActionsPlugin
  ) {
    val mockPluginBinding =
        mock<FlutterPluginBinding> { on { binaryMessenger } doReturn testBinaryMessenger }
    plugin.onAttachedToEngine(mockPluginBinding)
  }

  private fun createMockIntentWithQuickActionExtra(): Intent = mock {
    on { hasExtra(QuickActions.EXTRA_ACTION) } doReturn true
    on { getStringExtra(QuickActions.EXTRA_ACTION) } doReturn SHORTCUT_TYPE
  }

  companion object {
    private const val SUPPORTED_BUILD = 25
    private const val UNSUPPORTED_BUILD = 24
    private const val SHORTCUT_TYPE = "action_one"
  }
}
