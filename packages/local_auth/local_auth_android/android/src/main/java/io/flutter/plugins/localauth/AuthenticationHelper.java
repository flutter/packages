// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.biometric.BiometricManager;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import java.util.concurrent.Executor;

/**
 * Authenticates the user with biometrics and sends corresponding response back to Flutter.
 *
 * <p>One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
class AuthenticationHelper extends BiometricPrompt.AuthenticationCallback
    implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
  /** The callback that handles the result of this authentication process. */
  interface AuthCompletionHandler {
    /** Called when authentication attempt is complete. */
    void complete(Messages.AuthResult authResult);
  }

  // This is null when not using v2 embedding;
  private final Lifecycle lifecycle;
  private final FragmentActivity activity;
  private final AuthCompletionHandler completionHandler;
  private final boolean useErrorDialogs;
  private final Messages.AuthStrings strings;
  private final BiometricPrompt.PromptInfo promptInfo;
  private final boolean isAuthSticky;
  private final UiThreadExecutor uiThreadExecutor;
  private boolean activityPaused = false;
  private BiometricPrompt biometricPrompt;

  AuthenticationHelper(
      Lifecycle lifecycle,
      FragmentActivity activity,
      @NonNull Messages.AuthOptions options,
      @NonNull Messages.AuthStrings strings,
      @NonNull AuthCompletionHandler completionHandler,
      boolean allowCredentials) {
    this.lifecycle = lifecycle;
    this.activity = activity;
    this.completionHandler = completionHandler;
    this.strings = strings;
    this.isAuthSticky = options.getSticky();
    this.useErrorDialogs = options.getUseErrorDialgs();
    this.uiThreadExecutor = new UiThreadExecutor();

    BiometricPrompt.PromptInfo.Builder promptBuilder =
        new BiometricPrompt.PromptInfo.Builder()
            .setDescription(strings.getReason())
            .setTitle(strings.getSignInTitle())
            .setSubtitle(strings.getBiometricHint())
            .setConfirmationRequired(options.getSensitiveTransaction());

    int allowedAuthenticators =
        BiometricManager.Authenticators.BIOMETRIC_WEAK
            | BiometricManager.Authenticators.BIOMETRIC_STRONG;

    if (allowCredentials) {
      allowedAuthenticators |= BiometricManager.Authenticators.DEVICE_CREDENTIAL;
    } else {
      promptBuilder.setNegativeButtonText(strings.getCancelButton());
    }

    promptBuilder.setAllowedAuthenticators(allowedAuthenticators);
    this.promptInfo = promptBuilder.build();
  }

  /** Start the biometric listener. */
  void authenticate() {
    if (lifecycle != null) {
      lifecycle.addObserver(this);
    } else {
      activity.getApplication().registerActivityLifecycleCallbacks(this);
    }
    biometricPrompt = new BiometricPrompt(activity, uiThreadExecutor, this);
    biometricPrompt.authenticate(promptInfo);
  }

  /** Cancels the biometric authentication. */
  void stopAuthentication() {
    if (biometricPrompt != null) {
      biometricPrompt.cancelAuthentication();
      biometricPrompt = null;
    }
  }

  /** Stops the biometric listener. */
  private void stop() {
    if (lifecycle != null) {
      lifecycle.removeObserver(this);
      return;
    }
    activity.getApplication().unregisterActivityLifecycleCallbacks(this);
  }

  @SuppressLint("SwitchIntDef")
  @Override
  public void onAuthenticationError(int errorCode, @NonNull CharSequence errString) {
    switch (errorCode) {
      case BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL:
        if (useErrorDialogs) {
          showGoToSettingsDialog(
              strings.getDeviceCredentialsRequiredTitle(),
              strings.getDeviceCredentialsSetupDescription());
          return;
        }
        completionHandler.complete(Messages.AuthResult.ERROR_NOT_AVAILABLE);
        break;
      case BiometricPrompt.ERROR_NO_SPACE:
      case BiometricPrompt.ERROR_NO_BIOMETRICS:
        if (useErrorDialogs) {
          showGoToSettingsDialog(
              strings.getBiometricRequiredTitle(), strings.getGoToSettingsDescription());
          return;
        }
        completionHandler.complete(Messages.AuthResult.ERROR_NOT_ENROLLED);
        break;
      case BiometricPrompt.ERROR_HW_UNAVAILABLE:
      case BiometricPrompt.ERROR_HW_NOT_PRESENT:
        completionHandler.complete(Messages.AuthResult.ERROR_NOT_AVAILABLE);
        break;
      case BiometricPrompt.ERROR_LOCKOUT:
        completionHandler.complete(Messages.AuthResult.ERROR_LOCKED_OUT_TEMPORARILY);
        break;
      case BiometricPrompt.ERROR_LOCKOUT_PERMANENT:
        completionHandler.complete(Messages.AuthResult.ERROR_LOCKED_OUT_PERMANENTLY);
        break;
      case BiometricPrompt.ERROR_CANCELED:
        // If we are doing sticky auth and the activity has been paused,
        // ignore this error. We will start listening again when resumed.
        if (activityPaused && isAuthSticky) {
          return;
        } else {
          completionHandler.complete(Messages.AuthResult.FAILURE);
        }
        break;
      default:
        completionHandler.complete(Messages.AuthResult.FAILURE);
    }
    stop();
  }

  @Override
  public void onAuthenticationSucceeded(@NonNull BiometricPrompt.AuthenticationResult result) {
    completionHandler.complete(Messages.AuthResult.SUCCESS);
    stop();
  }

  @Override
  public void onAuthenticationFailed() {}

  /**
   * If the activity is paused, we keep track because biometric dialog simply returns "User
   * cancelled" when the activity is paused.
   */
  @Override
  public void onActivityPaused(Activity ignored) {
    if (isAuthSticky) {
      activityPaused = true;
    }
  }

  @Override
  public void onActivityResumed(Activity ignored) {
    if (isAuthSticky) {
      activityPaused = false;
      final BiometricPrompt prompt = new BiometricPrompt(activity, uiThreadExecutor, this);
      // When activity is resuming, we cannot show the prompt right away. We need to post it to the
      // UI queue.
      uiThreadExecutor.handler.post(() -> prompt.authenticate(promptInfo));
    }
  }

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {
    onActivityPaused(null);
  }

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {
    onActivityResumed(null);
  }

  // Suppress inflateParams lint because dialogs do not need to attach to a parent view.
  @SuppressLint("InflateParams")
  private void showGoToSettingsDialog(String title, String descriptionText) {
    View view = LayoutInflater.from(activity).inflate(R.layout.go_to_setting, null, false);
    TextView message = view.findViewById(R.id.fingerprint_required);
    TextView description = view.findViewById(R.id.go_to_setting_description);
    message.setText(title);
    description.setText(descriptionText);
    Context context = new ContextThemeWrapper(activity, R.style.AlertDialogCustom);
    OnClickListener goToSettingHandler =
        (dialog, which) -> {
          completionHandler.complete(Messages.AuthResult.FAILURE);
          stop();
          activity.startActivity(new Intent(Settings.ACTION_SECURITY_SETTINGS));
        };
    OnClickListener cancelHandler =
        (dialog, which) -> {
          completionHandler.complete(Messages.AuthResult.FAILURE);
          stop();
        };
    new AlertDialog.Builder(context)
        .setView(view)
        .setPositiveButton(strings.getGoToSettingsButton(), goToSettingHandler)
        .setNegativeButton(strings.getCancelButton(), cancelHandler)
        .setCancelable(false)
        .show();
  }

  // Unused methods for activity lifecycle.

  @Override
  public void onActivityCreated(Activity activity, Bundle bundle) {}

  @Override
  public void onActivityStarted(Activity activity) {}

  @Override
  public void onActivityStopped(Activity activity) {}

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {}

  @Override
  public void onActivityDestroyed(Activity activity) {}

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {}

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {}

  static class UiThreadExecutor implements Executor {
    final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}
