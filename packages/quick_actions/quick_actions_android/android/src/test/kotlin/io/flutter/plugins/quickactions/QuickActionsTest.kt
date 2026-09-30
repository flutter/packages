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
import io.flutter.plugins.quickactions.QuickActionsPlugin.AndroidSdkChecker
import java.nio.ByteBuffer
import org.junit.Assert
import org.junit.Test
import org.mockito.Mockito

class QuickActionsTest {
  private class TestBinaryMessenger : BinaryMessenger {
    var launchActionCalled: Boolean = false

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
    val mockPluginBinding = Mockito.mock<FlutterPluginBinding>(FlutterPluginBinding::class.java)
    Mockito.`when`<BinaryMessenger?>(mockPluginBinding.getBinaryMessenger())
        .thenReturn(testBinaryMessenger)

    val plugin = QuickActionsPlugin()
    plugin.onAttachedToEngine(mockPluginBinding)
  }

  @Test
  @Throws(NoSuchFieldException::class, IllegalAccessException::class)
  fun onAttachedToActivity_buildVersionSupported_invokesLaunchMethod() {
    // Arrange
    val testBinaryMessenger = TestBinaryMessenger()
    val plugin =
        QuickActionsPlugin(AndroidSdkChecker { version: Int -> SUPPORTED_BUILD >= version })
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin)
    val mockIntent = createMockIntentWithQuickActionExtra()
    val mockMainActivity = Mockito.mock<Activity>(Activity::class.java)
    Mockito.`when`<Intent?>(mockMainActivity.getIntent()).thenReturn(mockIntent)
    val mockActivityPluginBinding =
        Mockito.mock<ActivityPluginBinding>(ActivityPluginBinding::class.java)
    Mockito.`when`<Activity?>(mockActivityPluginBinding.getActivity()).thenReturn(mockMainActivity)
    val mockContext = Mockito.mock<Context?>(Context::class.java)
    Mockito.`when`<Context?>(mockMainActivity.getApplicationContext()).thenReturn(mockContext)
    plugin.onAttachedToActivity(mockActivityPluginBinding)

    // Act
    plugin.onAttachedToActivity(mockActivityPluginBinding)

    // Assert
    Assert.assertTrue(testBinaryMessenger.launchActionCalled)
  }

  @Test
  fun onNewIntent_buildVersionUnsupported_doesNotInvokeMethod() {
    // Arrange
    val testBinaryMessenger = TestBinaryMessenger()
    val plugin =
        QuickActionsPlugin(AndroidSdkChecker { version: Int -> UNSUPPORTED_BUILD >= version })
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin)
    val mockIntent = createMockIntentWithQuickActionExtra()

    // Act
    val onNewIntentReturn = plugin.onNewIntent(mockIntent)

    // Assert
    Assert.assertFalse(testBinaryMessenger.launchActionCalled)
    Assert.assertFalse(onNewIntentReturn)
  }

  @Test
  fun onNewIntent_buildVersionSupported_invokesLaunchMethod() {
    // Arrange
    val testBinaryMessenger = TestBinaryMessenger()
    val plugin =
        QuickActionsPlugin(AndroidSdkChecker { version: Int -> SUPPORTED_BUILD >= version })
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin)
    val mockIntent = createMockIntentWithQuickActionExtra()
    val mockMainActivity = Mockito.mock<Activity>(Activity::class.java)
    Mockito.`when`<Intent?>(mockMainActivity.getIntent()).thenReturn(mockIntent)
    val mockActivityPluginBinding =
        Mockito.mock<ActivityPluginBinding>(ActivityPluginBinding::class.java)
    Mockito.`when`<Activity?>(mockActivityPluginBinding.getActivity()).thenReturn(mockMainActivity)
    val mockContext = Mockito.mock<Context?>(Context::class.java)
    Mockito.`when`<Context?>(mockMainActivity.getApplicationContext()).thenReturn(mockContext)
    plugin.onAttachedToActivity(mockActivityPluginBinding)

    // Act
    val onNewIntentReturn = plugin.onNewIntent(mockIntent)

    // Assert
    Assert.assertTrue(testBinaryMessenger.launchActionCalled)
    Assert.assertFalse(onNewIntentReturn)
  }

  private fun setUpMessengerAndFlutterPluginBinding(
      testBinaryMessenger: TestBinaryMessenger?,
      plugin: QuickActionsPlugin
  ) {
    val mockPluginBinding = Mockito.mock<FlutterPluginBinding>(FlutterPluginBinding::class.java)
    Mockito.`when`<BinaryMessenger?>(mockPluginBinding.getBinaryMessenger())
        .thenReturn(testBinaryMessenger)
    plugin.onAttachedToEngine(mockPluginBinding)
  }

  private fun createMockIntentWithQuickActionExtra(): Intent {
    val mockIntent = Mockito.mock<Intent>(Intent::class.java)
    Mockito.`when`<Boolean?>(mockIntent.hasExtra(QuickActions.EXTRA_ACTION)).thenReturn(true)
    Mockito.`when`<String?>(mockIntent.getStringExtra(QuickActions.EXTRA_ACTION))
        .thenReturn(SHORTCUT_TYPE)
    return mockIntent
  }

  companion object {
    const val SUPPORTED_BUILD: Int = 25
    const val UNSUPPORTED_BUILD: Int = 24
    const val SHORTCUT_TYPE: String = "action_one"
  }
}
