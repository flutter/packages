// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.KeyguardManager;
import android.app.NativeActivity;
import android.content.Context;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;
import io.flutter.plugins.localauth.Messages.AuthClassification;
import io.flutter.plugins.localauth.Messages.AuthOptions;
import io.flutter.plugins.localauth.Messages.AuthResult;
import io.flutter.plugins.localauth.Messages.AuthStrings;
import io.flutter.plugins.localauth.Messages.Result;
import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class LocalAuthTest {
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
  public void authenticate_returnsErrorWhenAuthInProgress() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.authInProgress.set(true);
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);
    plugin.authenticate(defaultOptions, dummyStrings, mockResult);
    ArgumentCaptor<AuthResult> captor = ArgumentCaptor.forClass(AuthResult.class);
    verify(mockResult).success(captor.capture());
    assertEquals(AuthResult.ERROR_ALREADY_IN_PROGRESS, captor.getValue());
  }

  @Test
  public void authenticate_returnsErrorWithNoForegroundActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);

    plugin.authenticate(defaultOptions, dummyStrings, mockResult);
    ArgumentCaptor<AuthResult> captor = ArgumentCaptor.forClass(AuthResult.class);
    verify(mockResult).success(captor.capture());
    assertEquals(AuthResult.ERROR_NO_ACTIVITY, captor.getValue());
  }

  @Test
  public void authenticate_returnsErrorWhenActivityNotFragmentActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(NativeActivity.class)));
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);
    plugin.authenticate(defaultOptions, dummyStrings, mockResult);
    ArgumentCaptor<AuthResult> captor = ArgumentCaptor.forClass(AuthResult.class);
    verify(mockResult).success(captor.capture());
    assertEquals(AuthResult.ERROR_NOT_FRAGMENT_ACTIVITY, captor.getValue());
  }

  @Test
  public void authenticate_returnsErrorWhenDeviceNotSupported() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);

    plugin.authenticate(defaultOptions, dummyStrings, mockResult);
    ArgumentCaptor<AuthResult> captor = ArgumentCaptor.forClass(AuthResult.class);
    verify(mockResult).success(captor.capture());
    assertEquals(AuthResult.ERROR_NOT_AVAILABLE, captor.getValue());
  }

  @Test
  public void authenticate_properlyConfiguresBiometricOnlyAuthenticationRequest() {
    final LocalAuthPlugin plugin = spy(new LocalAuthPlugin());
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    when(plugin.isDeviceSupported()).thenReturn(true);

    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    ArgumentCaptor<Boolean> allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean.class);
    doNothing()
        .when(plugin)
        .sendAuthenticationRequest(
            any(AuthOptions.class),
            any(AuthStrings.class),
            allowCredentialsCaptor.capture(),
            any(AuthCompletionHandler.class));
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);

    final AuthOptions options =
        new AuthOptions.Builder()
            .setBiometricOnly(true)
            .setSensitiveTransaction(false)
            .setSticky(false)
            .setUseErrorDialgs(false)
            .build();
    plugin.authenticate(options, dummyStrings, mockResult);
    assertFalse(allowCredentialsCaptor.getValue());
  }

  @Test
  @Config(sdk = 30)
  public void authenticate_properlyConfiguresBiometricAndDeviceCredentialAuthenticationRequest() {
    final LocalAuthPlugin plugin = spy(new LocalAuthPlugin());
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    when(plugin.isDeviceSupported()).thenReturn(true);

    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    ArgumentCaptor<Boolean> allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean.class);
    doNothing()
        .when(plugin)
        .sendAuthenticationRequest(
            any(AuthOptions.class),
            any(AuthStrings.class),
            allowCredentialsCaptor.capture(),
            any(AuthCompletionHandler.class));
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);

    plugin.authenticate(defaultOptions, dummyStrings, mockResult);
    assertTrue(allowCredentialsCaptor.getValue());
  }

  @Test
  @Config(sdk = 30)
  public void authenticate_properlyConfiguresDeviceCredentialOnlyAuthenticationRequest() {
    final LocalAuthPlugin plugin = spy(new LocalAuthPlugin());
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    when(plugin.isDeviceSupported()).thenReturn(true);

    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    ArgumentCaptor<Boolean> allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean.class);
    doNothing()
        .when(plugin)
        .sendAuthenticationRequest(
            any(AuthOptions.class),
            any(AuthStrings.class),
            allowCredentialsCaptor.capture(),
            any(AuthCompletionHandler.class));
    @SuppressWarnings("unchecked")
    final Result<AuthResult> mockResult = mock(Result.class);

    plugin.authenticate(defaultOptions, dummyStrings, mockResult);
    assertTrue(allowCredentialsCaptor.getValue());
  }

  @Test
  public void isDeviceSupportedReturnsFalse() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    assertFalse(plugin.isDeviceSupported());
  }

  @Test
  public void deviceCanSupportBiometrics_returnsTrueForPresentNonEnrolledBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    assertTrue(plugin.deviceCanSupportBiometrics());
  }

  @Test
  public void deviceSupportsBiometrics_returnsTrueForPresentEnrolledBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    assertTrue(plugin.deviceCanSupportBiometrics());
  }

  @Test
  public void deviceSupportsBiometrics_returnsFalseForNoBiometricHardware() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE);
    plugin.setBiometricManager(mockBiometricManager);

    assertFalse(plugin.deviceCanSupportBiometrics());
  }

  @Test
  public void deviceSupportsBiometrics_returnsFalseForNullBiometricManager() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.setBiometricManager(null);

    assertFalse(plugin.deviceCanSupportBiometrics());
  }

  @Test
  public void onDetachedFromActivity_ShouldReleaseActivity() {
    final Activity mockActivity = mock(Activity.class);
    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);

    Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);

    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);

    final Lifecycle mockLifecycle = mock(Lifecycle.class);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);

    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    final BinaryMessenger mockMessenger = mock(BinaryMessenger.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(mockMessenger);

    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    assertNotNull(plugin.getActivity());

    plugin.onDetachedFromActivity();
    assertNull(plugin.getActivity());
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnEmptyList_withoutHardwarePresent() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(anyInt()))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE);
    plugin.setBiometricManager(mockBiometricManager);

    final List<AuthClassification> enrolled = plugin.getEnrolledBiometrics();
    assertTrue(enrolled.isEmpty());
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnEmptyList_withNoMethodsEnrolled() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(anyInt()))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    final List<AuthClassification> enrolled = plugin.getEnrolledBiometrics();
    assertTrue(enrolled.isEmpty());
  }

  @Test
  public void getEnrolledBiometrics_shouldOnlyAddEnrolledBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    final List<AuthClassification> enrolled = plugin.getEnrolledBiometrics();
    assertEquals(1, enrolled.size());
    assertEquals(AuthClassification.WEAK, enrolled.get(0));
  }

  @Test
  public void getEnrolledBiometrics_shouldAddStrongBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    final List<AuthClassification> enrolled = plugin.getEnrolledBiometrics();
    assertEquals(2, enrolled.size());
    assertEquals(AuthClassification.WEAK, enrolled.get(0));
    assertEquals(AuthClassification.STRONG, enrolled.get(1));
  }

  @Test
  @Config(sdk = 22)
  public void isDeviceSecure_returnsFalseOnBelowApi23() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    assertFalse(plugin.isDeviceSecure());
  }

  @Test
  @Config(sdk = 23)
  public void isDeviceSecure_returnsTrueIfDeviceIsSecure() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    KeyguardManager mockKeyguardManager = mock(KeyguardManager.class);
    plugin.setKeyguardManager(mockKeyguardManager);

    when(mockKeyguardManager.isDeviceSecure()).thenReturn(true);
    assertTrue(plugin.isDeviceSecure());

    when(mockKeyguardManager.isDeviceSecure()).thenReturn(false);
    assertFalse(plugin.isDeviceSecure());
  }

  @Test
  @Config(sdk = 30)
  public void
      canAuthenticateWithDeviceCredential_returnsTrueIfHasBiometricManagerSupportAboveApi30() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    plugin.setBiometricManager(mockBiometricManager);

    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    assertTrue(plugin.canAuthenticateWithDeviceCredential());

    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    assertFalse(plugin.canAuthenticateWithDeviceCredential());
  }

  private Activity buildMockActivityWithContext(Activity mockActivity) {
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    return mockActivity;
  }

  private void setPluginActivity(LocalAuthPlugin plugin, Activity activity) {
    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    final BinaryMessenger mockMessenger = mock(BinaryMessenger.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(mockMessenger);
    when(mockActivityBinding.getActivity()).thenReturn(activity);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);
    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
  }
}
