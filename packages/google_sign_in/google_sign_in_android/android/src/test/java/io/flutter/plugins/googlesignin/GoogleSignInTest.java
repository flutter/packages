// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.Task;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.googlesignin.Messages.FlutterError;
import io.flutter.plugins.googlesignin.Messages.InitParams;
import java.util.Collections;
import java.util.List;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

public class GoogleSignInTest {
  @Mock Context mockContext;
  @Mock Resources mockResources;
  @Mock Activity mockActivity;
  @Mock BinaryMessenger mockMessenger;
  @Spy Messages.Result<Void> voidResult;
  @Spy Messages.Result<Boolean> boolResult;
  @Spy Messages.Result<Messages.UserData> userDataResult;
  @Mock GoogleSignInWrapper mockGoogleSignIn;
  @Mock GoogleSignInAccount account;
  @Mock GoogleSignInClient mockClient;
  @Mock Task<GoogleSignInAccount> mockSignInTask;

  @SuppressWarnings("deprecation")
  @Mock
  PluginRegistry.Registrar mockRegistrar;

  private GoogleSignInPlugin.Delegate plugin;
  private AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    when(mockRegistrar.messenger()).thenReturn(mockMessenger);
    when(mockRegistrar.context()).thenReturn(mockContext);
    when(mockRegistrar.activity()).thenReturn(mockActivity);
    when(mockContext.getResources()).thenReturn(mockResources);
    plugin = new GoogleSignInPlugin.Delegate(mockRegistrar.context(), mockGoogleSignIn);
    plugin.setUpRegistrar(mockRegistrar);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void requestScopes_ResultErrorIfAccountIsNull() {
    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(null);

    plugin.requestScopes(Collections.singletonList("requestedScope"), boolResult);

    ArgumentCaptor<Throwable> resultCaptor = ArgumentCaptor.forClass(Throwable.class);
    verify(boolResult).error(resultCaptor.capture());
    FlutterError error = (FlutterError) resultCaptor.getValue();
    Assert.assertEquals("sign_in_required", error.code);
    Assert.assertEquals("No account to grant scopes.", error.getMessage());
  }

  @Test
  public void requestScopes_ResultTrueIfAlreadyGranted() {
    Scope requestedScope = new Scope("requestedScope");
    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(true);

    plugin.requestScopes(Collections.singletonList("requestedScope"), boolResult);

    verify(boolResult).success(true);
  }

  @Test
  public void requestScopes_RequestsPermissionIfNotGranted() {
    Scope requestedScope = new Scope("requestedScope");
    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.requestScopes(Collections.singletonList("requestedScope"), boolResult);

    verify(mockGoogleSignIn)
        .requestPermissions(mockActivity, 53295, account, new Scope[] {requestedScope});
  }

  @Test
  public void requestScopes_ReturnsFalseIfPermissionDenied() {
    Scope requestedScope = new Scope("requestedScope");
    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.requestScopes(Collections.singletonList("requestedScope"), boolResult);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE,
        Activity.RESULT_CANCELED,
        new Intent());

