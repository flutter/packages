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
import java.util.ArrayList;
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
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_BIOMETRICS, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.NOT_ENROLLED, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsHardwareUnavailable() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_UNAVAILABLE, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.HARDWARE_UNAVAILABLE, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsHardwareNotPresent() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_HW_NOT_PRESENT, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.NO_HARDWARE, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsTemporaryLockoutForLockout() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.LOCKED_OUT_TEMPORARILY, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsPermanentLockoutForLockoutPermanent() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT_PERMANENT, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.LOCKED_OUT_PERMANENTLY, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_withoutSticky_returnsSystemCanceled() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.SYSTEM_CANCELED, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsTimeout() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_TIMEOUT, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.TIMEOUT, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsNoSpace() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_NO_SPACE, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.NO_SPACE, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsSecurityUpdateRequired() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.SECURITY_UPDATE_REQUIRED, result.get(0).getCode());
  }

  @Test
  public void onAuthenticationError_returnsUnknownForOtherCases() {
    final ArrayList<AuthResult> result = new ArrayList<>();
    final AuthenticationHelper helper =
        new AuthenticationHelper(
            null,
            buildMockActivityWithContext(mock(FragmentActivity.class)),
            defaultOptions,
            dummyStrings,
            (authResult -> {
              result.add(authResult);
              return Unit.INSTANCE;
            }),
            true);

    helper.onAuthenticationError(BiometricPrompt.ERROR_UNABLE_TO_PROCESS, "");

    assertEquals(1, result.size());
    assertEquals(AuthResultCode.UNKNOWN_ERROR, result.get(0).getCode());
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
