// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlesignin

import android.accounts.Account
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender.SendIntentException
import androidx.annotation.VisibleForTesting
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.Credential
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.exceptions.ClearCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.GetCredentialInterruptedException
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException
import androidx.credentials.exceptions.GetCredentialUnsupportedException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.gms.auth.api.identity.AuthorizationClient
import com.google.android.gms.auth.api.identity.AuthorizationRequest
import com.google.android.gms.auth.api.identity.ClearTokenRequest
import com.google.android.gms.auth.api.identity.Identity
import com.google.android.gms.auth.api.identity.RevokeAccessRequest
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Scope
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.util.concurrent.Executors

/** Google sign-in plugin for Flutter. */
class GoogleSignInPlugin : FlutterPlugin, ActivityAware {
  private var delegate: Delegate? = null
  private var messenger: BinaryMessenger? = null
  private var activityPluginBinding: ActivityPluginBinding? = null

  private fun initInstance(messenger: BinaryMessenger, context: Context) {
    initWithDelegate(
        messenger,
        Delegate(
            context,
            CredentialManager::create,
            Identity::getAuthorizationClient,
            { credential -> GoogleIdTokenCredential.createFrom(credential.data) }))
  }

  @VisibleForTesting
  fun initWithDelegate(messenger: BinaryMessenger, delegate: Delegate) {
    this.messenger = messenger
    this.delegate = delegate
    GoogleSignInApi.setUp(messenger, delegate)
  }

  private fun dispose() {
    delegate = null
    messenger?.let { GoogleSignInApi.setUp(it, null) }
    messenger = null
  }

  private fun attachToActivity(activityPluginBinding: ActivityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding
    delegate?.let {
      activityPluginBinding.addActivityResultListener(it)
      it.activity = activityPluginBinding.activity
    }
  }

