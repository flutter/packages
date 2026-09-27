// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth

import android.app.Application
import android.content.Context
import android.os.Looper
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricPrompt.PromptInfo
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

// TODO(stuartmorgan): Add injectable BiometricPrompt factory, and AlertDialog factor, and add
// testing of the rest of the flows.
@RunWith(RobolectricTestRunner::class)
class AuthenticationHelperTest {
  @Test
  fun onAuthenticationError_returnsUserCanceled() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.USER_CANCELED, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsNegativeButton() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_NEGATIVE_BUTTON, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.NEGATIVE_BUTTON, result[0].code)
  }

  @Test
  fun onAuthenticationError_withoutDialogs_returnsNoCredential() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.NO_CREDENTIALS, result[0].code)
  }

  @Test
  fun onAuthenticationError_withoutDialogs_returnsNotEnrolledForNoBiometrics() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_BIOMETRICS, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.NOT_ENROLLED, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsHardwareUnavailable() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_UNAVAILABLE, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.HARDWARE_UNAVAILABLE, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsHardwareNotPresent() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_NOT_PRESENT, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.NO_HARDWARE, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsTemporaryLockoutForLockout() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.LOCKED_OUT_TEMPORARILY, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsPermanentLockoutForLockoutPermanent() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT_PERMANENT, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.LOCKED_OUT_PERMANENTLY, result[0].code)
  }

  @Test
  fun onAuthenticationError_withoutSticky_returnsSystemCanceled() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.SYSTEM_CANCELED, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsTimeout() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_TIMEOUT, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.TIMEOUT, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsNoSpace() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_SPACE, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.NO_SPACE, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsSecurityUpdateRequired() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.SECURITY_UPDATE_REQUIRED, result[0].code)
  }

  @Test
  fun onAuthenticationError_returnsUnknownForOtherCases() {
    val result = ArrayList<AuthResult>()
    val helper =
        AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock<FragmentActivity>()),
            defaultOptions,
            dummyStrings,
            { authResult -> result.add(authResult) },
            true)

    helper.onAuthenticationError(BiometricPrompt.ERROR_UNABLE_TO_PROCESS, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.UNKNOWN_ERROR, result[0].code)
  }

  @Test
  fun stopAuthentication_afterStickyResume_cancelsResumedPrompt() {
    // Regression test for https://github.com/flutter/flutter/issues/191804.
    Mockito.mockConstruction(BiometricPrompt::class.java).use { prompts ->
      val helper = buildStickyHelper()
      val owner = mock<LifecycleOwner>()

      helper.authenticate()
      helper.onPause(owner)
      helper.onResume(owner)
      shadowOf(Looper.getMainLooper()).idle()
      helper.stopAuthentication()

      Assert.assertEquals(2, prompts.constructed().size)
      verify(prompts.constructed()[1]).authenticate(any<PromptInfo>())
      verify(prompts.constructed()[1]).cancelAuthentication()
    }
  }

  @Test
  fun stopAuthentication_beforeResumedPromptIsShown_doesNotShowIt() {
    // Regression test for https://github.com/flutter/flutter/issues/191804.
    Mockito.mockConstruction(BiometricPrompt::class.java).use { prompts ->
      val lifecycle = mock<Lifecycle>()
      val helper = buildStickyHelper(lifecycle)
      val owner = mock<LifecycleOwner>()

      helper.authenticate()
      helper.onPause(owner)
      helper.onResume(owner)
      helper.stopAuthentication()
      shadowOf(Looper.getMainLooper()).idle()

      Assert.assertEquals(2, prompts.constructed().size)
      verify(prompts.constructed()[1], never()).authenticate(any<PromptInfo>())
      verify(lifecycle).removeObserver(helper)
    }
  }

  @Test
  fun stopAuthentication_whilePaused_stopsListeningForResume() {
    // Regression test for https://github.com/flutter/flutter/issues/191804.
    Mockito.mockConstruction(BiometricPrompt::class.java).use {
      val lifecycle = mock<Lifecycle>()
      val helper = buildStickyHelper(lifecycle)

      helper.authenticate()
      helper.onPause(mock<LifecycleOwner>())
      helper.stopAuthentication()

      // The cancel error is ignored while paused, so without this the next resume would show a
      // prompt that can no longer be canceled.
      verify(lifecycle).removeObserver(helper)
    }
  }

  private fun buildStickyHelper(lifecycle: Lifecycle = mock<Lifecycle>()): AuthenticationHelper {
    return AuthenticationHelper(
        lifecycle,
        buildMockActivityWithContext(mock<FragmentActivity>()),
        AuthOptions(biometricOnly = false, sensitiveTransaction = false, sticky = true),
        dummyStrings,
        {},
        true)
  }

  private fun buildMockActivityWithContext(mockActivity: FragmentActivity): FragmentActivity {
    val mockApplication = mock<Application>()
    val mockContext = mock<Context>()
    whenever(mockActivity.baseContext).thenReturn(mockContext)
    whenever(mockActivity.applicationContext).thenReturn(mockContext)
    whenever(mockActivity.application).thenReturn(mockApplication)
    return mockActivity
  }

  companion object {
    val dummyStrings: AuthStrings = AuthStrings("a reason", "a hint", "cancel", "sign in")

    val defaultOptions: AuthOptions =
        AuthOptions(biometricOnly = false, sensitiveTransaction = false, sticky = false)
  }
}
