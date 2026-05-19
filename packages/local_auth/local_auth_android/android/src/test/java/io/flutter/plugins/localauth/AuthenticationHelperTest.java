// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Application;
import android.content.Context;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

// TODO(stuartmorgan): Add injectable BiometricPrompt factory, and AlertDialog factor, and add
// testing of the rest of the flows.

@RunWith(RobolectricTestRunner.class)
public class AuthenticationHelperTest {
  static final AuthStrings dummyStrings =
      new AuthStrings("a reason", "a hint", "cancel", "sign in");

  static final AuthOptions defaultOptions =
      new AuthOptions(
          /* biometricOnly */ false, /* sensitiveTransaction */ false, /* sticky */ false);

  @Test
  public void onAuthenticationError_returnsUserCanceled() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "");

    verify(handler).complete(new AuthResult(AuthResultCode.USER_CANCELED, ""));
  }

  @Test
  public void onAuthenticationError_returnsNegativeButton() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NEGATIVE_BUTTON, "");

    verify(handler).complete(new AuthResult(AuthResultCode.NEGATIVE_BUTTON, ""));
  }

  @Test
  public void onAuthenticationError_withoutDialogs_returnsNoCredential() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL, "");

    verify(handler).complete(new AuthResult(AuthResultCode.NO_CREDENTIALS, ""));
  }

  @Test
  public void onAuthenticationError_withoutDialogs_returnsNotEnrolledForNoBiometrics() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_BIOMETRICS, "");

    verify(handler).complete(new AuthResult(AuthResultCode.NOT_ENROLLED, ""));
  }

  @Test
  public void onAuthenticationError_returnsHardwareUnavailable() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_UNAVAILABLE, "");

    verify(handler).complete(new AuthResult(AuthResultCode.HARDWARE_UNAVAILABLE, ""));
  }

  @Test
  public void onAuthenticationError_returnsHardwareNotPresent() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_NOT_PRESENT, "");

    verify(handler).complete(new AuthResult(AuthResultCode.NO_HARDWARE, ""));
  }

  @Test
  public void onAuthenticationError_returnsTemporaryLockoutForLockout() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT, "");

    verify(handler).complete(new AuthResult(AuthResultCode.LOCKED_OUT_TEMPORARILY, ""));
  }

  @Test
  public void onAuthenticationError_returnsPermanentLockoutForLockoutPermanent() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT_PERMANENT, "");

    verify(handler).complete(new AuthResult(AuthResultCode.LOCKED_OUT_PERMANENTLY, ""));
  }

  @Test
  public void onAuthenticationError_withoutSticky_returnsSystemCanceled() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "");

    verify(handler).complete(new AuthResult(AuthResultCode.SYSTEM_CANCELED, ""));
  }

  @Test
  public void onAuthenticationError_returnsTimeout() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_TIMEOUT, "");

    verify(handler).complete(new AuthResult(AuthResultCode.TIMEOUT, ""));
  }

  @Test
  public void onAuthenticationError_returnsNoSpace() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_SPACE, "");

    verify(handler).complete(new AuthResult(AuthResultCode.NO_SPACE, ""));
  }

  @Test
  public void onAuthenticationError_returnsSecurityUpdateRequired() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED, "");

    verify(handler).complete(new AuthResult(AuthResultCode.SECURITY_UPDATE_REQUIRED, ""));
  }

  @Test
  public void onAuthenticationError_returnsUnknownForOtherCases() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_UNABLE_TO_PROCESS, "");

    verify(handler).complete(new AuthResult(AuthResultCode.UNKNOWN_ERROR, ""));
  }

  private FragmentActivity buildMockActivityWithContext(FragmentActivity mockActivity) {
    final Application mockApplication = mock(Application.class);
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    when(mockActivity.getApplication()).thenReturn(mockApplication);
    return mockActivity;
  }
}
