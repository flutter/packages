// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth

import android.app.Application
import android.content.Context
import android.os.Looper
import android.view.View
import android.view.ViewTreeObserver
import android.view.Window
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import java.time.Duration
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.argumentCaptor
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
  fun onAuthenticationError_withSticky_returnsUserCanceledIfActivityHasFocus() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    whenever(activity.hasWindowFocus()).thenReturn(true)
    val helper = buildStickyHelper(activity, result)

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.USER_CANCELED, result[0].code)
  }

  @Test
  fun onAuthenticationError_withSticky_returnsUserCanceledWhenActivityRegainsFocus() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    val observer = mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")
    Assert.assertEquals(0, result.size)
    val listener = argumentCaptor<ViewTreeObserver.OnWindowFocusChangeListener>()
    verify(observer).addOnWindowFocusChangeListener(listener.capture())
    listener.firstValue.onWindowFocusChanged(true)

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.USER_CANCELED, result[0].code)
    verify(observer).removeOnWindowFocusChangeListener(listener.firstValue)
  }

  @Test
  fun onAuthenticationError_withSticky_ignoresUserCanceledWhilePaused() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    val observer = mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.onActivityPaused(activity)
    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")
    idlePastFocusTimeout()

    Assert.assertEquals(0, result.size)
    verify(observer, never()).addOnWindowFocusChangeListener(any())
  }

  @Test
  fun onAuthenticationError_withSticky_ignoresCanceledWhilePaused() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.onActivityPaused(activity)
    helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "")
    idlePastFocusTimeout()

    Assert.assertEquals(0, result.size)
  }

  @Test
  fun onAuthenticationError_withSticky_ignoresUserCanceledFollowedByPause() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    val observer = mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")
    helper.onActivityPaused(activity)
    idlePastFocusTimeout()

    Assert.assertEquals(0, result.size)
    val listener = argumentCaptor<ViewTreeObserver.OnWindowFocusChangeListener>()
    verify(observer).addOnWindowFocusChangeListener(listener.capture())
    verify(observer).removeOnWindowFocusChangeListener(listener.firstValue)
  }

  @Test
  fun onAuthenticationError_withSticky_ignoresUserCanceledIfFocusDoesNotReturn() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    val observer = mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")
    idlePastFocusTimeout()

    Assert.assertEquals(0, result.size)
    verify(observer, never()).removeOnWindowFocusChangeListener(any())
  }

  @Test
  fun onAuthenticationError_withSticky_returnsUserCanceledIfActivityIsFinishing() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    whenever(activity.isFinishing).thenReturn(true)
    val observer = mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.USER_CANCELED, result[0].code)
    verify(observer, never()).addOnWindowFocusChangeListener(any())
  }

  @Test
  fun onAuthenticationError_withSticky_returnsCanceledImmediatelyAfterStopAuthentication() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    val observer = mockViewTreeObserver(activity)
    val helper = buildStickyHelper(activity, result)

    helper.stopAuthentication()
    helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.SYSTEM_CANCELED, result[0].code)
    verify(observer, never()).addOnWindowFocusChangeListener(any())
  }

  @Test
  fun onAuthenticationError_withSticky_returnsNegativeButtonImmediately() {
    val result = ArrayList<AuthResult>()
    val activity = buildMockActivityWithContext(mock<FragmentActivity>())
    val helper = buildStickyHelper(activity, result)

    helper.onAuthenticationError(BiometricPrompt.ERROR_NEGATIVE_BUTTON, "")

    Assert.assertEquals(1, result.size)
    Assert.assertEquals(AuthResultCode.NEGATIVE_BUTTON, result[0].code)
  }

  private fun buildStickyHelper(
      activity: FragmentActivity,
      result: ArrayList<AuthResult>
  ): AuthenticationHelper =
      AuthenticationHelper(
          null,
          activity,
          stickyOptions,
          dummyStrings,
          { authResult -> result.add(authResult) },
          true)

  private fun mockViewTreeObserver(activity: FragmentActivity): ViewTreeObserver {
    val window = mock<Window>()
    val decorView = mock<View>()
    val observer = mock<ViewTreeObserver>()
    whenever(activity.window).thenReturn(window)
    whenever(window.decorView).thenReturn(decorView)
    whenever(decorView.viewTreeObserver).thenReturn(observer)
    return observer
  }

  private fun idlePastFocusTimeout() {
    shadowOf(Looper.getMainLooper())
        .idleFor(Duration.ofMillis(AuthenticationHelper.FOCUS_RETURN_TIMEOUT_MS + 1))
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

    val stickyOptions: AuthOptions =
        AuthOptions(biometricOnly = false, sensitiveTransaction = false, sticky = true)
  }
}
