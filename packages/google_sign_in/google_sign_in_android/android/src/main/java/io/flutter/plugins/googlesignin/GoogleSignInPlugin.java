// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
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
import com.google.common.base.Joiner;
import com.google.common.base.Strings;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.googlesignin.Messages.FlutterError;
import io.flutter.plugins.googlesignin.Messages.GoogleSignInApi;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;

/** Google sign-in plugin for Flutter. */
public class GoogleSignInPlugin implements FlutterPlugin, ActivityAware {
  private Delegate delegate;
  private @Nullable BinaryMessenger messenger;
  private ActivityPluginBinding activityPluginBinding;

  @SuppressWarnings("deprecation")
  public static void registerWith(
      @NonNull io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    GoogleSignInPlugin instance = new GoogleSignInPlugin();
    instance.initInstance(registrar.messenger(), registrar.context(), new GoogleSignInWrapper());
    instance.setUpRegistrar(registrar);
  }

  @VisibleForTesting
  public void initInstance(
      @NonNull BinaryMessenger messenger,
      @NonNull Context context,
      @NonNull GoogleSignInWrapper googleSignInWrapper) {
    this.messenger = messenger;
    delegate = new Delegate(context, googleSignInWrapper);
    GoogleSignInApi.setup(messenger, delegate);
  }

  @VisibleForTesting
  @SuppressWarnings("deprecation")
  public void setUpRegistrar(@NonNull PluginRegistry.Registrar registrar) {
    delegate.setUpRegistrar(registrar);
  }

