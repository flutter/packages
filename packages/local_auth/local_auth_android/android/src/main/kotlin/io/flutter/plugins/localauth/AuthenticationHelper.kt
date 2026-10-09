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
import android.view.ViewTreeObserver
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
  private var stoppedByClient = false
  private var focusListener: ViewTreeObserver.OnWindowFocusChangeListener? = null
  private var focusTimeout: Runnable? = null
  private var repromptOnFocus = false
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
    stoppedByClient = true
    stop()
    biometricPrompt?.cancelAuthentication()
    biometricPrompt = null
  }

  /** Stops the biometric listener. */
  private fun stop() {
    stopWaitingForFocus()
    if (lifecycle != null) {
      lifecycle.removeObserver(this)
      return
    }
    activity.application.unregisterActivityLifecycleCallbacks(this)
  }

  @SuppressLint("SwitchIntDef")
  override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
    if (isAuthSticky && !stoppedByClient && isCancellation(errorCode)) {
      // If we are doing sticky auth and the activity has been paused,
      // ignore this error. We will start listening again when resumed.
      if (activityPaused) return
      // Android 12+ reports ERROR_USER_CANCELED both when the user dismisses the prompt and when
      // SystemUI dismisses it because the app left the foreground, and the error can arrive
      // before the activity is paused, or without it being paused at all (e.g. the app switcher
      // keeps it resumed). The prompt window holds focus while shown, so focus only returns to
      // the activity if the user dismissed the prompt.
      // See https://github.com/flutter/flutter/issues/125293
      // Focus can't return to an activity that is going away, so report the error in that case.
      if (!activity.hasWindowFocus() && !activity.isFinishing && !activity.isDestroyed) {
        waitForFocus(errorCode, errString)
        return
      }
    }
    completeWithError(errorCode, errString)
  }

  private fun isCancellation(errorCode: Int): Boolean =
      errorCode == BiometricPrompt.ERROR_CANCELED ||
          errorCode == BiometricPrompt.ERROR_USER_CANCELED

  /**
   * Reports the cancellation if the activity regains focus shortly, otherwise treats the app as
   * backgrounded and prompts again once the activity regains focus or is resumed.
   */
  private fun waitForFocus(errorCode: Int, errString: CharSequence) {
    stopWaitingForFocus()
    val listener =
        ViewTreeObserver.OnWindowFocusChangeListener { hasFocus ->
          if (!hasFocus) return@OnWindowFocusChangeListener
          val reprompt = repromptOnFocus
          stopWaitingForFocus()
          if (reprompt) {
            showPromptAgain()
          } else {
            completeWithError(errorCode, errString)
          }
        }
    val timeout = Runnable { repromptOnFocus = true }
    focusListener = listener
    focusTimeout = timeout
    activity.window.decorView.viewTreeObserver.addOnWindowFocusChangeListener(listener)
    uiThreadExecutor.handler.postDelayed(timeout, FOCUS_RETURN_TIMEOUT_MS)
  }

  private fun stopWaitingForFocus() {
    focusListener?.let {
      activity.window?.decorView?.viewTreeObserver?.removeOnWindowFocusChangeListener(it)
    }
    focusTimeout?.let { uiThreadExecutor.handler.removeCallbacks(it) }
    focusListener = null
    focusTimeout = null
    repromptOnFocus = false
  }

  private fun completeWithError(errorCode: Int, errString: CharSequence) {
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
      // Resuming will show the prompt again.
      stopWaitingForFocus()
    }
  }

  private fun handleResume() {
    if (isAuthSticky) {
      activityPaused = false
      showPromptAgain()
    }
  }

  private fun showPromptAgain() {
    // TODO(stuartmorgan): This should be assigning to biometricPrompt instead; see
    // https://github.com/flutter/flutter/issues/191804
    val prompt = BiometricPrompt(activity, uiThreadExecutor, this)
    // When activity is resuming, we cannot show the prompt right away. We need to post it to the
    // UI queue.
    uiThreadExecutor.handler.post { prompt.authenticate(promptInfo) }
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

  companion object {
    /** How long to wait for the activity to regain focus after the prompt is canceled. */
    internal const val FOCUS_RETURN_TIMEOUT_MS = 500L
  }

  internal class UiThreadExecutor : Executor {
    val handler: Handler = Handler(Looper.getMainLooper())

    override fun execute(command: Runnable) {
      handler.post(command)
    }
  }
}
