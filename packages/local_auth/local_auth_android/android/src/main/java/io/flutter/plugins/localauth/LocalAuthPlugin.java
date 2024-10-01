// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static android.app.Activity.RESULT_OK;
import static android.content.Context.KEYGUARD_SERVICE;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;
import io.flutter.plugins.localauth.Messages.AuthClassification;
import io.flutter.plugins.localauth.Messages.AuthOptions;
import io.flutter.plugins.localauth.Messages.AuthResult;
import io.flutter.plugins.localauth.Messages.AuthStrings;
import io.flutter.plugins.localauth.Messages.LocalAuthApi;
import io.flutter.plugins.localauth.Messages.Result;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Flutter plugin providing access to local authentication.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class LocalAuthPlugin implements FlutterPlugin, ActivityAware, LocalAuthApi {
  private static final int LOCK_REQUEST_CODE = 221;
  private Activity activity;
  private AuthenticationHelper authHelper;

  @VisibleForTesting final AtomicBoolean authInProgress = new AtomicBoolean(false);

  // These are null when not using v2 embedding.
  private Lifecycle lifecycle;
  private BiometricManager biometricManager;
  private KeyguardManager keyguardManager;
  Result<AuthResult> lockRequestResult;
  private final PluginRegistry.ActivityResultListener resultListener =
      new PluginRegistry.ActivityResultListener() {
        @Override
        public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
          if (requestCode == LOCK_REQUEST_CODE) {
            if (resultCode == RESULT_OK && lockRequestResult != null) {
              onAuthenticationCompleted(lockRequestResult, AuthResult.SUCCESS);
            } else {
              onAuthenticationCompleted(lockRequestResult, AuthResult.FAILURE);
            }
            lockRequestResult = null;
          }
          return false;
        }
      };

  /**
   * Default constructor for LocalAuthPlugin.
   *
   * <p>Use this constructor when adding this plugin to an app with v2 embedding.
   */
  public LocalAuthPlugin() {}

  public @NonNull Boolean isDeviceSupported() {
    return isDeviceSecure() || canAuthenticateWithBiometrics();
  }

  public @NonNull Boolean deviceCanSupportBiometrics() {
    return hasBiometricHardware();
  }

  public @NonNull List<AuthClassification> getEnrolledBiometrics() {
    ArrayList<AuthClassification> biometrics = new ArrayList<>();
    if (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)
        == BiometricManager.BIOMETRIC_SUCCESS) {
      biometrics.add(AuthClassification.WEAK);
    }
    if (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        == BiometricManager.BIOMETRIC_SUCCESS) {
      biometrics.add(AuthClassification.STRONG);
    }
    return biometrics;
  }

  public @NonNull Boolean stopAuthentication() {
    try {
      if (authHelper != null && authInProgress.get()) {
        authHelper.stopAuthentication();
        authHelper = null;
      }
      authInProgress.set(false);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  public void authenticate(
      @NonNull AuthOptions options,
      @NonNull AuthStrings strings,
      @NonNull Result<AuthResult> result) {
    if (authInProgress.get()) {
      result.success(AuthResult.ERROR_ALREADY_IN_PROGRESS);
      return;
    }

    if (activity == null || activity.isFinishing()) {
      result.success(AuthResult.ERROR_NO_ACTIVITY);
      return;
    }

    if (!(activity instanceof FragmentActivity)) {
      result.success(AuthResult.ERROR_NOT_FRAGMENT_ACTIVITY);
      return;
    }

    if (!isDeviceSupported()) {
      result.success(AuthResult.ERROR_NOT_AVAILABLE);
      return;
    }

    authInProgress.set(true);
    AuthCompletionHandler completionHandler = createAuthCompletionHandler(result);

    boolean allowCredentials = !options.getBiometricOnly() && canAuthenticateWithDeviceCredential();

    sendAuthenticationRequest(options, strings, allowCredentials, completionHandler);
  }

  @VisibleForTesting
  public @NonNull AuthCompletionHandler createAuthCompletionHandler(
      @NonNull final Result<AuthResult> result) {
    return authResult -> onAuthenticationCompleted(result, authResult);
  }

  @VisibleForTesting
  public void sendAuthenticationRequest(
      @NonNull AuthOptions options,
      @NonNull AuthStrings strings,
      boolean allowCredentials,
      @NonNull AuthCompletionHandler completionHandler) {
    authHelper =
        new AuthenticationHelper(
            lifecycle,
            (FragmentActivity) activity,
            options,
            strings,
            completionHandler,
            allowCredentials);

    authHelper.authenticate();
  }

  void onAuthenticationCompleted(Result<AuthResult> result, AuthResult value) {
    if (authInProgress.compareAndSet(true, false)) {
      result.success(value);
    }
  }

  @VisibleForTesting
  public boolean isDeviceSecure() {
    if (keyguardManager == null) return false;
    return (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && keyguardManager.isDeviceSecure());
  }

  private boolean canAuthenticateWithBiometrics() {
    if (biometricManager == null) return false;
    return biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)
        == BiometricManager.BIOMETRIC_SUCCESS;
  }

  private boolean hasBiometricHardware() {
    if (biometricManager == null) return false;
    return biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)
        != BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE;
  }

  @VisibleForTesting
  public boolean canAuthenticateWithDeviceCredential() {
    if (Build.VERSION.SDK_INT < 30) {
      // Checking for device credential only authentication via the BiometricManager
      // is not allowed before API level 30, so we check for presence of PIN, pattern,
      // or password instead.
      return isDeviceSecure();
    }

    if (biometricManager == null) return false;
    return biometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL)
        == BiometricManager.BIOMETRIC_SUCCESS;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    LocalAuthApi.setUp(binding.getBinaryMessenger(), this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    LocalAuthApi.setUp(binding.getBinaryMessenger(), null);
  }

  private void setServicesFromActivity(Activity activity) {
    if (activity == null) return;
    this.activity = activity;
    Context context = activity.getBaseContext();
    biometricManager = BiometricManager.from(activity);
    keyguardManager = (KeyguardManager) context.getSystemService(KEYGUARD_SERVICE);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    binding.addActivityResultListener(resultListener);
    setServicesFromActivity(binding.getActivity());
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    lifecycle = null;
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    binding.addActivityResultListener(resultListener);
    setServicesFromActivity(binding.getActivity());
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle = null;
    activity = null;
  }

  @VisibleForTesting
  final Activity getActivity() {
    return activity;
  }

  @VisibleForTesting
  void setBiometricManager(BiometricManager biometricManager) {
    this.biometricManager = biometricManager;
  }

  @VisibleForTesting
  void setKeyguardManager(KeyguardManager keyguardManager) {
    this.keyguardManager = keyguardManager;
  }
}