  private void dispose() {
    delegate = null;
    if (messenger != null) {
      GoogleSignInApi.setup(messenger, null);
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

  // TODO(stuartmorgan): Remove this, and convert the unit tests to IDelegate tests. This is left
  // here only to allow the existing tests to continue to work unchanged during the Pigeon migration
  // to ensure that the refactoring didn't change any behavior, and is not actually used by the
  // plugin.
  @VisibleForTesting
  void onMethodCall(
      @NonNull io.flutter.plugin.common.MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "init":
        String signInOption = Objects.requireNonNull(call.argument("signInOption"));
        List<String> requestedScopes = Objects.requireNonNull(call.argument("scopes"));
        String hostedDomain = call.argument("hostedDomain");
        String clientId = call.argument("clientId");
        String serverClientId = call.argument("serverClientId");
        boolean forceCodeForRefreshToken =
            Objects.requireNonNull(call.argument("forceCodeForRefreshToken"));
        delegate.init(
            result,
            signInOption,
            requestedScopes,
            hostedDomain,
            clientId,
            serverClientId,
            forceCodeForRefreshToken);
        break;

      case "signInSilently":
        delegate.signInSilently(result);
        break;

      case "signIn":
        delegate.signIn(result);
        break;

      case "getTokens":
        String email = Objects.requireNonNull(call.argument("email"));
        boolean shouldRecoverAuth = Objects.requireNonNull(call.argument("shouldRecoverAuth"));
        delegate.getTokens(result, email, shouldRecoverAuth);
        break;

      case "signOut":
        delegate.signOut(result);
        break;

      case "clearAuthCache":
        String token = Objects.requireNonNull(call.argument("token"));
        delegate.clearAuthCache(result, token);
        break;

      case "disconnect":
        delegate.disconnect(result);
        break;

      case "isSignedIn":
        delegate.isSignedIn(result);
        break;

      case "requestScopes":
        List<String> scopes = Objects.requireNonNull(call.argument("scopes"));
        delegate.requestScopes(result, scopes);
        break;

      default:
        result.notImplemented();
    }
  }

  /**
   * A delegate interface that exposes all of the sign-in functionality for other plugins to use.
   * The below {@link Delegate} implementation should be used by any clients unless they need to
   * override some of these functions, such as for testing.
   */
  public interface IDelegate {
    /** Initializes this delegate so that it is ready to perform other operations. */
    void init(
        @NonNull MethodChannel.Result result,
        @NonNull String signInOption,
        @NonNull List<String> requestedScopes,
        @Nullable String hostedDomain,
        @Nullable String clientId,
        @Nullable String serverClientId,
        boolean forceCodeForRefreshToken);

    /**
     * Returns the account information for the user who is signed in to this app. If no user is
     * signed in, tries to sign the user in without displaying any user interface.
     */
    void signInSilently(@NonNull MethodChannel.Result result);

    /**
     * Signs the user in via the sign-in user interface, including the OAuth consent flow if scopes
     * were requested.
     */
    void signIn(@NonNull MethodChannel.Result result);

    /**
     * Gets an OAuth access token with the scopes that were specified during initialization for the
     * user with the specified email address.
     *
     * <p>If shouldRecoverAuth is set to true and user needs to recover authentication for method to
     * complete, the method will attempt to recover authentication and rerun method.
     */
    void getTokens(
        final @NonNull MethodChannel.Result result,
        final @NonNull String email,
        final boolean shouldRecoverAuth);

    /**
     * Clears the token from any client cache forcing the next {@link #getTokens} call to fetch a
     * new one.
     */
    void clearAuthCache(final @NonNull MethodChannel.Result result, final @NonNull String token);

    /**
     * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
     * sign back in.
     */
    void signOut(@NonNull MethodChannel.Result result);

    /** Signs the user out, and revokes their credentials. */
    void disconnect(@NonNull MethodChannel.Result result);

    /** Checks if there is a signed in user. */
    void isSignedIn(@NonNull MethodChannel.Result result);

    /** Prompts the user to grant an additional Oauth scopes. */
    void requestScopes(
        final @NonNull MethodChannel.Result result, final @NonNull List<String> scopes);
  }

  /**
   * Helper class for supporting the legacy IDelegate interface based on raw method channels, which
   * handles converting any FlutterErrors (or other {@code Throwable}s in case any non- FlutterError
   * exceptions slip through) thrown by the new code paths into {@code error} callbacks.
   *
   * @param <T> The Result type of the result to convert from.
   */
  private abstract static class ErrorConvertingMethodChannelResult<T>
      implements Messages.Result<T> {
    final @NonNull MethodChannel.Result result;

    public ErrorConvertingMethodChannelResult(@NonNull MethodChannel.Result result) {
      this.result = result;
    }

    @Override
    public void error(@NonNull Throwable error) {
      if (error instanceof FlutterError) {
        FlutterError flutterError = (FlutterError) error;
        result.error(flutterError.code, flutterError.getMessage(), flutterError.details);
      } else {
        result.error("exception", error.getMessage(), null);
      }
    }
  }

  /**
   * Helper class for supporting the legacy IDelegate interface based on raw method channels, which
   * handles converting responses from methods that return {@code Messages.UserData}.
   */
  private static class UserDataMethodChannelResult
      extends ErrorConvertingMethodChannelResult<Messages.UserData> {
    public UserDataMethodChannelResult(MethodChannel.Result result) {
      super(result);
    }

    @Override
    public void success(Messages.UserData data) {
      Map<String, Object> response = new HashMap<>();
      response.put("email", data.getEmail());
      response.put("id", data.getId());
      response.put("idToken", data.getIdToken());
      response.put("serverAuthCode", data.getServerAuthCode());
      response.put("displayName", data.getDisplayName());
      if (data.getPhotoUrl() != null) {
        response.put("photoUrl", data.getPhotoUrl());
      }
      result.success(response);
    }
  }

  /**
   * Helper class for supporting the legacy IDelegate interface based on raw method channels, which
   * handles converting responses from methods that return {@code Void}.
   */
  private static class VoidMethodChannelResult extends ErrorConvertingMethodChannelResult<Void> {
    public VoidMethodChannelResult(MethodChannel.Result result) {
      super(result);
    }

    @Override
    public void success(Void unused) {
      result.success(null);
    }
  }

  /**
   * Delegate class that does the work for the Google sign-in plugin. This is exposed as a dedicated
   * class for use in other plugins that wrap basic sign-in functionality.
   *
   * <p>All methods in this class assume that they are run to completion before any other method is
   * invoked. In this context, "run to completion" means that their {@link MethodChannel.Result}
   * argument has been completed (either successfully or in error). This class provides no
   * synchronization constructs to guarantee such behavior; callers are responsible for providing
   * such guarantees.
   */
  // TODO(stuartmorgan): Remove this in a breaking change, replacing it with something using
  // structured types rather than strings and dictionaries left over from the pre-Pigeon method
  // channel implementation.
  public static class Delegate
      implements IDelegate, PluginRegistry.ActivityResultListener, GoogleSignInApi {
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

    private static final String DEFAULT_SIGN_IN = "SignInOption.standard";
    private static final String DEFAULT_GAMES_SIGN_IN = "SignInOption.games";

    private final @NonNull Context context;
    // Only set registrar for v1 embedder.
    @SuppressWarnings("deprecation")
    private PluginRegistry.Registrar registrar;
    // Only set activity for v2 embedder. Always access activity from getActivity() method.
    private @Nullable Activity activity;
    // TODO(stuartmorgan): See whether this can be replaced with background channels.
    private final BackgroundTaskRunner backgroundTaskRunner = new BackgroundTaskRunner(1);
    private final GoogleSignInWrapper googleSignInWrapper;

    private GoogleSignInClient signInClient;
    private List<String> requestedScopes;
    private PendingOperation pendingOperation;

    public Delegate(@NonNull Context context, @NonNull GoogleSignInWrapper googleSignInWrapper) {
      this.context = context;
      this.googleSignInWrapper = googleSignInWrapper;
    }

    @SuppressWarnings("deprecation")
    public void setUpRegistrar(@NonNull PluginRegistry.Registrar registrar) {
      this.registrar = registrar;
      registrar.addActivityResultListener(this);
    }

    public void setActivity(@Nullable Activity activity) {
      this.activity = activity;
    }

    // Only access activity with this method.
    public @Nullable Activity getActivity() {
      return registrar != null ? registrar.activity() : activity;
    }

    private void checkAndSetPendingOperation(
        String method,
        Messages.Result<Messages.UserData> userDataResult,
        Messages.Result<Void> voidResult,
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
        String method, @NonNull Messages.Result<Void> result) {
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
        if (!Strings.isNullOrEmpty(params.getClientId()) && Strings.isNullOrEmpty(serverClientId)) {
          Log.w(
              "google_sign_in",
              "clientId is not supported on Android and is interpreted as serverClientId. "
                  + "Use serverClientId instead to suppress this warning.");
          serverClientId = params.getClientId();
        }

        if (Strings.isNullOrEmpty(serverClientId)) {
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
        if (!Strings.isNullOrEmpty(serverClientId)) {
          optionsBuilder.requestIdToken(serverClientId);
          optionsBuilder.requestServerAuthCode(
              serverClientId, params.getForceCodeForRefreshToken());
        }
        requestedScopes = params.getScopes();
        for (String scope : requestedScopes) {
          optionsBuilder.requestScopes(new Scope(scope));
        }
        if (!Strings.isNullOrEmpty(params.getHostedDomain())) {
          optionsBuilder.setHostedDomain(params.getHostedDomain());
        }

        signInClient = googleSignInWrapper.getClient(context, optionsBuilder.build());
      } catch (Exception e) {
        throw new FlutterError(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      }
    }

    // IDelegate version, for backwards compatibility.
    @Override
    public void init(
        @NonNull MethodChannel.Result result,
        @NonNull String signInOption,
        @NonNull List<String> requestedScopes,
        @Nullable String hostedDomain,
        @Nullable String clientId,
        @Nullable String serverClientId,
        boolean forceCodeForRefreshToken) {
      try {
        Messages.SignInType type;
        switch (signInOption) {
          case DEFAULT_GAMES_SIGN_IN:
            type = Messages.SignInType.GAMES;
            break;
          case DEFAULT_SIGN_IN:
            type = Messages.SignInType.STANDARD;
            break;
          default:
            throw new IllegalStateException("Unknown signInOption");
        }
        init(
            new Messages.InitParams.Builder()
                .setSignInType(type)
                .setScopes(requestedScopes)
                .setHostedDomain(hostedDomain)
                .setClientId(clientId)
                .setServerClientId(serverClientId)
                .setForceCodeForRefreshToken(forceCodeForRefreshToken)
                .build());
        result.success(null);
      } catch (FlutterError e) {
        result.error(e.code, e.getMessage(), e.details);
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

    // IDelegate version, for backwards compatibility.
    @Override
    public void signInSilently(@NonNull MethodChannel.Result result) {
      signInSilently(new UserDataMethodChannelResult(result));
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

    // IDelegate version, for backwards compatibility.
    @Override
    public void signIn(@NonNull MethodChannel.Result result) {
      signIn(new UserDataMethodChannelResult(result));
    }

    /**
     * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
     * sign back in.
     */
    @Override
    public void signOut(@NonNull Messages.Result<Void> result) {
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

    // IDelegate version, for backwards compatibility.
    @Override
    public void signOut(@NonNull MethodChannel.Result result) {
      signOut(new VoidMethodChannelResult(result));
    }

    /** Signs the user out, and revokes their credentials. */
    @Override
    public void disconnect(@NonNull Messages.Result<Void> result) {
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

    // IDelegate version, for backwards compatibility.
    @Override
    public void disconnect(@NonNull MethodChannel.Result result) {
      signOut(new VoidMethodChannelResult(result));
    }

    /** Checks if there is a signed in user. */
    @NonNull
    @Override
    public Boolean isSignedIn() {
      return GoogleSignIn.getLastSignedInAccount(context) != null;
    }

    // IDelegate version, for backwards compatibility.
    @Override
    public void isSignedIn(final @NonNull MethodChannel.Result result) {
      result.success(isSignedIn());
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

    // IDelegate version, for backwards compatibility.
    @Override
    public void requestScopes(@NonNull MethodChannel.Result result, @NonNull List<String> scopes) {
      requestScopes(
          scopes,
          new ErrorConvertingMethodChannelResult<Boolean>(result) {
            @Override
            public void success(Boolean value) {
              result.success(value);
            }
          });
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
      Objects.requireNonNull(pendingOperation.voidResult).success(null);
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
      Messages.Result<?> result;
      if (pendingOperation.userDataResult != null) {
        result = pendingOperation.userDataResult;
      } else if (pendingOperation.boolResult != null) {
        result = pendingOperation.boolResult;
      } else if (pendingOperation.stringResult != null) {
        result = pendingOperation.stringResult;
      } else {
        result = pendingOperation.voidResult;
      }
      Objects.requireNonNull(result).error(new FlutterError(errorCode, errorMessage, null));
      pendingOperation = null;
    }

    private static class PendingOperation {
      final @NonNull String method;
      final @Nullable Messages.Result<Messages.UserData> userDataResult;
      final @Nullable Messages.Result<Void> voidResult;
      final @Nullable Messages.Result<Boolean> boolResult;
      final @Nullable Messages.Result<String> stringResult;
      final @Nullable Object data;

      PendingOperation(
          @NonNull String method,
          @Nullable Messages.Result<Messages.UserData> userDataResult,
          @Nullable Messages.Result<Void> voidResult,
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

    /** Clears the token kept in the client side cache. */
    @Override
    public void clearAuthCache(@NonNull String token, @NonNull Messages.Result<Void> result) {
      Callable<Void> clearTokenTask =
          () -> {
            GoogleAuthUtil.clearToken(context, token);
            return null;
          };

      backgroundTaskRunner.runInBackground(
          clearTokenTask,
          clearTokenFuture -> {
            try {
              result.success(clearTokenFuture.get());
            } catch (ExecutionException e) {
              @Nullable Throwable cause = e.getCause();
              result.error(
                  new FlutterError(
                      ERROR_REASON_EXCEPTION, cause == null ? null : cause.getMessage(), null));
            } catch (InterruptedException e) {
              result.error(new FlutterError(ERROR_REASON_EXCEPTION, e.getMessage(), null));
              Thread.currentThread().interrupt();
            }
          });
    }

    // IDelegate version, for backwards compatibility.
    @Override
    public void clearAuthCache(
        final @NonNull MethodChannel.Result result, final @NonNull String token) {
      clearAuthCache(token, new VoidMethodChannelResult(result));
    }

    /**
     * Gets an OAuth access token with the scopes that were specified during initialization for the
     * user with the specified email address.
     *
     * <p>If shouldRecoverAuth is set to true and user needs to recover authentication for method to
     * complete, the method will attempt to recover authentication and rerun method.
     */
    @Override
    public void getAccessToken(
        @NonNull String email,
        @NonNull Boolean shouldRecoverAuth,
        @NonNull Messages.Result<String> result) {
      Callable<String> getTokenTask =
          () -> {
            Account account = new Account(email, "com.google");
            String scopesStr = "oauth2:" + Joiner.on(' ').join(requestedScopes);
            return GoogleAuthUtil.getToken(context, account, scopesStr);
          };

      // Background task runner has a single thread effectively serializing
      // the getToken calls. 1p apps can then enjoy the token cache if multiple
      // getToken calls are coming in.
      backgroundTaskRunner.runInBackground(
          getTokenTask,
          tokenFuture -> {
            try {
              result.success(tokenFuture.get());
            } catch (ExecutionException e) {
              if (e.getCause() instanceof UserRecoverableAuthException) {
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
                    Intent recoveryIntent =
                        ((UserRecoverableAuthException) e.getCause()).getIntent();
                    activity.startActivityForResult(recoveryIntent, REQUEST_CODE_RECOVER_AUTH);
                  }
                } else {
                  result.error(
                      new FlutterError(ERROR_USER_RECOVERABLE_AUTH, e.getLocalizedMessage(), null));
                }
              } else {
                @Nullable Throwable cause = e.getCause();
                result.error(
                    new FlutterError(
                        ERROR_REASON_EXCEPTION, cause == null ? null : cause.getMessage(), null));
              }
            } catch (InterruptedException e) {
              result.error(new FlutterError(ERROR_REASON_EXCEPTION, e.getMessage(), null));
              Thread.currentThread().interrupt();
            }
          });
    }

    // IDelegate version, for backwards compatibility.
    @Override
    public void getTokens(
        @NonNull final MethodChannel.Result result,
        @NonNull final String email,
        final boolean shouldRecoverAuth) {
      getAccessToken(
          email,
          shouldRecoverAuth,
          new ErrorConvertingMethodChannelResult<String>(result) {
            @Override
            public void success(String value) {
              HashMap<String, String> tokenResult = new HashMap<>();
              tokenResult.put("accessToken", value);
              result.success(tokenResult);
            }
          });
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
