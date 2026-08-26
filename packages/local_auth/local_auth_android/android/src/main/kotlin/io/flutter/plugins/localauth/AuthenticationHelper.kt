// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application.ActivityLifecycleCallbacks
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricPrompt.PromptInfo
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import java.util.concurrent.Executor

/**
 * Authenticates the user with biometrics and sends corresponding response back to Flutter.
 *
 * One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
internal class AuthenticationHelper(
    private val lifecycle: Lifecycle?,
    private val activity: FragmentActivity,
    options: AuthOptions,
    strings: AuthStrings,
    private val completionHandler: (AuthResult) -> Unit,
    allowCredentials: Boolean
) : BiometricPrompt.AuthenticationCallback(), ActivityLifecycleCallbacks, DefaultLifecycleObserver {
  private val isAuthSticky: Boolean = options.sticky
  private val uiThreadExecutor: UiThreadExecutor = UiThreadExecutor()
  private var activityPaused = false
  private var biometricPrompt: BiometricPrompt? = null
  private val promptInfo: PromptInfo =
      PromptInfo.Builder()
          .apply {
            setDescription(strings.reason)
            setTitle(strings.signInTitle)
            setSubtitle(strings.signInHint)
            setConfirmationRequired(options.sensitiveTransaction)
            var allowedAuthenticators =
                (BiometricManager.Authenticators.BIOMETRIC_WEAK or
                    BiometricManager.Authenticators.BIOMETRIC_STRONG)
            if (allowCredentials) {
              allowedAuthenticators =
                  allowedAuthenticators or BiometricManager.Authenticators.DEVICE_CREDENTIAL
            } else {
              setNegativeButtonText(strings.cancelButton)
            }
            setAllowedAuthenticators(allowedAuthenticators)
          }
          .build()

  /** Start the biometric listener. */
  fun authenticate() {
    if (lifecycle != null) {
      lifecycle.addObserver(this)
    } else {
      activity.application.registerActivityLifecycleCallbacks(this)
    }
    val prompt = BiometricPrompt(activity, uiThreadExecutor, this)
    biometricPrompt = prompt
    prompt.authenticate(promptInfo)
  }

  /** Cancels the biometric authentication. */
  fun stopAuthentication() {
    biometricPrompt?.cancelAuthentication()
    biometricPrompt = null
  }

  /** Stops the biometric listener. */
  private fun stop() {
    if (lifecycle != null) {
      lifecycle.removeObserver(this)
      return
    }
    activity.application.unregisterActivityLifecycleCallbacks(this)
  }

  @SuppressLint("SwitchIntDef")
  override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
    // If we are doing sticky auth and the activity has been paused,
    // ignore this error. We will start listening again when resumed.
    if (errorCode == BiometricPrompt.ERROR_CANCELED && activityPaused && isAuthSticky) return
    val code =
        when (errorCode) {
          BiometricPrompt.ERROR_USER_CANCELED -> AuthResultCode.USER_CANCELED
          BiometricPrompt.ERROR_NEGATIVE_BUTTON -> AuthResultCode.NEGATIVE_BUTTON
          BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL -> AuthResultCode.NO_CREDENTIALS
          BiometricPrompt.ERROR_NO_BIOMETRICS -> AuthResultCode.NOT_ENROLLED
          BiometricPrompt.ERROR_HW_UNAVAILABLE -> AuthResultCode.HARDWARE_UNAVAILABLE
          BiometricPrompt.ERROR_HW_NOT_PRESENT -> AuthResultCode.NO_HARDWARE
          BiometricPrompt.ERROR_LOCKOUT -> AuthResultCode.LOCKED_OUT_TEMPORARILY
          BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> AuthResultCode.LOCKED_OUT_PERMANENTLY
          BiometricPrompt.ERROR_CANCELED -> AuthResultCode.SYSTEM_CANCELED
          BiometricPrompt.ERROR_TIMEOUT -> AuthResultCode.TIMEOUT
          BiometricPrompt.ERROR_NO_SPACE -> AuthResultCode.NO_SPACE
          BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED -> AuthResultCode.SECURITY_UPDATE_REQUIRED
          else -> AuthResultCode.UNKNOWN_ERROR
        }
    completionHandler(AuthResult(code, errString.toString()))
    stop()
  }

  override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
    completionHandler(AuthResult(AuthResultCode.SUCCESS, null))
    stop()
  }

  override fun onAuthenticationFailed() {
    // No-op; this is called for incremental failures. Wait for a final
    // resolution via the success or error callbacks.
  }

  /**
   * If the activity is paused, we keep track because biometric dialog simply returns "User
   * cancelled" when the activity is paused.
   */
  private fun handlePause() {
    if (isAuthSticky) {
      activityPaused = true
    }
  }

  private fun handleResume() {
    if (isAuthSticky) {
      activityPaused = false
      val prompt = BiometricPrompt(activity, uiThreadExecutor, this)
      // When activity is resuming, we cannot show the prompt right away. We need to post it to the
      // UI queue.
      uiThreadExecutor.handler.post { prompt.authenticate(promptInfo) }
    }
  }

  override fun onActivityPaused(ignored: Activity) {
    handlePause()
  }

  override fun onActivityResumed(ignored: Activity) {
    handleResume()
  }

  override fun onPause(owner: LifecycleOwner) {
    handlePause()
  }

  override fun onResume(owner: LifecycleOwner) {
    handleResume()
  }

  // Unused methods for activity lifecycle.
  override fun onActivityCreated(activity: Activity, bundle: Bundle?) {}

  override fun onActivityStarted(activity: Activity) {}

  override fun onActivityStopped(activity: Activity) {}

  override fun onActivitySaveInstanceState(activity: Activity, bundle: Bundle) {}

  override fun onActivityDestroyed(activity: Activity) {}

  internal class UiThreadExecutor : Executor {
    val handler: Handler = Handler(Looper.getMainLooper())

    override fun execute(command: Runnable) {
      handler.post(command)
    }
  }
}
