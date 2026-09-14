// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth

import android.app.Activity
import android.app.KeyguardManager
import android.app.NativeActivity
import android.content.Context
import androidx.biometric.BiometricManager
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentCaptor
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class LocalAuthTest {
  @Test
  fun authenticate_returnsErrorWhenAuthInProgress() {
    val plugin = LocalAuthPlugin()
    plugin.authInProgress.set(true)
    val callbackCalled = ArrayList<Boolean>()
    plugin.authenticate(defaultOptions, dummyStrings) { reply: Result<AuthResult> ->
      callbackCalled.add(true)
      Assert.assertEquals(AuthResultCode.ALREADY_IN_PROGRESS, reply.getOrNull()?.code)
    }
    Assert.assertTrue(callbackCalled[0])
  }

  @Test
  fun authenticate_returnsErrorWithNoForegroundActivity() {
    val plugin = LocalAuthPlugin()
    val callbackCalled = ArrayList<Boolean>()

    plugin.authenticate(defaultOptions, dummyStrings) { reply: Result<AuthResult> ->
      callbackCalled.add(true)
      Assert.assertEquals(AuthResultCode.NO_ACTIVITY, reply.getOrNull()?.code)
    }
    Assert.assertTrue(callbackCalled[0])
  }

  @Test
  fun authenticate_returnsErrorWhenActivityNotFragmentActivity() {
    val plugin = LocalAuthPlugin()
    setPluginActivity(
        plugin, buildMockActivityWithContext(Mockito.mock(NativeActivity::class.java)))
    val callbackCalled = ArrayList<Boolean>()
    plugin.authenticate(defaultOptions, dummyStrings) { reply: Result<AuthResult> ->
      callbackCalled.add(true)
      Assert.assertEquals(AuthResultCode.NOT_FRAGMENT_ACTIVITY, reply.getOrNull()?.code)
    }
    Assert.assertTrue(callbackCalled[0])
  }

  @Test
  fun authenticate_returnsErrorWhenDeviceNotSupported() {
    val plugin = LocalAuthPlugin()
    setPluginActivity(
        plugin, buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)))
    val callbackCalled = ArrayList<Boolean>()

    plugin.authenticate(defaultOptions, dummyStrings) { reply: Result<AuthResult> ->
      callbackCalled.add(true)
      Assert.assertEquals(AuthResultCode.NO_CREDENTIALS, reply.getOrNull()?.code)
    }
    Assert.assertTrue(callbackCalled[0])
  }

  @Test
  fun authenticate_properlyConfiguresBiometricOnlyAuthenticationRequest() {
    val plugin = Mockito.spy(LocalAuthPlugin())
    val activity =
        buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)) as FragmentActivity
    setPluginActivity(plugin, activity)
    Mockito.`when`<Boolean?>(plugin.isDeviceSupported()).thenReturn(true)

    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    plugin.setBiometricManager(mockBiometricManager)

    val allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean::class.java)
    Mockito.doNothing()
        .`when`(plugin)
        .sendAuthenticationRequest(
            any(), any(), allowCredentialsCaptor.capture(), eq(activity), any())
    val options = AuthOptions(biometricOnly = true, sensitiveTransaction = false, sticky = false)

    plugin.authenticate(options, dummyStrings) {}
    Assert.assertFalse(allowCredentialsCaptor.getValue())
  }

  @Test
  @Config(sdk = [30])
  fun authenticate_properlyConfiguresBiometricAndDeviceCredentialAuthenticationRequest() {
    val plugin = Mockito.spy(LocalAuthPlugin())
    val activity =
        buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)) as FragmentActivity
    setPluginActivity(plugin, activity)
    Mockito.`when`<Boolean?>(plugin.isDeviceSupported()).thenReturn(true)

    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    plugin.setBiometricManager(mockBiometricManager)

    val allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean::class.java)
    Mockito.doNothing()
        .`when`(plugin)
        .sendAuthenticationRequest(
            any(), any(), allowCredentialsCaptor.capture()!!, eq(activity), any())
    plugin.authenticate(defaultOptions, dummyStrings) {}
    Assert.assertTrue(allowCredentialsCaptor.getValue())
  }

  @Test
  @Config(sdk = [30])
  fun authenticate_properlyConfiguresDeviceCredentialOnlyAuthenticationRequest() {
    val plugin = Mockito.spy(LocalAuthPlugin())
    val activity =
        buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)) as FragmentActivity
    setPluginActivity(plugin, activity)
    Mockito.`when`<Boolean?>(plugin.isDeviceSupported()).thenReturn(true)

    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    plugin.setBiometricManager(mockBiometricManager)

    val allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean::class.java)
    Mockito.doNothing()
        .`when`(plugin)
        .sendAuthenticationRequest(
            any(), any(), allowCredentialsCaptor.capture()!!, eq(activity), any())
    plugin.authenticate(defaultOptions, dummyStrings) {}
    Assert.assertTrue(allowCredentialsCaptor.getValue())
  }

  @Test
  fun isDeviceSupportedReturnsFalse() {
    val plugin = LocalAuthPlugin()
    Assert.assertFalse(plugin.isDeviceSupported())
  }

  @Test
  fun deviceCanSupportBiometrics_returnsTrueForPresentNonEnrolledBiometrics() {
    val plugin = LocalAuthPlugin()
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED)
    plugin.setBiometricManager(mockBiometricManager)

    Assert.assertTrue(plugin.deviceCanSupportBiometrics())
  }

  @Test
  fun deviceSupportsBiometrics_returnsTrueForPresentEnrolledBiometrics() {
    val plugin = LocalAuthPlugin()
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    plugin.setBiometricManager(mockBiometricManager)

    Assert.assertTrue(plugin.deviceCanSupportBiometrics())
  }

  @Test
  fun deviceSupportsBiometrics_returnsFalseForNoBiometricHardware() {
    val plugin = LocalAuthPlugin()
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE)
    plugin.setBiometricManager(mockBiometricManager)

    Assert.assertFalse(plugin.deviceCanSupportBiometrics())
  }

  @Test
  fun deviceSupportsBiometrics_returnsFalseForNullBiometricManager() {
    val plugin = LocalAuthPlugin()
    plugin.setBiometricManager(null)

    Assert.assertFalse(plugin.deviceCanSupportBiometrics())
  }

  @Test
  fun onDetachedFromActivity_ShouldReleaseActivity() {
    val mockActivity = Mockito.mock(Activity::class.java)
    val mockActivityBinding = Mockito.mock(ActivityPluginBinding::class.java)
    Mockito.`when`<Activity?>(mockActivityBinding.activity).thenReturn(mockActivity)

    val mockContext = Mockito.mock(Context::class.java)
    Mockito.`when`<Context?>(mockActivity.baseContext).thenReturn(mockContext)
    Mockito.`when`<Context?>(mockActivity.applicationContext).thenReturn(mockContext)

    val mockLifecycleReference = Mockito.mock(HiddenLifecycleReference::class.java)
    Mockito.`when`<Any?>(mockActivityBinding.lifecycle).thenReturn(mockLifecycleReference)

    val mockLifecycle = Mockito.mock(Lifecycle::class.java)
    Mockito.`when`<Lifecycle?>(mockLifecycleReference.lifecycle).thenReturn(mockLifecycle)

    val mockPluginBinding = Mockito.mock(FlutterPluginBinding::class.java)
    val mockMessenger = Mockito.mock(BinaryMessenger::class.java)
    Mockito.`when`<BinaryMessenger?>(mockPluginBinding.binaryMessenger).thenReturn(mockMessenger)

    val plugin = LocalAuthPlugin()
    plugin.onAttachedToEngine(mockPluginBinding)
    plugin.onAttachedToActivity(mockActivityBinding)
    Assert.assertNotNull(plugin.activity)

    plugin.onDetachedFromActivity()
    Assert.assertNull(plugin.activity)
  }

  @Test
  fun getEnrolledBiometrics_shouldReturnNullForNoActivity() {
    val plugin = LocalAuthPlugin()

    val enrolled: List<AuthClassification>? = plugin.getEnrolledBiometrics()
    Assert.assertNull(enrolled)
  }

  @Test
  fun getEnrolledBiometrics_shouldReturnEmptyList_withoutHardwarePresent() {
    val plugin = LocalAuthPlugin()
    setPluginActivity(plugin, buildMockActivityWithContext(Mockito.mock(Activity::class.java)))
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(mockBiometricManager.canAuthenticate(any()))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE)
    plugin.setBiometricManager(mockBiometricManager)

    val enrolled: List<AuthClassification>? = plugin.getEnrolledBiometrics()
    Assert.assertTrue(enrolled!!.isEmpty())
  }

  @Test
  fun getEnrolledBiometrics_shouldReturnEmptyList_withNoMethodsEnrolled() {
    val plugin = LocalAuthPlugin()
    setPluginActivity(plugin, buildMockActivityWithContext(Mockito.mock(Activity::class.java)))
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(mockBiometricManager.canAuthenticate(any()))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED)
    plugin.setBiometricManager(mockBiometricManager)

    val enrolled: List<AuthClassification>? = plugin.getEnrolledBiometrics()
    Assert.assertTrue(enrolled!!.isEmpty())
  }

  @Test
  fun getEnrolledBiometrics_shouldOnlyAddEnrolledBiometrics() {
    val plugin = LocalAuthPlugin()
    setPluginActivity(plugin, buildMockActivityWithContext(Mockito.mock(Activity::class.java)))
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED)
    plugin.setBiometricManager(mockBiometricManager)

    val enrolled: List<AuthClassification>? = plugin.getEnrolledBiometrics()
    Assert.assertEquals(1, enrolled!!.size.toLong())
    Assert.assertEquals(AuthClassification.WEAK, enrolled[0])
  }

  @Test
  fun getEnrolledBiometrics_shouldAddStrongBiometrics() {
    val plugin = LocalAuthPlugin()
    setPluginActivity(plugin, buildMockActivityWithContext(Mockito.mock(Activity::class.java)))
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    plugin.setBiometricManager(mockBiometricManager)

    val enrolled: List<AuthClassification>? = plugin.getEnrolledBiometrics()
    Assert.assertEquals(2, enrolled!!.size.toLong())
    Assert.assertEquals(AuthClassification.WEAK, enrolled[0])
    Assert.assertEquals(AuthClassification.STRONG, enrolled[1])
  }

  @Test
  fun isDeviceSecure_returnsTrueIfDeviceIsSecure() {
    val plugin = LocalAuthPlugin()
    val mockKeyguardManager = Mockito.mock(KeyguardManager::class.java)
    plugin.setKeyguardManager(mockKeyguardManager)

    Mockito.`when`<Boolean?>(mockKeyguardManager.isDeviceSecure).thenReturn(true)
    Assert.assertTrue(plugin.isDeviceSecure)

    Mockito.`when`<Boolean?>(mockKeyguardManager.isDeviceSecure).thenReturn(false)
    Assert.assertFalse(plugin.isDeviceSecure)
  }

  @Test
  @Config(sdk = [30])
  fun canAuthenticateWithDeviceCredential_returnsTrueIfHasBiometricManagerSupportAboveApi30() {
    val plugin = LocalAuthPlugin()
    val mockBiometricManager = Mockito.mock(BiometricManager::class.java)
    plugin.setBiometricManager(mockBiometricManager)

    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS)
    Assert.assertTrue(plugin.canAuthenticateWithDeviceCredential())

    Mockito.`when`<Int?>(
            mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED)
    Assert.assertFalse(plugin.canAuthenticateWithDeviceCredential())
  }

  private fun buildMockActivityWithContext(mockActivity: Activity): Activity {
    val mockContext = Mockito.mock(Context::class.java)
    Mockito.`when`<Context?>(mockActivity.baseContext).thenReturn(mockContext)
    Mockito.`when`<Context?>(mockActivity.applicationContext).thenReturn(mockContext)
    return mockActivity
  }

  private fun setPluginActivity(plugin: LocalAuthPlugin, activity: Activity?) {
    val mockLifecycleReference = Mockito.mock(HiddenLifecycleReference::class.java)
    val mockPluginBinding = Mockito.mock(FlutterPluginBinding::class.java)
    val mockActivityBinding = Mockito.mock(ActivityPluginBinding::class.java)
    val mockMessenger = Mockito.mock(BinaryMessenger::class.java)
    Mockito.`when`<BinaryMessenger?>(mockPluginBinding.binaryMessenger).thenReturn(mockMessenger)
    Mockito.`when`<Activity?>(mockActivityBinding.activity).thenReturn(activity)
    Mockito.`when`<Any?>(mockActivityBinding.lifecycle).thenReturn(mockLifecycleReference)
    plugin.onAttachedToEngine(mockPluginBinding)
    plugin.onAttachedToActivity(mockActivityBinding)
  }

  companion object {
    val dummyStrings: AuthStrings = AuthStrings("a reason", "a hint", "cancel", "sign in")

    val defaultOptions: AuthOptions =
        AuthOptions(biometricOnly = false, sensitiveTransaction = false, sticky = false)
  }
}
