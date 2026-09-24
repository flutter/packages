// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlesignin

import android.accounts.Account
import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentSender.SendIntentException
import androidx.annotation.VisibleForTesting
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.Credential
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManager.Companion.create
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
import com.google.android.gms.auth.api.identity.AuthorizationResult
import com.google.android.gms.auth.api.identity.ClearTokenRequest
import com.google.android.gms.auth.api.identity.Identity
import com.google.android.gms.auth.api.identity.RevokeAccessRequest
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Scope
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential.Companion.createFrom
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugins.googlesignin.GoogleSignInApi.Companion.setUp
import java.util.Objects
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
            CredentialManagerFactory { c: Context -> create(c) },
            AuthorizationClientFactory { c: Context -> Identity.getAuthorizationClient(c) },
            GoogleIdCredentialConverter { credential: Credential -> createFrom(credential.data) }))
  }

  @VisibleForTesting
  fun initWithDelegate(messenger: BinaryMessenger, delegate: Delegate) {
    this.messenger = messenger
    this.delegate = delegate
    setUp(messenger, delegate)
  }

  private fun dispose() {
    delegate = null
    if (messenger != null) {
      GoogleSignInApi.Companion.setUp(messenger!!, null)
      messenger = null
    }
  }

  private fun attachToActivity(activityPluginBinding: ActivityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding
    activityPluginBinding.addActivityResultListener(delegate!!)
    delegate!!.activity = activityPluginBinding.getActivity()
  }

  private fun disposeActivity() {
    activityPluginBinding!!.removeActivityResultListener(delegate!!)
    delegate!!.activity = null
    activityPluginBinding = null
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initInstance(binding.getBinaryMessenger(), binding.getApplicationContext())
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

  // Creates CredentialManager instances. This is provided to be overridden for tests.
  @VisibleForTesting
  interface CredentialManagerFactory {
    fun create(context: Context): CredentialManager
  }

  // Creates AuthorizationClient instances. This is provided to be overridden for tests.
  @VisibleForTesting
  interface AuthorizationClientFactory {
    fun create(context: Context): AuthorizationClient
  }

  // Creates GoogleIdTokenCredential instances from Credential instances. This is provided
  // to be overridden for tests.
  @VisibleForTesting
  interface GoogleIdCredentialConverter {
    fun createFrom(credential: Credential): GoogleIdTokenCredential
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
      private val credentialManagerFactory: CredentialManagerFactory,
      private val authorizationClientFactory: AuthorizationClientFactory,
      val credentialConverter: GoogleIdCredentialConverter
  ) : ActivityResultListener, GoogleSignInApi {
    // Only access activity with this method.
    // Always access activity from getActivity() method.
    var activity: Activity? = null

    private var pendingAuthorizationCallback: ((Result<AuthorizeResult>) -> Unit)? = null

    override fun getGoogleServicesJsonServerClientId(): String? {
      @SuppressLint("DiscouragedApi")
      val webClientIdIdentifier =
          context
              .getResources()
              .getIdentifier("default_web_client_id", "string", context.getPackageName())
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
        if (serverClientId == null || serverClientId.isEmpty()) {
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

        val nonce = params.nonce
        val hostedDomain = params.hostedDomain
        val requestBuilder = GetCredentialRequest.Builder()
        if (params.useButtonFlow) {
          val optionBuilder = GetSignInWithGoogleOption.Builder(serverClientId)
          if (hostedDomain != null) {
            optionBuilder.setHostedDomainFilter(hostedDomain)
          }
          if (nonce != null) {
            optionBuilder.setNonce(nonce)
          }
          requestBuilder.addCredentialOption(optionBuilder.build())
        } else {
          val optionParams = params.googleIdOptionParams
          // TODO(stuartmorgan): Add a hosted domain filter here if hosted
          // domain support is added to GetGoogleIdOption in the future.
          val optionBuilder =
              GetGoogleIdOption.Builder()
                  .setFilterByAuthorizedAccounts(optionParams.filterToAuthorized)
                  .setAutoSelectEnabled(optionParams.autoSelectEnabled)
                  .setServerClientId(serverClientId)
          if (nonce != null) {
            optionBuilder.setNonce(nonce)
          }
          requestBuilder.addCredentialOption(optionBuilder.build())
        }

        val credentialManager = credentialManagerFactory.create(context)
        credentialManager.getCredentialAsync(
            activity,
            requestBuilder.build(),
            null,
            Executors.newSingleThreadExecutor(),
            object : CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?> {
              override fun onResult(response: GetCredentialResponse) {
                val credential = response.credential
                if (credential is CustomCredential &&
                    (credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL)) {
                  val googleIdTokenCredential = credentialConverter.createFrom(credential)
                  val profilePictureUri = googleIdTokenCredential.profilePictureUri
                  callback(
                      Result.success(
                          GetCredentialSuccess(
                              PlatformGoogleIdTokenCredential(
                                  googleIdTokenCredential.displayName,
                                  googleIdTokenCredential.familyName,
                                  googleIdTokenCredential.givenName,
                                  googleIdTokenCredential.email!!,
                                  googleIdTokenCredential.uniqueId,
                                  googleIdTokenCredential.idToken,
                                  if (profilePictureUri == null) null
                                  else profilePictureUri.toString()))))
                } else {
                  callback(
                      Result.success(
                          GetCredentialFailure(
                              GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE,
                              "Unexpected credential type: " + credential,
                              null)))
                }
              }

              override fun onError(e: GetCredentialException) {
                val type: GetCredentialFailureType?
                if (e is GetCredentialCancellationException) {
                  type = GetCredentialFailureType.CANCELED
                } else if (e is GetCredentialInterruptedException) {
                  type = GetCredentialFailureType.INTERRUPTED
                } else if (e is GetCredentialProviderConfigurationException) {
                  type = GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE
                } else if (e is GetCredentialUnsupportedException) {
                  type = GetCredentialFailureType.UNSUPPORTED
                } else if (e is NoCredentialException) {
                  type = GetCredentialFailureType.NO_CREDENTIAL
                } else {
                  type = GetCredentialFailureType.UNKNOWN
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
                    "Cause: " + e.cause + ", Stacktrace: " + Log.getStackTraceString(e))))
      }
    }

    override fun clearCredentialState(callback: (Result<Unit>) -> Unit) {
      val credentialManager = credentialManagerFactory.create(context)
      credentialManager.clearCredentialStateAsync(
          ClearCredentialStateRequest(),
          null,
          Executors.newSingleThreadExecutor(),
          object : CredentialManagerCallback<Void?, ClearCredentialException?> {
            override fun onResult(result: Void?) {
              callback(Result.success(Unit))
            }

            override fun onError(e: ClearCredentialException) {
              callback(Result.failure(FlutterError("Clear Failed", e.message, null)))
            }
          })
    }

    override fun clearAuthorizationToken(token: String, callback: (Result<Unit>) -> Unit) {
      authorizationClientFactory
          .create(context)
          .clearToken(ClearTokenRequest.builder().setToken(token).build())
          .addOnSuccessListener(
              OnSuccessListener { unused: Void? -> callback(Result.success(Unit)) })
          .addOnFailureListener(
              OnFailureListener { e: Exception? ->
                callback(
                    Result.failure(
                        FlutterError("clearAuthorizationToken failed", e!!.message, null)))
              })
    }

    override fun authorize(
        params: PlatformAuthorizationRequest,
        promptIfUnauthorized: Boolean,
        callback: (Result<AuthorizeResult>) -> Unit
    ) {
      try {
        val requestedScopes: MutableList<Scope?> = ArrayList<Scope?>()
        for (scope in params.scopes) {
          requestedScopes.add(Scope(scope))
        }
        val authorizationRequestBuilder =
            AuthorizationRequest.builder().setRequestedScopes(requestedScopes)
        if (params.hostedDomain != null) {
          authorizationRequestBuilder.filterByHostedDomain(params.hostedDomain)
        }
        if (params.serverClientIdForForcedRefreshToken != null) {
          authorizationRequestBuilder.requestOfflineAccess(
              params.serverClientIdForForcedRefreshToken)
          // This requests a new refresh token
          authorizationRequestBuilder.setPrompt(AuthorizationRequest.Prompt.CONSENT)
        }
        if (params.accountEmail != null) {
          authorizationRequestBuilder.setAccount(Account(params.accountEmail, GOOGLE_ACCOUNT_TYPE))
        }
        val authorizationRequest = authorizationRequestBuilder.build()
        authorizationClientFactory
            .create(context)
            .authorize(authorizationRequest)
            .addOnSuccessListener(
                OnSuccessListener { authorizationResult: AuthorizationResult? ->
                  if (authorizationResult!!.hasResolution()) {
                    if (promptIfUnauthorized) {
                      val activity = this.activity
                      if (activity == null) {
                        callback(
                            Result.success(
                                AuthorizeFailure(
                                    AuthorizeFailureType.NO_ACTIVITY,
                                    "No activity available",
                                    null)))
                        return@addOnSuccessListener
                      }
                      // Prompt for access. `callback` will be resolved in onActivityResult.
                      // There must be a pending intent if hasResolution() was true.
                      val pendingIntent =
                          Objects.requireNonNull<PendingIntent>(
                              authorizationResult.getPendingIntent())
                      try {
                        pendingAuthorizationCallback = callback
                        activity.startIntentSenderForResult(
                            pendingIntent.getIntentSender(),
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
                                    AuthorizeFailureType.PENDING_INTENT_EXCEPTION,
                                    e.message,
                                    null)))
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
                                authorizationResult.getAccessToken(),
                                authorizationResult.getServerAuthCode(),
                                authorizationResult.getGrantedScopes())))
                  }
                })
            .addOnFailureListener(
                OnFailureListener { e: Exception? ->
                  callback(
                      Result.success(
                          AuthorizeFailure(
                              AuthorizeFailureType.AUTHORIZE_FAILURE, e!!.message, null)))
                })
      } catch (e: RuntimeException) {
        callback(
            Result.success(
                AuthorizeFailure(
                    AuthorizeFailureType.API_EXCEPTION,
                    e.message,
                    "Cause: " + e.cause + ", Stacktrace: " + Log.getStackTraceString(e))))
      }
    }

    override fun revokeAccess(
        params: PlatformRevokeAccessRequest,
        callback: (Result<Unit>) -> Unit
    ) {
      val scopes: MutableList<Scope?> = ArrayList<Scope?>()
      for (scope in params.scopes) {
        scopes.add(Scope(scope))
      }
      authorizationClientFactory
          .create(context)
          .revokeAccess(
              RevokeAccessRequest.builder()
                  .setAccount(Account(params.accountEmail, GOOGLE_ACCOUNT_TYPE))
                  .setScopes(scopes)
                  .build())
          .addOnSuccessListener(
              OnSuccessListener { unused: Void? -> callback(Result.success(Unit)) })
          .addOnFailureListener(
              OnFailureListener { e: Exception? ->
                callback(Result.failure(FlutterError("revokeAccess failed", e!!.message, null)))
              })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
      if (requestCode == REQUEST_CODE_AUTHORIZE) {
        if (pendingAuthorizationCallback != null) {
          // Clear the pending callback before completing it so a re-delivered result (e.g. after a
          // configuration change or process death) cannot complete the same reply twice.
          val callback: (Result<AuthorizeResult>) -> Unit = pendingAuthorizationCallback
          pendingAuthorizationCallback = null
          try {
            val authorizationResult =
                authorizationClientFactory.create(context).getAuthorizationResultFromIntent(data)
            callback(
                Result.success(
                    PlatformAuthorizationResult(
                        authorizationResult.getAccessToken(),
                        authorizationResult.getServerAuthCode(),
                        authorizationResult.getGrantedScopes())))
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
