// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.credentials.ClearCredentialStateRequest;
import androidx.credentials.Credential;
import androidx.credentials.CredentialManager;
import androidx.credentials.CredentialManagerCallback;
import androidx.credentials.CustomCredential;
import androidx.credentials.GetCredentialRequest;
import androidx.credentials.GetCredentialResponse;
import androidx.credentials.exceptions.ClearCredentialException;
import androidx.credentials.exceptions.GetCredentialCancellationException;
import androidx.credentials.exceptions.GetCredentialException;
import androidx.credentials.exceptions.GetCredentialInterruptedException;
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException;
import androidx.credentials.exceptions.GetCredentialUnsupportedException;
import androidx.credentials.exceptions.NoCredentialException;
import com.google.android.gms.auth.api.identity.AuthorizationClient;
import com.google.android.gms.auth.api.identity.AuthorizationRequest;
import com.google.android.gms.auth.api.identity.AuthorizationResult;
import com.google.android.gms.auth.api.identity.ClearTokenRequest;
import com.google.android.gms.auth.api.identity.Identity;
import com.google.android.gms.auth.api.identity.RevokeAccessRequest;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.Scope;
import com.google.android.libraries.identity.googleid.GetGoogleIdOption;
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption;
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.Executors;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/** Google sign-in plugin for Flutter. */
public class GoogleSignInPlugin implements FlutterPlugin, ActivityAware {
  private Delegate delegate;
  private @Nullable BinaryMessenger messenger;
  private ActivityPluginBinding activityPluginBinding;

  // The account type to use to create an Account object for a Google Sign In account.
  private static final String GOOGLE_ACCOUNT_TYPE = "com.google";

  private void initInstance(@NonNull BinaryMessenger messenger, @NonNull Context context) {
    initWithDelegate(
        messenger,
        new Delegate(
            context,
            (@NonNull Context c) -> CredentialManager.create(c),
            (@NonNull Context c) -> Identity.getAuthorizationClient(c),
            (@NonNull Credential credential) ->
                GoogleIdTokenCredential.createFrom(credential.getData())));
  }

  @VisibleForTesting
  void initWithDelegate(@NonNull BinaryMessenger messenger, @NonNull Delegate delegate) {
    this.messenger = messenger;
    this.delegate = delegate;
    GoogleSignInApi.Companion.setUp(messenger, delegate);
  }

  private void dispose() {
    delegate = null;
    if (messenger != null) {
      GoogleSignInApi.Companion.setUp(messenger, null);
      messenger = null;
    }
  }

