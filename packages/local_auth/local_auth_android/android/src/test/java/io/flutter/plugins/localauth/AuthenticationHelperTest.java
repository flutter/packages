// Copyright 2013 The Flutter Authors. All rights reserved.
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
import io.flutter.plugins.localauth.Messages.AuthOptions;
import io.flutter.plugins.localauth.Messages.AuthResult;
import io.flutter.plugins.localauth.Messages.AuthStrings;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

// TODO(stuartmorgan): Add injectable BiometricPrompt factory, and AlertDialog factor, and add
// testing of the rest of the flows.

@RunWith(RobolectricTestRunner.class)
public class AuthenticationHelperTest {
  static final AuthStrings dummyStrings =
      new AuthStrings.Builder()
          .setReason("a reason")
          .setBiometricHint("a hint")
          .setBiometricNotRecognized("biometric not recognized")
          .setBiometricRequiredTitle("biometric required")
          .setCancelButton("cancel")
          .setDeviceCredentialsRequiredTitle("credentials required")
          .setDeviceCredentialsSetupDescription("credentials setup description")
          .setGoToSettingsButton("go")
          .setGoToSettingsDescription("go to settings description")
          .setSignInTitle("sign in")
          .build();

  static final AuthOptions defaultOptions =
      new AuthOptions.Builder()
          .setBiometricOnly(false)
          .setSensitiveTransaction(false)
          .setSticky(false)
          .setUseErrorDialgs(false)
          .build();

  @Test
  public void onAuthenticationError_withoutDialogs_returnsNotAvailableForNoCredential() {
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

    verify(handler).complete(AuthResult.ERROR_NOT_AVAILABLE);
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

    verify(handler).complete(AuthResult.ERROR_NOT_ENROLLED);
  }

  @Test
  public void onAuthenticationError_returnsNotAvailableForHardwareUnavailable() {
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

    verify(handler).complete(AuthResult.ERROR_NOT_AVAILABLE);
  }

  @Test
  public void onAuthenticationError_returnsNotAvailableForHardwareNotPresent() {
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

    verify(handler).complete(AuthResult.ERROR_NOT_AVAILABLE);
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

    verify(handler).complete(AuthResult.ERROR_LOCKED_OUT_TEMPORARILY);
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

    verify(handler).complete(AuthResult.ERROR_LOCKED_OUT_PERMANENTLY);
  }

  @Test
  public void onAuthenticationError_withoutSticky_returnsFailureForCanceled() {
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

    verify(handler).complete(AuthResult.FAILURE);
  }

  @Test
  public void onAuthenticationError_withoutSticky_returnsFailureForOtherCases() {
    final AuthCompletionHandler handler = mock(AuthCompletionHandler.class);
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            handler,
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_VENDOR, "");

    verify(handler).complete(AuthResult.FAILURE);
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
