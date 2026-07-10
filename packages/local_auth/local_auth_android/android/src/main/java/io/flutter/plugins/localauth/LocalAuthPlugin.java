// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static android.content.Context.KEYGUARD_SERVICE;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.jetbrains.annotations.NotNull;

/**
 * Flutter plugin providing access to local authentication.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class LocalAuthPlugin implements FlutterPlugin, ActivityAware, LocalAuthApi {
  private Activity activity;
  private AuthenticationHelper authHelper;

  @VisibleForTesting final AtomicBoolean authInProgress = new AtomicBoolean(false);

  private Lifecycle lifecycle;
  private BiometricManager biometricManager;
  private KeyguardManager keyguardManager;

  /**
   * Default constructor for LocalAuthPlugin.
   *
   * <p>Use this constructor when adding this plugin to an app with v2 embedding.
   */
  public LocalAuthPlugin() {}

  @Override
  public boolean isDeviceSupported() {
    return isDeviceSecure() || canAuthenticateWithBiometrics();
  }

  @Override
  public boolean deviceCanSupportBiometrics() {
    return hasBiometricHardware();
  }

  @Override
  public @Nullable List<AuthClassification> getEnrolledBiometrics() {
    if (biometricManager == null) {
      return null;
    }
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

  @Override
  public boolean stopAuthentication() {
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

  @Override
  public void authenticate(
      @NonNull AuthOptions options,
      @NonNull AuthStrings strings,
      @NonNull Function1<? super @NotNull Result<@NotNull AuthResult>, @NotNull Unit> callback) {
    if (authInProgress.get()) {
      ResultUtilsKt.completeWithValue(
          callback, new AuthResult(AuthResultCode.ALREADY_IN_PROGRESS, null));
      return;
    }

    if (activity == null || activity.isFinishing()) {
      ResultUtilsKt.completeWithValue(callback, new AuthResult(AuthResultCode.NO_ACTIVITY, null));
      return;
    }

    if (!(activity instanceof FragmentActivity)) {
      ResultUtilsKt.completeWithValue(
          callback, new AuthResult(AuthResultCode.NOT_FRAGMENT_ACTIVITY, null));
      return;
    }

    if (!isDeviceSupported()) {
      ResultUtilsKt.completeWithValue(
          callback, new AuthResult(AuthResultCode.NO_CREDENTIALS, null));
      return;
    }

    authInProgress.set(true);
    AuthCompletionHandler completionHandler = createAuthCompletionHandler(callback);

    boolean allowCredentials = !options.getBiometricOnly() && canAuthenticateWithDeviceCredential();

    sendAuthenticationRequest(options, strings, allowCredentials, completionHandler);
  }

  @VisibleForTesting
  public @NonNull AuthCompletionHandler createAuthCompletionHandler(
      @NonNull Function1<? super @NotNull Result<@NotNull AuthResult>, @NotNull Unit> callback) {
    return authResult -> onAuthenticationCompleted(callback, authResult);
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

  void onAuthenticationCompleted(
      @NonNull Function1<? super @NotNull Result<@NotNull AuthResult>, @NotNull Unit> callback,
      AuthResult value) {
    if (authInProgress.compareAndSet(true, false)) {
      ResultUtilsKt.completeWithValue(callback, value);
    }
  }

  @VisibleForTesting
  public boolean isDeviceSecure() {
    if (keyguardManager == null) return false;
    return keyguardManager.isDeviceSecure();
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
    LocalAuthApi.Companion.setUp(binding.getBinaryMessenger(), this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    LocalAuthApi.Companion.setUp(binding.getBinaryMessenger(), null);
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
