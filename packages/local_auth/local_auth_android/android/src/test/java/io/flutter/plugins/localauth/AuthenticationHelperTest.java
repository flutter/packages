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
import io.flutter.plugins.localauth.Messages.AuthOptions;
import io.flutter.plugins.localauth.Messages.AuthResult;
import io.flutter.plugins.localauth.Messages.AuthResultCode;
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
          .setSignInHint("a hint")
          .setCancelButton("cancel")
          .setSignInTitle("sign in")
          .build();

  static final AuthOptions defaultOptions =
      new AuthOptions.Builder()
          .setBiometricOnly(false)
          .setSensitiveTransaction(false)
          .setSticky(false)
          .build();

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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.USER_CANCELED)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.NEGATIVE_BUTTON)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.NO_CREDENTIALS)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.NOT_ENROLLED)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.HARDWARE_UNAVAILABLE)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.NO_HARDWARE)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.LOCKED_OUT_TEMPORARILY)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.LOCKED_OUT_PERMANENTLY)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.SYSTEM_CANCELED)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder().setCode(AuthResultCode.TIMEOUT).setErrorMessage("").build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder().setCode(AuthResultCode.NO_SPACE).setErrorMessage("").build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.SECURITY_UPDATE_REQUIRED)
                .setErrorMessage("")
                .build());
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

    verify(handler)
        .complete(
            new AuthResult.Builder()
                .setCode(AuthResultCode.UNKNOWN_ERROR)
                .setErrorMessage("")
                .build());
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
