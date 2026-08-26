// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.app.Application;
import android.content.Context;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import kotlin.Unit;
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
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.USER_CANCELED, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsNegativeButton() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NEGATIVE_BUTTON, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.NEGATIVE_BUTTON, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_withoutDialogs_returnsNoCredential() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.NO_CREDENTIALS, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_withoutDialogs_returnsNotEnrolledForNoBiometrics() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_BIOMETRICS, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.NOT_ENROLLED, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsHardwareUnavailable() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_UNAVAILABLE, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.HARDWARE_UNAVAILABLE, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsHardwareNotPresent() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_NOT_PRESENT, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.NO_HARDWARE, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsTemporaryLockoutForLockout() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.LOCKED_OUT_TEMPORARILY, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsPermanentLockoutForLockoutPermanent() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT_PERMANENT, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.LOCKED_OUT_PERMANENTLY, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_withoutSticky_returnsSystemCanceled() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.SYSTEM_CANCELED, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsTimeout() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_TIMEOUT, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.TIMEOUT, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsNoSpace() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_SPACE, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.NO_SPACE, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsSecurityUpdateRequired() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.SECURITY_UPDATE_REQUIRED, result[0].getCode());
  }

  @Test
  public void onAuthenticationError_returnsUnknownForOtherCases() {
    final AuthResult[] result = new AuthResult[1];
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result[0] = authResult;
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_UNABLE_TO_PROCESS, "");

    assertNotNull(result[0]);
    assertEquals(AuthResultCode.UNKNOWN_ERROR, result[0].getCode());
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