  private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
    activityPluginBinding.addActivityResultListener(delegate);
    delegate.setActivity(activityPluginBinding.getActivity());
  }

  private void disposeActivity() {
    activityPluginBinding.removeActivityResultListener(delegate);
    delegate.setActivity(null);
    activityPluginBinding = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    dispose();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    disposeActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    disposeActivity();
  }

  // Creates CredentialManager instances. This is provided to be overridden for tests.
  @VisibleForTesting
  public interface CredentialManagerFactory {
    @NonNull
    CredentialManager create(@NonNull Context context);
  }

  // Creates AuthorizationClient instances. This is provided to be overridden for tests.
  @VisibleForTesting
  public interface AuthorizationClientFactory {
    @NonNull
    AuthorizationClient create(@NonNull Context context);
  }

  // Creates GoogleIdTokenCredential instances from Credential instances. This is provided
  // to be overridden for tests.
  @VisibleForTesting
  public interface GoogleIdCredentialConverter {
    @NonNull
    GoogleIdTokenCredential createFrom(@NonNull Credential credential);
  }

  /**
   * Delegate class that does the work for the Google sign-in plugin. This is exposed as a dedicated
   * class for use in other plugins that wrap basic sign-in functionality.
   *
   * <p>All methods in this class assume that they are run to completion before any other method is
   * invoked. In this context, "run to completion" means that their callback argument has been
   * completed (either successfully or in error). This class provides no synchronization constructs
   * to guarantee such behavior; callers are responsible for providing such guarantees.
   */
  public static class Delegate implements PluginRegistry.ActivityResultListener, GoogleSignInApi {
    @VisibleForTesting static final int REQUEST_CODE_AUTHORIZE = 53294;

    private final @NonNull Context context;
    private final @NonNull CredentialManagerFactory credentialManagerFactory;
    private final @NonNull AuthorizationClientFactory authorizationClientFactory;
    final @NonNull GoogleIdCredentialConverter credentialConverter;
    // Always access activity from getActivity() method.
    private @Nullable Activity activity;

    private Function1<? super Result<? extends AuthorizeResult>, Unit> pendingAuthorizationCallback;

    public Delegate(
        @NonNull Context context,
        @NonNull CredentialManagerFactory credentialManagerFactory,
        @NonNull AuthorizationClientFactory authorizationClientFactory,
        @NonNull GoogleIdCredentialConverter credentialConverter) {
      this.context = context;
      this.credentialManagerFactory = credentialManagerFactory;
      this.authorizationClientFactory = authorizationClientFactory;
      this.credentialConverter = credentialConverter;
    }

    public void setActivity(@Nullable Activity activity) {
      this.activity = activity;
    }

    // Only access activity with this method.
    public @Nullable Activity getActivity() {
      return activity;
    }

    @Override
    public @Nullable String getGoogleServicesJsonServerClientId() {
      @SuppressLint("DiscouragedApi")
      int webClientIdIdentifier =
          context
              .getResources()
              .getIdentifier("default_web_client_id", "string", context.getPackageName());
      if (webClientIdIdentifier != 0) {
        return context.getString(webClientIdIdentifier);
      }
      return null;
    }

    @Override
    public void getCredential(
        @NonNull GetCredentialRequestParams params,
        @NonNull Function1<? super Result<? extends GetCredentialResult>, Unit> callback) {
      try {
        String serverClientId = params.getServerClientId();
        if (serverClientId == null || serverClientId.isEmpty()) {
          ResultUtilsKt.completeWithGetCredentialFailure(
              callback,
              new GetCredentialFailure(
                  GetCredentialFailureType.MISSING_SERVER_CLIENT_ID,
                  "CredentialManager requires a serverClientId.",
                  null));
          return;
        }

        // getCredentialAsync requires an activity context, not an application context, per
        // the API docs.
        Activity activity = getActivity();
        if (activity == null) {
          ResultUtilsKt.completeWithGetCredentialFailure(
              callback,
              new GetCredentialFailure(
                  GetCredentialFailureType.NO_ACTIVITY, "No activity available", null));
          return;
        }

        String nonce = params.getNonce();
        String hostedDomain = params.getHostedDomain();
        GetCredentialRequest.Builder requestBuilder = new GetCredentialRequest.Builder();
        if (params.getUseButtonFlow()) {
          GetSignInWithGoogleOption.Builder optionBuilder =
              new GetSignInWithGoogleOption.Builder(serverClientId);
          if (hostedDomain != null) {
            optionBuilder.setHostedDomainFilter(hostedDomain);
          }
          if (nonce != null) {
            optionBuilder.setNonce(nonce);
          }
          requestBuilder.addCredentialOption(optionBuilder.build());
        } else {
          GetCredentialRequestGoogleIdOptionParams optionParams = params.getGoogleIdOptionParams();
          // TODO(stuartmorgan): Add a hosted domain filter here if hosted
          // domain support is added to GetGoogleIdOption in the future.
          GetGoogleIdOption.Builder optionBuilder =
              new GetGoogleIdOption.Builder()
                  .setFilterByAuthorizedAccounts(optionParams.getFilterToAuthorized())
                  .setAutoSelectEnabled(optionParams.getAutoSelectEnabled())
                  .setServerClientId(serverClientId);
          if (nonce != null) {
            optionBuilder.setNonce(nonce);
          }
          requestBuilder.addCredentialOption(optionBuilder.build());
        }

        CredentialManager credentialManager = credentialManagerFactory.create(context);
        credentialManager.getCredentialAsync(
            activity,
            requestBuilder.build(),
            null,
            Executors.newSingleThreadExecutor(),
            new CredentialManagerCallback<>() {
              @Override
              public void onResult(GetCredentialResponse response) {
                Credential credential = response.getCredential();
                if (credential instanceof CustomCredential
                    && credential
                        .getType()
                        .equals(GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL)) {
                  GoogleIdTokenCredential googleIdTokenCredential =
                      credentialConverter.createFrom(credential);
                  Uri profilePictureUri = googleIdTokenCredential.getProfilePictureUri();
                  ResultUtilsKt.completeWithGetGetCredentialResult(
                      callback,
                      new GetCredentialSuccess(
                          new PlatformGoogleIdTokenCredential(
                              googleIdTokenCredential.getDisplayName(),
                              googleIdTokenCredential.getFamilyName(),
                              googleIdTokenCredential.getGivenName(),
                              googleIdTokenCredential.getId(),
                              googleIdTokenCredential.getIdToken(),
                              profilePictureUri == null ? null : profilePictureUri.toString())));
                } else {
                  ResultUtilsKt.completeWithGetCredentialFailure(
                      callback,
                      new GetCredentialFailure(
                          GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE,
                          "Unexpected credential type: " + credential,
                          null));
                }
              }

              @Override
              public void onError(@NonNull GetCredentialException e) {
                GetCredentialFailureType type;
                if (e instanceof GetCredentialCancellationException) {
                  type = GetCredentialFailureType.CANCELED;
                } else if (e instanceof GetCredentialInterruptedException) {
                  type = GetCredentialFailureType.INTERRUPTED;
                } else if (e instanceof GetCredentialProviderConfigurationException) {
                  type = GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE;
                } else if (e instanceof GetCredentialUnsupportedException) {
                  type = GetCredentialFailureType.UNSUPPORTED;
                } else if (e instanceof NoCredentialException) {
                  type = GetCredentialFailureType.NO_CREDENTIAL;
                } else {
                  type = GetCredentialFailureType.UNKNOWN;
                }
                // Errors are reported through the return value as structured data, rather than
                // a Result error's PlatformException.
                ResultUtilsKt.completeWithGetCredentialFailure(
                    callback, new GetCredentialFailure(type, e.getMessage(), null));
              }
            });
      } catch (RuntimeException e) {
        ResultUtilsKt.completeWithGetCredentialFailure(
            callback,
            new GetCredentialFailure(
                GetCredentialFailureType.UNKNOWN,
                e.getMessage(),
                "Cause: " + e.getCause() + ", Stacktrace: " + Log.getStackTraceString(e)));
      }
    }

    @Override
    public void clearCredentialState(@NonNull Function1<? super Result<Unit>, Unit> callback) {
      CredentialManager credentialManager = credentialManagerFactory.create(context);
      credentialManager.clearCredentialStateAsync(
          new ClearCredentialStateRequest(),
          null,
          Executors.newSingleThreadExecutor(),
          new CredentialManagerCallback<>() {
            @Override
            public void onResult(Void result) {
              ResultUtilsKt.completeWithUnitSuccess(callback);
            }

            @Override
            public void onError(@NonNull ClearCredentialException e) {
              ResultUtilsKt.completeWithUnitError(
                  callback, new FlutterError("Clear Failed", e.getMessage(), null));
            }
          });
    }

    @Override
    public void clearAuthorizationToken(
        @NonNull String token, @NonNull Function1<? super Result<Unit>, Unit> callback) {
      authorizationClientFactory
          .create(context)
          .clearToken(ClearTokenRequest.builder().setToken(token).build())
          .addOnSuccessListener(unused -> ResultUtilsKt.completeWithUnitSuccess(callback))
          .addOnFailureListener(
              e ->
                  ResultUtilsKt.completeWithUnitError(
                      callback,
                      new FlutterError("clearAuthorizationToken failed", e.getMessage(), null)));
    }

    @Override
    public void authorize(
        @NonNull PlatformAuthorizationRequest params,
        boolean promptIfUnauthorized,
        @NonNull Function1<? super Result<? extends AuthorizeResult>, Unit> callback) {
      try {
        List<Scope> requestedScopes = new ArrayList<>();
        for (String scope : params.getScopes()) {
          requestedScopes.add(new Scope(scope));
        }
        AuthorizationRequest.Builder authorizationRequestBuilder =
            AuthorizationRequest.builder().setRequestedScopes(requestedScopes);
        if (params.getHostedDomain() != null) {
          authorizationRequestBuilder.filterByHostedDomain(params.getHostedDomain());
        }
        if (params.getServerClientIdForForcedRefreshToken() != null) {
          authorizationRequestBuilder.requestOfflineAccess(
              params.getServerClientIdForForcedRefreshToken(), true);
        }
        if (params.getAccountEmail() != null) {
          authorizationRequestBuilder.setAccount(
              new Account(params.getAccountEmail(), GOOGLE_ACCOUNT_TYPE));
        }
        AuthorizationRequest authorizationRequest = authorizationRequestBuilder.build();
        authorizationClientFactory
            .create(context)
            .authorize(authorizationRequest)
            .addOnSuccessListener(
                authorizationResult -> {
                  if (authorizationResult.hasResolution()) {
                    if (promptIfUnauthorized) {
                      Activity activity = getActivity();
                      if (activity == null) {
                        ResultUtilsKt.completeWithAuthorizeFailure(
                            callback,
                            new AuthorizeFailure(
                                AuthorizeFailureType.NO_ACTIVITY, "No activity available", null));
                        return;
                      }
                      // Prompt for access. `callback` will be resolved in onActivityResult.
                      // There must be a pending intent if hasResolution() was true.
                      PendingIntent pendingIntent =
                          Objects.requireNonNull(authorizationResult.getPendingIntent());
                      try {
                        pendingAuthorizationCallback = callback;
                        activity.startIntentSenderForResult(
                            pendingIntent.getIntentSender(),
                            REQUEST_CODE_AUTHORIZE,
                            /* fillInIntent */ null,
                            /* flagsMask */ 0,
                            /* flagsValue */ 0,
                            /* extraFlags */ 0,
                            /* options */ null);
                      } catch (IntentSender.SendIntentException e) {
                        pendingAuthorizationCallback = null;
                        ResultUtilsKt.completeWithAuthorizeFailure(
                            callback,
                            new AuthorizeFailure(
                                AuthorizeFailureType.PENDING_INTENT_EXCEPTION,
                                e.getMessage(),
                                null));
                      }
                    } else {
                      ResultUtilsKt.completeWithAuthorizeFailure(
                          callback,
                          new AuthorizeFailure(AuthorizeFailureType.UNAUTHORIZED, null, null));
                    }
                  } else {
                    ResultUtilsKt.completeWithAuthorizationResult(
                        callback,
                        new PlatformAuthorizationResult(
                            authorizationResult.getAccessToken(),
                            authorizationResult.getServerAuthCode(),
                            authorizationResult.getGrantedScopes()));
                  }
                })
            .addOnFailureListener(
                e ->
                    ResultUtilsKt.completeWithAuthorizeFailure(
                        callback,
                        new AuthorizeFailure(
                            AuthorizeFailureType.AUTHORIZE_FAILURE, e.getMessage(), null)));
      } catch (RuntimeException e) {
        ResultUtilsKt.completeWithAuthorizeFailure(
            callback,
            new AuthorizeFailure(
                AuthorizeFailureType.API_EXCEPTION,
                e.getMessage(),
                "Cause: " + e.getCause() + ", Stacktrace: " + Log.getStackTraceString(e)));
      }
    }

    @Override
    public void revokeAccess(
        @NonNull PlatformRevokeAccessRequest params,
        @NonNull Function1<? super Result<Unit>, Unit> callback) {
      List<Scope> scopes = new ArrayList<>();
      for (String scope : params.getScopes()) {
        scopes.add(new Scope(scope));
      }
      authorizationClientFactory
          .create(context)
          .revokeAccess(
              RevokeAccessRequest.builder()
                  .setAccount(new Account(params.getAccountEmail(), GOOGLE_ACCOUNT_TYPE))
                  .setScopes(scopes)
                  .build())
          .addOnSuccessListener(unused -> ResultUtilsKt.completeWithUnitSuccess(callback))
          .addOnFailureListener(
              e ->
                  ResultUtilsKt.completeWithUnitError(
                      callback, new FlutterError("revokeAccess failed", e.getMessage(), null)));
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
      if (requestCode == REQUEST_CODE_AUTHORIZE) {
        if (pendingAuthorizationCallback != null) {
          try {
            AuthorizationResult authorizationResult =
                authorizationClientFactory.create(context).getAuthorizationResultFromIntent(data);
            ResultUtilsKt.completeWithAuthorizationResult(
                pendingAuthorizationCallback,
                new PlatformAuthorizationResult(
                    authorizationResult.getAccessToken(),
                    authorizationResult.getServerAuthCode(),
                    authorizationResult.getGrantedScopes()));
            return true;
          } catch (ApiException e) {
            ResultUtilsKt.completeWithAuthorizeFailure(
                pendingAuthorizationCallback,
                new AuthorizeFailure(AuthorizeFailureType.API_EXCEPTION, e.getMessage(), null));
          }
          pendingAuthorizationCallback = null;
        } else {
          Log.e("google_sign_in", "Unexpected authorization result callback");
        }
      }
      return false;
    }
  }
}
