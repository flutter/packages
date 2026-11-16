// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugins.localauth.LocalAuthApi.Companion.setUp
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/**
 * Flutter plugin providing access to local authentication.
 *
 * Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
class LocalAuthPlugin
/**
 * Default constructor for LocalAuthPlugin.
 *
 * Use this constructor when adding this plugin to an app with v2 embedding.
 */
: FlutterPlugin, ActivityAware, LocalAuthApi {
  internal var activity: Activity? = null
    private set

  private var authHelper: AuthenticationHelper? = null

  internal val authInProgress: AtomicBoolean = AtomicBoolean(false)

  private var lifecycle: Lifecycle? = null
  private var biometricManager: BiometricManager? = null
  private var keyguardManager: KeyguardManager? = null

  override fun isDeviceSupported(): Boolean {
    return this.isDeviceSecure || canAuthenticateWithBiometrics()
  }

  override fun deviceCanSupportBiometrics(): Boolean {
    return hasBiometricHardware()
  }

  override fun getEnrolledBiometrics(): List<AuthClassification>? {
    val manager = biometricManager ?: return null
    return buildList {
      if (manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK) ==
          BiometricManager.BIOMETRIC_SUCCESS) {
        add(AuthClassification.WEAK)
      }
      if (manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG) ==
          BiometricManager.BIOMETRIC_SUCCESS) {
        add(AuthClassification.STRONG)
      }
    }
  }

  override fun stopAuthentication(): Boolean {
    try {
      if (authInProgress.get()) {
        authHelper?.stopAuthentication()
        authHelper = null
      }
      return true
    } catch (_: Exception) {
      return false
    }
  }

  override suspend fun authenticate(options: AuthOptions, strings: AuthStrings): AuthResult {
    val currentActivity = activity
    if (authInProgress.get()) {
      return AuthResult(AuthResultCode.ALREADY_IN_PROGRESS, null)
    }

    if (currentActivity?.isFinishing ?: true) {
      return AuthResult(AuthResultCode.NO_ACTIVITY, null)
    }

    if (currentActivity !is FragmentActivity) {
      return AuthResult(AuthResultCode.NOT_FRAGMENT_ACTIVITY, null)
    }

    if (!isDeviceSupported()) {
      return AuthResult(AuthResultCode.NO_CREDENTIALS, null)
    }

    authInProgress.set(true)
    val allowCredentials = !options.biometricOnly && canAuthenticateWithDeviceCredential()

    return suspendCoroutine { continuation ->
      val completionHandler = createAuthCompletionHandler(continuation)
      sendAuthenticationRequest(
          options, strings, allowCredentials, currentActivity, completionHandler)
    }
  }

  internal fun createAuthCompletionHandler(
      continuation: Continuation<AuthResult>
  ): (AuthResult) -> Unit {
    return { authResult ->
      if (authInProgress.compareAndSet(true, false)) {
        continuation.resume(authResult)
      }
    }
  }

  internal fun sendAuthenticationRequest(
      options: AuthOptions,
      strings: AuthStrings,
      allowCredentials: Boolean,
      fragmentActivity: FragmentActivity,
      completionHandler: (AuthResult) -> Unit
  ) {
    val helper =
        AuthenticationHelper(
            lifecycle, fragmentActivity, options, strings, completionHandler, allowCredentials)
    authHelper = helper
    helper.authenticate()
  }

  internal val isDeviceSecure: Boolean
    get() {
      return keyguardManager?.isDeviceSecure ?: false
    }

  private fun canAuthenticateWithBiometrics(): Boolean {
    return biometricManager?.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK) ==
        BiometricManager.BIOMETRIC_SUCCESS
  }

  private fun hasBiometricHardware(): Boolean {
    val manager = biometricManager ?: return false
    return manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK) !=
        BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE
  }

  internal fun canAuthenticateWithDeviceCredential(): Boolean {
    if (Build.VERSION.SDK_INT < 30) {
      // Checking for device credential only authentication via the BiometricManager
      // is not allowed before API level 30, so we check for presence of PIN, pattern,
      // or password instead.
      return this.isDeviceSecure
    }

    return biometricManager?.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL) ==
        BiometricManager.BIOMETRIC_SUCCESS
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    setUp(binding.binaryMessenger, null)
  }

  private fun setServicesFromActivity(activity: Activity?) {
    if (activity == null) return
    this.activity = activity
    val context = activity.baseContext
    biometricManager = BiometricManager.from(activity)
    keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager?
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    setServicesFromActivity(binding.activity)
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    lifecycle = null
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    setServicesFromActivity(binding.activity)
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
  }

  override fun onDetachedFromActivity() {
    lifecycle = null
    activity = null
  }

  internal fun setBiometricManager(biometricManager: BiometricManager?) {
    this.biometricManager = biometricManager
  }

  internal fun setKeyguardManager(keyguardManager: KeyguardManager?) {
    this.keyguardManager = keyguardManager
  }
}