    verify(boolResult).success(false);
  }

  @Test
  public void requestScopes_ReturnsTrueIfPermissionGranted() {
    Scope requestedScope = new Scope("requestedScope");
    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.requestScopes(Collections.singletonList("requestedScope"), boolResult);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());

    verify(boolResult).success(true);
  }

  @Test
  public void requestScopes_mayBeCalledRepeatedly_ifAlreadyGranted() {
    List<String> requestedScopes = Collections.singletonList("requestedScope");
    Scope requestedScope = new Scope("requestedScope");
    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.requestScopes(requestedScopes, boolResult);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());
    plugin.requestScopes(requestedScopes, boolResult);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());

    verify(boolResult, times(2)).success(true);
  }

  @Test
  public void requestScopes_mayBeCalledRepeatedly_ifNotSignedIn() {
    List<String> requestedScopes = Collections.singletonList("requestedScope");
    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(null);

    plugin.requestScopes(requestedScopes, boolResult);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());
    plugin.requestScopes(requestedScopes, boolResult);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());

    ArgumentCaptor<Throwable> resultCaptor = ArgumentCaptor.forClass(Throwable.class);
    verify(boolResult, times(2)).error(resultCaptor.capture());
    List<Throwable> errors = resultCaptor.getAllValues();
    Assert.assertEquals(2, errors.size());
    FlutterError error = (FlutterError) errors.get(0);
    Assert.assertEquals("sign_in_required", error.code);
    Assert.assertEquals("No account to grant scopes.", error.getMessage());
    error = (FlutterError) errors.get(1);
    Assert.assertEquals("sign_in_required", error.code);
    Assert.assertEquals("No account to grant scopes.", error.getMessage());
  }

  @Test(expected = IllegalStateException.class)
  public void signInThrowsWithoutActivity() {
    final GoogleSignInPlugin.Delegate plugin =
        new GoogleSignInPlugin.Delegate(mock(Context.class), mock(GoogleSignInWrapper.class));

    plugin.signIn(userDataResult);
  }

  @Test
  public void signInSilentlyThatImmediatelyCompletesWithoutResultFinishesWithError()
      throws ApiException {
    final String clientId = "fakeClientId";
    InitParams params = buildInitParams(clientId, null);
    initAndAssertServerClientId(params, clientId);

    ApiException exception =
        new ApiException(new Status(CommonStatusCodes.SIGN_IN_REQUIRED, "Error text"));
    when(mockClient.silentSignIn()).thenReturn(mockSignInTask);
    when(mockSignInTask.isComplete()).thenReturn(true);
    when(mockSignInTask.getResult(ApiException.class)).thenThrow(exception);

    plugin.signInSilently(userDataResult);
    ArgumentCaptor<Throwable> resultCaptor = ArgumentCaptor.forClass(Throwable.class);
    verify(userDataResult).error(resultCaptor.capture());
    FlutterError error = (FlutterError) resultCaptor.getValue();
    Assert.assertEquals("sign_in_required", error.code);
    Assert.assertEquals(
        "com.google.android.gms.common.api.ApiException: 4: Error text", error.getMessage());
  }

  @Test
  public void init_LoadsServerClientIdFromResources() {
    final String packageName = "fakePackageName";
    final String serverClientId = "fakeServerClientId";
    final int resourceId = 1;
    InitParams params = buildInitParams(null, null);
    when(mockContext.getPackageName()).thenReturn(packageName);
    when(mockResources.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(resourceId);
    when(mockContext.getString(resourceId)).thenReturn(serverClientId);
    initAndAssertServerClientId(params, serverClientId);
  }

  @Test
  public void init_InterpretsClientIdAsServerClientId() {
    final String clientId = "fakeClientId";
    InitParams params = buildInitParams(clientId, null);
    initAndAssertServerClientId(params, clientId);
  }

  @Test
  public void init_ForwardsServerClientId() {
    final String serverClientId = "fakeServerClientId";
    InitParams params = buildInitParams(null, serverClientId);
    initAndAssertServerClientId(params, serverClientId);
  }

  @Test
  public void init_IgnoresClientIdIfServerClientIdIsProvided() {
    final String clientId = "fakeClientId";
    final String serverClientId = "fakeServerClientId";
    InitParams params = buildInitParams(clientId, serverClientId);
    initAndAssertServerClientId(params, serverClientId);
  }

  @Test
  public void init_PassesForceCodeForRefreshTokenFalseWithServerClientIdParameter() {
    InitParams params = buildInitParams("fakeClientId", "fakeServerClientId", false);

    initAndAssertForceCodeForRefreshToken(params, false);
  }

  @Test
  public void init_PassesForceCodeForRefreshTokenTrueWithServerClientIdParameter() {
    InitParams params = buildInitParams("fakeClientId", "fakeServerClientId", true);

    initAndAssertForceCodeForRefreshToken(params, true);
  }

  @Test
  public void init_PassesForceCodeForRefreshTokenFalseWithServerClientIdFromResources() {
    final String packageName = "fakePackageName";
    final String serverClientId = "fakeServerClientId";
    final int resourceId = 1;
    InitParams params = buildInitParams(null, null, false);
    when(mockContext.getPackageName()).thenReturn(packageName);
    when(mockResources.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(resourceId);
    when(mockContext.getString(resourceId)).thenReturn(serverClientId);

    initAndAssertForceCodeForRefreshToken(params, false);
  }

  @Test
  public void init_PassesForceCodeForRefreshTokenTrueWithServerClientIdFromResources() {
    final String packageName = "fakePackageName";
    final String serverClientId = "fakeServerClientId";
    final int resourceId = 1;
    InitParams params = buildInitParams(null, null, true);
    when(mockContext.getPackageName()).thenReturn(packageName);
    when(mockResources.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(resourceId);
    when(mockContext.getString(resourceId)).thenReturn(serverClientId);

    initAndAssertForceCodeForRefreshToken(params, true);
  }

  public void initAndAssertServerClientId(InitParams params, String serverClientId) {
    ArgumentCaptor<GoogleSignInOptions> optionsCaptor =
        ArgumentCaptor.forClass(GoogleSignInOptions.class);
    when(mockGoogleSignIn.getClient(any(Context.class), optionsCaptor.capture()))
        .thenReturn(mockClient);
    plugin.init(params);
    Assert.assertEquals(serverClientId, optionsCaptor.getValue().getServerClientId());
  }

  public void initAndAssertForceCodeForRefreshToken(
      InitParams params, boolean forceCodeForRefreshToken) {
    ArgumentCaptor<GoogleSignInOptions> optionsCaptor =
        ArgumentCaptor.forClass(GoogleSignInOptions.class);
    when(mockGoogleSignIn.getClient(any(Context.class), optionsCaptor.capture()))
        .thenReturn(mockClient);
    plugin.init(params);
    Assert.assertEquals(
        forceCodeForRefreshToken, optionsCaptor.getValue().isForceCodeForRefreshToken());
  }

  private static InitParams buildInitParams(String clientId, String serverClientId) {
    return buildInitParams(
        Messages.SignInType.STANDARD, Collections.emptyList(), clientId, serverClientId, false);
  }

  private static InitParams buildInitParams(
      String clientId, String serverClientId, boolean forceCodeForRefreshToken) {
    return buildInitParams(
        Messages.SignInType.STANDARD,
        Collections.emptyList(),
        clientId,
        serverClientId,
        forceCodeForRefreshToken);
  }

  private static InitParams buildInitParams(
      Messages.SignInType signInType,
      List<String> scopes,
      String clientId,
      String serverClientId,
      boolean forceCodeForRefreshToken) {
    InitParams.Builder builder = new InitParams.Builder();
    builder.setSignInType(signInType);
    builder.setScopes(scopes);
    if (clientId != null) {
      builder.setClientId(clientId);
    }
    if (serverClientId != null) {
      builder.setServerClientId(serverClientId);
    }
    builder.setForceCodeForRefreshToken(forceCodeForRefreshToken);
    return builder.build();
  }
}
