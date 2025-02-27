// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.auth.UserRecoverableAuthException;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.tasks.RuntimeExecutionException;
import com.google.android.gms.tasks.Task;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.googlesignin.Messages.FlutterError;
import io.flutter.plugins.googlesignin.Messages.GoogleSignInApi;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/** Google sign-in plugin for Flutter. */
public class GoogleSignInPlugin implements FlutterPlugin, ActivityAware {
  private Delegate delegate;
  private @Nullable BinaryMessenger messenger;
  private ActivityPluginBinding activityPluginBinding;

  @VisibleForTesting
  public void initInstance(
      @NonNull BinaryMessenger messenger,
      @NonNull Context context,
      @NonNull GoogleSignInWrapper googleSignInWrapper) {
    this.messenger = messenger;
    delegate = new Delegate(context, googleSignInWrapper);
    GoogleSignInApi.setUp(messenger, delegate);
  }

  private void dispose() {
    delegate = null;
    if (messenger != null) {
      GoogleSignInApi.setUp(messenger, null);
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
    initInstance(
        binding.getBinaryMessenger(), binding.getApplicationContext(), new GoogleSignInWrapper());
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

  /**
   * Delegate class that does the work for the Google sign-in plugin. This is exposed as a dedicated
   * class for use in other plugins that wrap basic sign-in functionality.
   *
   * <p>All methods in this class assume that they are run to completion before any other method is
   * invoked. In this context, "run to completion" means that their {@link Messages.Result} argument
   * has been completed (either successfully or in error). This class provides no synchronization
   * constructs to guarantee such behavior; callers are responsible for providing such guarantees.
   */
  public static class Delegate implements PluginRegistry.ActivityResultListener, GoogleSignInApi {
    private static final int REQUEST_CODE_SIGNIN = 53293;
    private static final int REQUEST_CODE_RECOVER_AUTH = 53294;
    @VisibleForTesting static final int REQUEST_CODE_REQUEST_SCOPE = 53295;

    private static final String ERROR_REASON_EXCEPTION = "exception";
    private static final String ERROR_REASON_STATUS = "status";
    // These error codes must match with ones declared on iOS and Dart sides.
    private static final String ERROR_REASON_SIGN_IN_CANCELED = "sign_in_canceled";
    private static final String ERROR_REASON_SIGN_IN_REQUIRED = "sign_in_required";
    private static final String ERROR_REASON_NETWORK_ERROR = "network_error";
    private static final String ERROR_REASON_SIGN_IN_FAILED = "sign_in_failed";
    private static final String ERROR_FAILURE_TO_RECOVER_AUTH = "failed_to_recover_auth";
    private static final String ERROR_USER_RECOVERABLE_AUTH = "user_recoverable_auth";

    private final @NonNull Context context;
    // Only set activity for v2 embedder. Always access activity from getActivity() method.
    private @Nullable Activity activity;
    private final GoogleSignInWrapper googleSignInWrapper;

    private GoogleSignInClient signInClient;
    private List<String> requestedScopes;
    private PendingOperation pendingOperation;

    public Delegate(@NonNull Context context, @NonNull GoogleSignInWrapper googleSignInWrapper) {
      this.context = context;
      this.googleSignInWrapper = googleSignInWrapper;
    }

    public void setActivity(@Nullable Activity activity) {
      this.activity = activity;
    }

    // Only access activity with this method.
    public @Nullable Activity getActivity() {
      return activity;
    }

    private void checkAndSetPendingOperation(
        String method,
        Messages.Result<Messages.UserData> userDataResult,
        Messages.VoidResult voidResult,
        Messages.Result<Boolean> boolResult,
        Messages.Result<String> stringResult,
        Object data) {
      if (pendingOperation != null) {
        throw new IllegalStateException(
            "Concurrent operations detected: " + pendingOperation.method + ", " + method);
      }
      pendingOperation =
          new PendingOperation(method, userDataResult, voidResult, boolResult, stringResult, data);
    }

    private void checkAndSetPendingSignInOperation(
        String method, @NonNull Messages.Result<Messages.UserData> result) {
      checkAndSetPendingOperation(method, result, null, null, null, null);
    }

    private void checkAndSetPendingVoidOperation(
        String method, @NonNull Messages.VoidResult result) {
      checkAndSetPendingOperation(method, null, result, null, null, null);
    }

    private void checkAndSetPendingBoolOperation(
        String method, @NonNull Messages.Result<Boolean> result) {
      checkAndSetPendingOperation(method, null, null, result, null, null);
    }

    private void checkAndSetPendingStringOperation(
        String method, @NonNull Messages.Result<String> result, @Nullable Object data) {
      checkAndSetPendingOperation(method, null, null, null, result, data);
    }

    private void checkAndSetPendingAccessTokenOperation(
        String method, Messages.Result<String> result, @NonNull Object data) {
      checkAndSetPendingStringOperation(method, result, data);
    }

    /**
     * Initializes this delegate so that it is ready to perform other operations. The Dart code
     * guarantees that this will be called and completed before any other methods are invoked.
     */
    @Override
    public void init(@NonNull Messages.InitParams params) {
      try {
        GoogleSignInOptions.Builder optionsBuilder;

        switch (params.getSignInType()) {
          case GAMES:
            optionsBuilder =
                new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN);
            break;
          case STANDARD:
            optionsBuilder =
                new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail();
            break;
          default:
            throw new IllegalStateException("Unknown signInOption");
        }

        // The clientId parameter is not supported on Android.
        // Android apps are identified by their package name and the SHA-1 of their signing key.
        // https://developers.google.com/android/guides/client-auth
        // https://developers.google.com/identity/sign-in/android/start#configure-a-google-api-project
        String serverClientId = params.getServerClientId();
        if (!isNullOrEmpty(params.getClientId()) && isNullOrEmpty(serverClientId)) {
          Log.w(
              "google_sign_in",
              "clientId is not supported on Android and is interpreted as serverClientId. "
                  + "Use serverClientId instead to suppress this warning.");
          serverClientId = params.getClientId();
        }

        if (isNullOrEmpty(serverClientId)) {
          // Only requests a clientId if google-services.json was present and parsed
          // by the google-services Gradle script.
          // TODO(jackson): Perhaps we should provide a mechanism to override this
          // behavior.
          @SuppressLint("DiscouragedApi")
          int webClientIdIdentifier =
              context
                  .getResources()
                  .getIdentifier("default_web_client_id", "string", context.getPackageName());
          if (webClientIdIdentifier != 0) {
            serverClientId = context.getString(webClientIdIdentifier);
          }
        }
        if (!isNullOrEmpty(serverClientId)) {
          optionsBuilder.requestIdToken(serverClientId);
          optionsBuilder.requestServerAuthCode(
              serverClientId, params.getForceCodeForRefreshToken());
        }
        requestedScopes = params.getScopes();
        for (String scope : requestedScopes) {
          optionsBuilder.requestScopes(new Scope(scope));
        }
        if (!isNullOrEmpty(params.getHostedDomain())) {
          optionsBuilder.setHostedDomain(params.getHostedDomain());
        }

        String forceAccountName = params.getForceAccountName();
        if (!isNullOrEmpty(forceAccountName)) {
          optionsBuilder.setAccountName(forceAccountName);
        }

        signInClient = googleSignInWrapper.getClient(context, optionsBuilder.build());
      } catch (Exception e) {
        throw new FlutterError(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      }
    }

    /**
     * Returns the account information for the user who is signed in to this app. If no user is
     * signed in, tries to sign the user in without displaying any user interface.
     */
    @Override
    public void signInSilently(@NonNull Messages.Result<Messages.UserData> result) {
      checkAndSetPendingSignInOperation("signInSilently", result);
      Task<GoogleSignInAccount> task = signInClient.silentSignIn();
      if (task.isComplete()) {
        // There's immediate result available.
        onSignInResult(task);
      } else {
        task.addOnCompleteListener(this::onSignInResult);
      }
    }

    /**
     * Signs the user in via the sign-in user interface, including the OAuth consent flow if scopes
     * were requested.
     */
    @Override
    public void signIn(@NonNull Messages.Result<Messages.UserData> result) {
      if (getActivity() == null) {
        throw new IllegalStateException("signIn needs a foreground activity");
      }
      checkAndSetPendingSignInOperation("signIn", result);

      Intent signInIntent = signInClient.getSignInIntent();
      getActivity().startActivityForResult(signInIntent, REQUEST_CODE_SIGNIN);
    }

    /**
     * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
     * sign back in.
     */
    @Override
    public void signOut(@NonNull Messages.VoidResult result) {
      checkAndSetPendingVoidOperation("signOut", result);

      signInClient
          .signOut()
          .addOnCompleteListener(
              task -> {
                if (task.isSuccessful()) {
                  finishWithSuccess();
                } else {
                  finishWithError(ERROR_REASON_STATUS, "Failed to signout.");
                }
              });
    }

    /** Signs the user out, and revokes their credentials. */
    @Override
    public void disconnect(@NonNull Messages.VoidResult result) {
      checkAndSetPendingVoidOperation("disconnect", result);

      signInClient
          .revokeAccess()
          .addOnCompleteListener(
              task -> {
                if (task.isSuccessful()) {
                  finishWithSuccess();
                } else {
                  finishWithError(ERROR_REASON_STATUS, "Failed to disconnect.");
                }
              });
    }

    /** Checks if there is a signed in user. */
    @NonNull
    @Override
    public Boolean isSignedIn() {
      return GoogleSignIn.getLastSignedInAccount(context) != null;
    }

    @Override
    public void requestScopes(
        @NonNull List<String> scopes, @NonNull Messages.Result<Boolean> result) {
      checkAndSetPendingBoolOperation("requestScopes", result);

      GoogleSignInAccount account = googleSignInWrapper.getLastSignedInAccount(context);
      if (account == null) {
        finishWithError(ERROR_REASON_SIGN_IN_REQUIRED, "No account to grant scopes.");
        return;
      }

      List<Scope> wrappedScopes = new ArrayList<>();

      for (String scope : scopes) {
        Scope wrappedScope = new Scope(scope);
        if (!googleSignInWrapper.hasPermissions(account, wrappedScope)) {
          wrappedScopes.add(wrappedScope);
        }
      }

      if (wrappedScopes.isEmpty()) {
        finishWithBoolean(true);
        return;
      }

      googleSignInWrapper.requestPermissions(
          getActivity(), REQUEST_CODE_REQUEST_SCOPE, account, wrappedScopes.toArray(new Scope[0]));
    }

    private void onSignInResult(Task<GoogleSignInAccount> completedTask) {
      try {
        GoogleSignInAccount account = completedTask.getResult(ApiException.class);
        onSignInAccount(account);
      } catch (ApiException e) {
        // Forward all errors and let Dart decide how to handle.
        String errorCode = errorCodeForStatus(e.getStatusCode());
        finishWithError(errorCode, e.toString());
      } catch (RuntimeExecutionException e) {
        finishWithError(ERROR_REASON_EXCEPTION, e.toString());
      }
    }

    private void onSignInAccount(GoogleSignInAccount account) {
      final Messages.UserData.Builder builder =
          new Messages.UserData.Builder()
              // TODO(stuartmorgan): Test with games sign-in; according to docs these could be null
              // as the games login request is currently constructed, but the public Dart API
              // assumes they are non-null, so the sign-in query may need to change to
              // include requestEmail() and requestProfile().
              .setEmail(account.getEmail())
              .setId(account.getId())
              .setIdToken(account.getIdToken())
              .setServerAuthCode(account.getServerAuthCode())
              .setDisplayName(account.getDisplayName());
      if (account.getPhotoUrl() != null) {
        builder.setPhotoUrl(account.getPhotoUrl().toString());
      }
      finishWithUserData(builder.build());
    }

    private String errorCodeForStatus(int statusCode) {
      switch (statusCode) {
        case GoogleSignInStatusCodes.SIGN_IN_CANCELLED:
          return ERROR_REASON_SIGN_IN_CANCELED;
        case CommonStatusCodes.SIGN_IN_REQUIRED:
          return ERROR_REASON_SIGN_IN_REQUIRED;
        case CommonStatusCodes.NETWORK_ERROR:
          return ERROR_REASON_NETWORK_ERROR;
        case GoogleSignInStatusCodes.SIGN_IN_CURRENTLY_IN_PROGRESS:
        case GoogleSignInStatusCodes.SIGN_IN_FAILED:
        case CommonStatusCodes.INVALID_ACCOUNT:
        case CommonStatusCodes.INTERNAL_ERROR:
        default:
          return ERROR_REASON_SIGN_IN_FAILED;
      }
    }

    private void finishWithSuccess() {
      Objects.requireNonNull(pendingOperation.voidResult).success();
      pendingOperation = null;
    }

    private void finishWithBoolean(Boolean value) {
      Objects.requireNonNull(pendingOperation.boolResult).success(value);
      pendingOperation = null;
    }

    private void finishWithUserData(Messages.UserData data) {
      Objects.requireNonNull(pendingOperation.userDataResult).success(data);
      pendingOperation = null;
    }

    private void finishWithError(String errorCode, String errorMessage) {
      if (pendingOperation.voidResult != null) {
        Objects.requireNonNull(pendingOperation.voidResult)
            .error(new FlutterError(errorCode, errorMessage, null));
      } else {
        Messages.Result<?> result;
        if (pendingOperation.userDataResult != null) {
          result = pendingOperation.userDataResult;
        } else if (pendingOperation.boolResult != null) {
          result = pendingOperation.boolResult;
        } else {
          result = pendingOperation.stringResult;
        }
        Objects.requireNonNull(result).error(new FlutterError(errorCode, errorMessage, null));
      }
      pendingOperation = null;
    }

    private static boolean isNullOrEmpty(@Nullable String s) {
      return s == null || s.isEmpty();
    }

    private static class PendingOperation {
      final @NonNull String method;
      final @Nullable Messages.Result<Messages.UserData> userDataResult;
      final @Nullable Messages.VoidResult voidResult;
      final @Nullable Messages.Result<Boolean> boolResult;
      final @Nullable Messages.Result<String> stringResult;
      final @Nullable Object data;

      PendingOperation(
          @NonNull String method,
          @Nullable Messages.Result<Messages.UserData> userDataResult,
          @Nullable Messages.VoidResult voidResult,
          @Nullable Messages.Result<Boolean> boolResult,
          @Nullable Messages.Result<String> stringResult,
          @Nullable Object data) {
        assert (userDataResult != null
            || voidResult != null
            || boolResult != null
            || stringResult != null);
        this.method = method;
        this.userDataResult = userDataResult;
        this.voidResult = voidResult;
        this.boolResult = boolResult;
        this.stringResult = stringResult;
        this.data = data;
      }
    }

    /**
     * Clears the token kept in the client side cache.
     *
     * <p>Runs on a background task queue.
     */
    @Override
    public void clearAuthCache(@NonNull String token) {
      try {
        GoogleAuthUtil.clearToken(context, token);
      } catch (Exception e) {
        throw new FlutterError(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      }
    }

    /**
     * Gets an OAuth access token with the scopes that were specified during initialization for the
     * user with the specified email address.
     *
     * <p>Runs on a background task queue.
     *
     * <p>If shouldRecoverAuth is set to true and user needs to recover authentication for method to
     * complete, the method will attempt to recover authentication and rerun method.
     */
    @Override
    public void getAccessToken(
        @NonNull String email,
        @NonNull Boolean shouldRecoverAuth,
        @NonNull Messages.Result<String> result) {
      try {
        Account account = new Account(email, "com.google");
        String scopesStr = "oauth2:" + String.join(" ", requestedScopes);
        String token = GoogleAuthUtil.getToken(context, account, scopesStr);
        result.success(token);
      } catch (UserRecoverableAuthException e) {
        // This method runs in a background task queue; hop to the main thread for interactions with
        // plugin state and activities.
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(
            () -> {
              if (shouldRecoverAuth && pendingOperation == null) {
                Activity activity = getActivity();
                if (activity == null) {
                  result.error(
                      new FlutterError(
                          ERROR_USER_RECOVERABLE_AUTH,
                          "Cannot recover auth because app is not in foreground. "
                              + e.getLocalizedMessage(),
                          null));
                } else {
                  checkAndSetPendingAccessTokenOperation("getTokens", result, email);
                  Intent recoveryIntent = e.getIntent();
                  activity.startActivityForResult(recoveryIntent, REQUEST_CODE_RECOVER_AUTH);
                }
              } else {
                result.error(
                    new FlutterError(ERROR_USER_RECOVERABLE_AUTH, e.getLocalizedMessage(), null));
              }
            });
      } catch (Exception e) {
        result.error(new FlutterError(ERROR_REASON_EXCEPTION, e.getMessage(), null));
      }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
      if (pendingOperation == null) {
        return false;
      }
      switch (requestCode) {
        case REQUEST_CODE_RECOVER_AUTH:
          if (resultCode == Activity.RESULT_OK) {
            // Recover the previous result and data and attempt to get tokens again.
            Messages.Result<String> result = Objects.requireNonNull(pendingOperation.stringResult);
            String email = (String) Objects.requireNonNull(pendingOperation.data);
            pendingOperation = null;
            getAccessToken(email, false, result);
          } else {
            finishWithError(
                ERROR_FAILURE_TO_RECOVER_AUTH, "Failed attempt to recover authentication");
          }
          return true;
        case REQUEST_CODE_SIGNIN:
          // Whether resultCode is OK or not, the Task returned by GoogleSigIn will determine
          // failure with better specifics which are extracted in onSignInResult method.
          if (data != null) {
            onSignInResult(GoogleSignIn.getSignedInAccountFromIntent(data));
          } else {
            // data is null which is highly unusual for a sign in result.
            finishWithError(ERROR_REASON_SIGN_IN_FAILED, "Signin failed");
          }
          return true;
        case REQUEST_CODE_REQUEST_SCOPE:
          finishWithBoolean(resultCode == Activity.RESULT_OK);
          return true;
        default:
          return false;
      }
    }
  }
}