  private fun disposeActivity() {
    delegate?.let {
      activityPluginBinding?.removeActivityResultListener(it)
      it.activity = null
    }
    activityPluginBinding = null
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initInstance(binding.binaryMessenger, binding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    dispose()
  }

  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    attachToActivity(activityPluginBinding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    disposeActivity()
  }

  override fun onReattachedToActivityForConfigChanges(
      activityPluginBinding: ActivityPluginBinding
  ) {
    attachToActivity(activityPluginBinding)
  }

  override fun onDetachedFromActivity() {
    disposeActivity()
  }

  /**
   * Delegate class that does the work for the Google sign-in plugin. This is exposed as a dedicated
   * class for use in other plugins that wrap basic sign-in functionality.
   *
   * All methods in this class assume that they are run to completion before any other method is
   * invoked. In this context, "run to completion" means that their callback argument has been
   * completed (either successfully or in error). This class provides no synchronization constructs
   * to guarantee such behavior; callers are responsible for providing such guarantees.
   */
  class Delegate(
      private val context: Context,
      private val credentialManagerFactory: (Context) -> CredentialManager,
      private val authorizationClientFactory: (Context) -> AuthorizationClient,
      private val credentialConverter: (Credential) -> GoogleIdTokenCredential
  ) : ActivityResultListener, GoogleSignInApi {
    var activity: Activity? = null

    private var pendingAuthorizationCallback: ((Result<AuthorizeResult>) -> Unit)? = null

    override fun getGoogleServicesJsonServerClientId(): String? {
      @SuppressLint("DiscouragedApi")
      val webClientIdIdentifier =
          context.resources.getIdentifier("default_web_client_id", "string", context.packageName)
      if (webClientIdIdentifier != 0) {
        return context.getString(webClientIdIdentifier)
      }
      return null
    }

    override fun getCredential(
        params: GetCredentialRequestParams,
        callback: (Result<GetCredentialResult>) -> Unit
    ) {
      try {
        val serverClientId = params.serverClientId
        if (serverClientId.isNullOrEmpty()) {
          callback(
              Result.success(
                  GetCredentialFailure(
                      GetCredentialFailureType.MISSING_SERVER_CLIENT_ID,
                      "CredentialManager requires a serverClientId.",
                      null)))
          return
        }

        // getCredentialAsync requires an activity context, not an application context, per
        // the API docs.
        val activity = this.activity
        if (activity == null) {
          callback(
              Result.success(
                  GetCredentialFailure(
                      GetCredentialFailureType.NO_ACTIVITY, "No activity available", null)))
          return
        }

        val credentialOption =
            if (params.useButtonFlow) {
              GetSignInWithGoogleOption.Builder(serverClientId)
                  .apply {
                    params.hostedDomain?.let { setHostedDomainFilter(it) }
                    params.nonce?.let { setNonce(it) }
                  }
                  .build()
            } else {
              // TODO(stuartmorgan): Add a hosted domain filter here if hosted
              // domain support is added to GetGoogleIdOption in the future.
              GetGoogleIdOption.Builder()
                  .apply {
                    setFilterByAuthorizedAccounts(params.googleIdOptionParams.filterToAuthorized)
                    setAutoSelectEnabled(params.googleIdOptionParams.autoSelectEnabled)
                    setServerClientId(serverClientId)
                    params.nonce?.let { setNonce(it) }
                  }
                  .build()
            }
        val requestBuilder = GetCredentialRequest.Builder()
        requestBuilder.addCredentialOption(credentialOption)

        val credentialManager = credentialManagerFactory(context)
        credentialManager.getCredentialAsync(
            activity,
            requestBuilder.build(),
            null,
            Executors.newSingleThreadExecutor(),
            object : CredentialManagerCallback<GetCredentialResponse, GetCredentialException> {
              override fun onResult(result: GetCredentialResponse) {
                val credential = result.credential
                if (credential is CustomCredential &&
                    (credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL)) {
                  val googleIdTokenCredential = credentialConverter(credential)
                  val profilePictureUri = googleIdTokenCredential.profilePictureUri
                  callback(
                      Result.success(
                          GetCredentialSuccess(
                              PlatformGoogleIdTokenCredential(
                                  googleIdTokenCredential.displayName,
                                  googleIdTokenCredential.familyName,
                                  googleIdTokenCredential.givenName,
                                  googleIdTokenCredential.email ?: "",
                                  googleIdTokenCredential.uniqueId,
                                  googleIdTokenCredential.idToken,
                                  profilePictureUri?.toString()))))
                } else {
                  callback(
                      Result.success(
                          GetCredentialFailure(
                              GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE,
                              "Unexpected credential type: $credential",
                              null)))
                }
              }

              override fun onError(e: GetCredentialException) {
                val type =
                    when (e) {
                      is GetCredentialCancellationException -> GetCredentialFailureType.CANCELED
                      is GetCredentialInterruptedException -> GetCredentialFailureType.INTERRUPTED
                      is GetCredentialProviderConfigurationException ->
                          GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE
                      is GetCredentialUnsupportedException -> GetCredentialFailureType.UNSUPPORTED
                      is NoCredentialException -> GetCredentialFailureType.NO_CREDENTIAL
                      else -> GetCredentialFailureType.UNKNOWN
                    }
                // Errors are reported through the return value as structured data, rather than
                // a Result error's PlatformException.
                callback(Result.success(GetCredentialFailure(type, e.message, null)))
              }
            })
      } catch (e: RuntimeException) {
        callback(
            Result.success(
                GetCredentialFailure(
                    GetCredentialFailureType.UNKNOWN,
                    e.message,
                    "Cause: ${e.cause}, Stacktrace: ${Log.getStackTraceString(e)}")))
      }
    }

    override fun clearCredentialState(callback: (Result<Unit>) -> Unit) {
      val credentialManager = credentialManagerFactory(context)
      credentialManager.clearCredentialStateAsync(
          ClearCredentialStateRequest(),
          null,
          Executors.newSingleThreadExecutor(),
          object : CredentialManagerCallback<Void?, ClearCredentialException> {
            override fun onResult(result: Void?) {
              callback(Result.success(Unit))
            }

            override fun onError(e: ClearCredentialException) {
              callback(Result.failure(FlutterError("Clear Failed", e.message, null)))
            }
          })
    }

    override fun clearAuthorizationToken(token: String, callback: (Result<Unit>) -> Unit) {
      authorizationClientFactory(context)
          .clearToken(ClearTokenRequest.builder().setToken(token).build())
          .addOnSuccessListener { callback(Result.success(Unit)) }
          .addOnFailureListener { e ->
            callback(
                Result.failure(FlutterError("clearAuthorizationToken failed", e.message, null)))
          }
    }

    override fun authorize(
        params: PlatformAuthorizationRequest,
        promptIfUnauthorized: Boolean,
        callback: (Result<AuthorizeResult>) -> Unit
    ) {
      try {
        val requestedScopes = params.scopes.map { Scope(it) }
        val authorizationRequest =
            AuthorizationRequest.builder()
                .apply {
                  setRequestedScopes(requestedScopes)
                  params.hostedDomain?.let { filterByHostedDomain(it) }
                  params.serverClientIdForForcedRefreshToken?.let {
                    requestOfflineAccess(it)
                    // This requests a new refresh token
                    setPrompt(AuthorizationRequest.Prompt.CONSENT)
                  }
                  params.accountEmail?.let { setAccount(Account(it, GOOGLE_ACCOUNT_TYPE)) }
                }
                .build()
        authorizationClientFactory(context)
            .authorize(authorizationRequest)
            .addOnSuccessListener { authorizationResult ->
              if (authorizationResult.hasResolution()) {
                if (promptIfUnauthorized) {
                  val activity = this.activity
                  if (activity == null) {
                    callback(
                        Result.success(
                            AuthorizeFailure(
                                AuthorizeFailureType.NO_ACTIVITY, "No activity available", null)))
                  } else {
                    // Prompt for access. `callback` will be resolved in onActivityResult.
                    // There must be a pending intent if hasResolution() was true.
                    val pendingIntent = authorizationResult.pendingIntent!!
                    try {
                      pendingAuthorizationCallback = callback
                      activity.startIntentSenderForResult(
                          pendingIntent.intentSender,
                          REQUEST_CODE_AUTHORIZE, /* fillInIntent */
                          null, /* flagsMask */
                          0, /* flagsValue */
                          0, /* extraFlags */
                          0, /* options */
                          null)
                    } catch (e: SendIntentException) {
                      pendingAuthorizationCallback = null
                      callback(
                          Result.success(
                              AuthorizeFailure(
                                  AuthorizeFailureType.PENDING_INTENT_EXCEPTION, e.message, null)))
                    }
                  }
                } else {
                  callback(
                      Result.success(
                          AuthorizeFailure(AuthorizeFailureType.UNAUTHORIZED, null, null)))
                }
              } else {
                callback(
                    Result.success(
                        PlatformAuthorizationResult(
                            authorizationResult.accessToken,
                            authorizationResult.serverAuthCode,
                            authorizationResult.grantedScopes)))
              }
            }
            .addOnFailureListener { e ->
              callback(
                  Result.success(
                      AuthorizeFailure(AuthorizeFailureType.AUTHORIZE_FAILURE, e.message, null)))
            }
      } catch (e: RuntimeException) {
        callback(
            Result.success(
                AuthorizeFailure(
                    AuthorizeFailureType.API_EXCEPTION,
                    e.message,
                    "Cause: ${e.cause}, Stacktrace: ${Log.getStackTraceString(e)}")))
      }
    }

    override fun revokeAccess(
        params: PlatformRevokeAccessRequest,
        callback: (Result<Unit>) -> Unit
    ) {
      val scopes = params.scopes.map { Scope(it) }
      authorizationClientFactory(context)
          .revokeAccess(
              RevokeAccessRequest.builder()
                  .setAccount(Account(params.accountEmail, GOOGLE_ACCOUNT_TYPE))
                  .setScopes(scopes)
                  .build())
          .addOnSuccessListener { callback(Result.success(Unit)) }
          .addOnFailureListener { e ->
            callback(Result.failure(FlutterError("revokeAccess failed", e.message, null)))
          }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
      if (requestCode == REQUEST_CODE_AUTHORIZE) {
        val callback = pendingAuthorizationCallback
        if (callback != null) {
          // Clear the pending callback before completing it so a re-delivered result (e.g. after a
          // configuration change or process death) cannot complete the same reply twice.
          pendingAuthorizationCallback = null
          try {
            val authorizationResult =
                authorizationClientFactory(context).getAuthorizationResultFromIntent(data)
            callback(
                Result.success(
                    PlatformAuthorizationResult(
                        authorizationResult.accessToken,
                        authorizationResult.serverAuthCode,
                        authorizationResult.grantedScopes)))
            return true
          } catch (e: ApiException) {
            callback(
                Result.success(
                    AuthorizeFailure(AuthorizeFailureType.API_EXCEPTION, e.message, null)))
          }
        } else {
          Log.e("google_sign_in", "Unexpected authorization result callback")
        }
      }
      return false
    }

    companion object {
      @VisibleForTesting const val REQUEST_CODE_AUTHORIZE: Int = 53294
    }
  }

  companion object {
    // The account type to use to create an Account object for a Google Sign In account.
    private const val GOOGLE_ACCOUNT_TYPE = "com.google"
  }
}
