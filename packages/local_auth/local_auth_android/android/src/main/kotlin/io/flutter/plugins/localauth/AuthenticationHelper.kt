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
 *
 * One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
internal class AuthenticationHelper(
    private val lifecycle: Lifecycle?,
    private val activity: FragmentActivity,
    options: AuthOptions,
    strings: AuthStrings,
    private val completionHandler: AuthCompletionHandler,
    allowCredentials: Boolean
) : BiometricPrompt.AuthenticationCallback(), ActivityLifecycleCallbacks, DefaultLifecycleObserver {
    /** The callback that handles the result of this authentication process.  */
    internal interface AuthCompletionHandler {
        /** Called when authentication attempt is complete.  */
        fun complete(authResult: AuthResult?)
    }

    private val promptInfo: PromptInfo
    private val isAuthSticky: Boolean
    private val uiThreadExecutor: UiThreadExecutor
    private var activityPaused = false
    private var biometricPrompt: BiometricPrompt? = null

    init {
        this.isAuthSticky = options.sticky
        this.uiThreadExecutor = UiThreadExecutor()

        val promptBuilder =
            PromptInfo.Builder()
                .setDescription(strings.reason)
                .setTitle(strings.signInTitle)
                .setSubtitle(strings.signInHint)
                .setConfirmationRequired(options.sensitiveTransaction)

        var allowedAuthenticators =
            (BiometricManager.Authenticators.BIOMETRIC_WEAK
                    or BiometricManager.Authenticators.BIOMETRIC_STRONG)

        if (allowCredentials) {
            allowedAuthenticators =
                allowedAuthenticators or BiometricManager.Authenticators.DEVICE_CREDENTIAL
        } else {
            promptBuilder.setNegativeButtonText(strings.cancelButton)
        }

        promptBuilder.setAllowedAuthenticators(allowedAuthenticators)
        this.promptInfo = promptBuilder.build()
    }

    /** Start the biometric listener.  */
    fun authenticate() {
        if (lifecycle != null) {
            lifecycle.addObserver(this)
        } else {
            activity.getApplication().registerActivityLifecycleCallbacks(this)
        }
        biometricPrompt = BiometricPrompt(activity, uiThreadExecutor, this)
        biometricPrompt!!.authenticate(promptInfo)
    }

    /** Cancels the biometric authentication.  */
    fun stopAuthentication() {
        if (biometricPrompt != null) {
            biometricPrompt!!.cancelAuthentication()
            biometricPrompt = null
        }
    }

    /** Stops the biometric listener.  */
    private fun stop() {
        if (lifecycle != null) {
            lifecycle.removeObserver(this)
            return
        }
        activity.getApplication().unregisterActivityLifecycleCallbacks(this)
    }

    @SuppressLint("SwitchIntDef")
    override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
        val code: AuthResultCode?
        when (errorCode) {
            BiometricPrompt.ERROR_USER_CANCELED -> code = AuthResultCode.USER_CANCELED
            BiometricPrompt.ERROR_NEGATIVE_BUTTON -> code = AuthResultCode.NEGATIVE_BUTTON
            BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL -> code = AuthResultCode.NO_CREDENTIALS
            BiometricPrompt.ERROR_NO_BIOMETRICS -> code = AuthResultCode.NOT_ENROLLED
            BiometricPrompt.ERROR_HW_UNAVAILABLE -> code = AuthResultCode.HARDWARE_UNAVAILABLE
            BiometricPrompt.ERROR_HW_NOT_PRESENT -> code = AuthResultCode.NO_HARDWARE
            BiometricPrompt.ERROR_LOCKOUT -> code = AuthResultCode.LOCKED_OUT_TEMPORARILY
            BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> code = AuthResultCode.LOCKED_OUT_PERMANENTLY
            BiometricPrompt.ERROR_CANCELED -> {
                // If we are doing sticky auth and the activity has been paused,
                // ignore this error. We will start listening again when resumed.
                if (activityPaused && isAuthSticky) {
                    return
                }
                code = AuthResultCode.SYSTEM_CANCELED
            }

            BiometricPrompt.ERROR_TIMEOUT -> code = AuthResultCode.TIMEOUT
            BiometricPrompt.ERROR_NO_SPACE -> code = AuthResultCode.NO_SPACE
            BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED -> code =
                AuthResultCode.SECURITY_UPDATE_REQUIRED

            else -> code = AuthResultCode.UNKNOWN_ERROR
        }
        completionHandler.complete(AuthResult(code, errString.toString()))
        stop()
    }

    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
        completionHandler.complete(AuthResult(AuthResultCode.SUCCESS, null))
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
    override fun onActivityPaused(ignored: Activity?) {
        if (isAuthSticky) {
            activityPaused = true
        }
    }

    override fun onActivityResumed(ignored: Activity?) {
        if (isAuthSticky) {
            activityPaused = false
            val prompt = BiometricPrompt(activity, uiThreadExecutor, this)
            // When activity is resuming, we cannot show the prompt right away. We need to post it to the
            // UI queue.
            uiThreadExecutor.handler.post(Runnable { prompt.authenticate(promptInfo) })
        }
    }

    override fun onPause(owner: LifecycleOwner) {
        onActivityPaused(null)
    }

    override fun onResume(owner: LifecycleOwner) {
        onActivityResumed(null)
    }

    // Unused methods for activity lifecycle.
    override fun onActivityCreated(activity: Activity?, bundle: Bundle?) {}

    override fun onActivityStarted(activity: Activity?) {}

    override fun onActivityStopped(activity: Activity?) {}

    override fun onActivitySaveInstanceState(activity: Activity?, bundle: Bundle?) {}

    override fun onActivityDestroyed(activity: Activity?) {}

    override fun onDestroy(owner: LifecycleOwner) {}

    override fun onStop(owner: LifecycleOwner) {}

    override fun onStart(owner: LifecycleOwner) {}

    override fun onCreate(owner: LifecycleOwner) {}

    internal class UiThreadExecutor : Executor {
        val handler: Handler = Handler(Looper.getMainLooper())

        override fun execute(command: Runnable) {
            handler.post(command)
        }
    }
}
