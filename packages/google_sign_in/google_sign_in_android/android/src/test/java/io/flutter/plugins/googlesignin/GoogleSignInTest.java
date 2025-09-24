// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.IntentSender;
import android.content.res.Resources;
import androidx.credentials.ClearCredentialStateRequest;
import androidx.credentials.Credential;
import androidx.credentials.CredentialManager;
import androidx.credentials.CredentialManagerCallback;
import androidx.credentials.CustomCredential;
import androidx.credentials.GetCredentialRequest;
import androidx.credentials.GetCredentialResponse;
import androidx.credentials.PasswordCredential;
import androidx.credentials.exceptions.ClearCredentialException;
import androidx.credentials.exceptions.GetCredentialCancellationException;
import androidx.credentials.exceptions.GetCredentialException;
import androidx.credentials.exceptions.GetCredentialInterruptedException;
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException;
import androidx.credentials.exceptions.GetCredentialUnknownException;
import androidx.credentials.exceptions.GetCredentialUnsupportedException;
import androidx.credentials.exceptions.NoCredentialException;
import com.google.android.gms.auth.api.identity.AuthorizationClient;
import com.google.android.gms.auth.api.identity.AuthorizationRequest;
import com.google.android.gms.auth.api.identity.AuthorizationResult;
import com.google.android.gms.auth.api.identity.ClearTokenRequest;
import com.google.android.gms.auth.api.identity.RevokeAccessRequest;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.libraries.identity.googleid.GetGoogleIdOption;
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption;
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class GoogleSignInTest {
  @Mock Context mockContext;
  @Mock Resources mockResources;
  @Mock Activity mockActivity;
  @Mock ActivityPluginBinding mockActivityPluginBinding;
  @Mock PendingIntent mockAuthorizationIntent;
  @Mock IntentSender mockAuthorizationIntentSender;
  @Mock AuthorizeResult mockAuthorizeResult;
  @Mock CredentialManager mockCredentialManager;
  @Mock AuthorizationClient mockAuthorizationClient;
  @Mock CustomCredential mockGenericCredential;
  @Mock GoogleIdTokenCredential mockGoogleCredential;
  @Mock Task<AuthorizationResult> mockAuthorizationTask;
  @Mock Task<Void> mockVoidTask;

  private GoogleSignInPlugin flutterPlugin;
  // Technically this is not the plugin, but in practice almost all of the functionality is in this
  // class so it is given the simpler name.
  private GoogleSignInPlugin.Delegate plugin;
  private AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);

    // Wire up basic mock functionality that is not test-specific.
    when(mockContext.getResources()).thenReturn(mockResources);
    when(mockGenericCredential.getType())
        .thenReturn(GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL);
    when(mockAuthorizationTask.addOnSuccessListener(any())).thenReturn(mockAuthorizationTask);
    when(mockAuthorizationTask.addOnFailureListener(any())).thenReturn(mockAuthorizationTask);
    when(mockVoidTask.addOnSuccessListener(any())).thenReturn(mockVoidTask);
    when(mockVoidTask.addOnFailureListener(any())).thenReturn(mockVoidTask);
    when(mockAuthorizationIntent.getIntentSender()).thenReturn(mockAuthorizationIntentSender);
    when(mockActivityPluginBinding.getActivity()).thenReturn(mockActivity);

    plugin =
        new GoogleSignInPlugin.Delegate(
            mockContext,
            (Context c) -> mockCredentialManager,
            (Context c) -> mockAuthorizationClient,
            (Credential cred) -> mockGoogleCredential);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void onAttachedToActivity_updatesDelegate() {
    flutterPlugin = new GoogleSignInPlugin();
    flutterPlugin.initWithDelegate(mock(io.flutter.plugin.common.BinaryMessenger.class), plugin);
    flutterPlugin.onAttachedToActivity(mockActivityPluginBinding);

    verify(mockActivityPluginBinding).addActivityResultListener(plugin);
    assertEquals(mockActivity, plugin.getActivity());
  }

  @Test
  public void onDetachedFromActivity_updatesDelegate() {
    flutterPlugin = new GoogleSignInPlugin();
    flutterPlugin.initWithDelegate(mock(io.flutter.plugin.common.BinaryMessenger.class), plugin);
    flutterPlugin.onAttachedToActivity(mockActivityPluginBinding);
    flutterPlugin.onDetachedFromActivity();

    verify(mockActivityPluginBinding).removeActivityResultListener(plugin);
    assertNull(plugin.getActivity());
  }

  @Test
  public void onReattachedToActivityForConfigChanges_updatesDelegate() {
    flutterPlugin = new GoogleSignInPlugin();
    flutterPlugin.initWithDelegate(mock(io.flutter.plugin.common.BinaryMessenger.class), plugin);
    flutterPlugin.onReattachedToActivityForConfigChanges(mockActivityPluginBinding);

    verify(mockActivityPluginBinding).addActivityResultListener(plugin);
    assertEquals(mockActivity, plugin.getActivity());
  }

  @Test
  public void onDetachedFromActivityForConfigChanges_updatesDelegate() {
    flutterPlugin = new GoogleSignInPlugin();
    flutterPlugin.initWithDelegate(mock(io.flutter.plugin.common.BinaryMessenger.class), plugin);
    flutterPlugin.onAttachedToActivity(mockActivityPluginBinding);
    flutterPlugin.onDetachedFromActivityForConfigChanges();

    verify(mockActivityPluginBinding).removeActivityResultListener(plugin);
    assertNull(plugin.getActivity());
  }

  @Test
  public void getGoogleServicesJsonServerClientId_loadsServerClientIdFromResources() {
    final String packageName = "fakePackageName";
    final String serverClientId = "fakeServerClientId";
    final int resourceId = 1;
    when(mockContext.getPackageName()).thenReturn(packageName);
    when(mockResources.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(resourceId);
    when(mockContext.getString(resourceId)).thenReturn(serverClientId);

    final String returnedId = plugin.getGoogleServicesJsonServerClientId();
    assertEquals(serverClientId, returnedId);
  }

  @Test
  public void getGoogleServicesJsonServerClientId_returnsNullIfNotFound() {
    final String packageName = "fakePackageName";
    when(mockContext.getPackageName()).thenReturn(packageName);
    when(mockResources.getIdentifier("default_web_client_id", "string", packageName)).thenReturn(0);

    final String returnedId = plugin.getGoogleServicesJsonServerClientId();
    assertNull(returnedId);
  }

  @Test
  public void getCredential_returnsAuthenticationInfo() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final String displayName = "Jane User";
    final String givenName = "Jane";
    final String familyName = "User";
    final String id = "someId";
    final String idToken = "idToken";
    when(mockGoogleCredential.getDisplayName()).thenReturn(displayName);
    when(mockGoogleCredential.getGivenName()).thenReturn(givenName);
    when(mockGoogleCredential.getFamilyName()).thenReturn(familyName);
    when(mockGoogleCredential.getId()).thenReturn(id);
    when(mockGoogleCredential.getIdToken()).thenReturn(idToken);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialSuccess);
              PlatformGoogleIdTokenCredential credential =
                  ((GetCredentialSuccess) result).getCredential();
              assertEquals(displayName, credential.getDisplayName());
              assertEquals(givenName, credential.getGivenName());
              assertEquals(familyName, credential.getFamilyName());
              assertEquals(id, credential.getId());
              assertEquals(idToken, credential.getIdToken());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onResult(new GetCredentialResponse(mockGenericCredential));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_usesGetSignInWithGoogleOptionForButtonFlow() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            true,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              // No-op, since this test doesn't trigger the getCredentialsAsync callback that would
              // call this.
              return null;
            }));

    ArgumentCaptor<GetCredentialRequest> captor =
        ArgumentCaptor.forClass(GetCredentialRequest.class);
    verify(mockCredentialManager)
        .getCredentialAsync(eq(mockActivity), captor.capture(), any(), any(), any());

    assertEquals(1, captor.getValue().getCredentialOptions().size());
    assertTrue(
        captor.getValue().getCredentialOptions().get(0) instanceof GetSignInWithGoogleOption);
  }

  @Test
  public void getCredential_usesGetGoogleIdOptionForNonButtonFlow() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              // This test doesn't trigger the getCredentialsAsync callback that would call this,
              // so if this is reached something has gone wrong.
              fail();
              return null;
            }));

    ArgumentCaptor<GetCredentialRequest> captor =
        ArgumentCaptor.forClass(GetCredentialRequest.class);
    verify(mockCredentialManager)
        .getCredentialAsync(eq(mockActivity), captor.capture(), any(), any(), any());

    assertEquals(1, captor.getValue().getCredentialOptions().size());
    assertTrue(captor.getValue().getCredentialOptions().get(0) instanceof GetGoogleIdOption);
  }

  @Test
  public void getCredential_passesHostedDomainInButtonFlow() {
    final String hostedDomain = "example.com";
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            true,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            hostedDomain,
            null);

    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              // This test doesn't trigger the getCredentialsAsync callback that would call this,
              // so if this is reached something has gone wrong.
              fail();
              return null;
            }));

    ArgumentCaptor<GetCredentialRequest> captor =
        ArgumentCaptor.forClass(GetCredentialRequest.class);
    verify(mockCredentialManager)
        .getCredentialAsync(eq(mockActivity), captor.capture(), any(), any(), any());

    assertEquals(1, captor.getValue().getCredentialOptions().size());
    assertEquals(
        hostedDomain,
        ((GetSignInWithGoogleOption) captor.getValue().getCredentialOptions().get(0))
            .getHostedDomainFilter());
  }

  @Test
  public void getCredential_passesNonceInButtonFlow() {
    final String nonce = "nonce";
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            true,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            nonce);

    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              // This test doesn't trigger the getCredentialsAsync callback that would call this,
              // so if this is reached something has gone wrong.
              fail();
              return null;
            }));

    ArgumentCaptor<GetCredentialRequest> captor =
        ArgumentCaptor.forClass(GetCredentialRequest.class);
    verify(mockCredentialManager)
        .getCredentialAsync(eq(mockActivity), captor.capture(), any(), any(), any());

    assertEquals(1, captor.getValue().getCredentialOptions().size());
    assertEquals(
        nonce,
        ((GetSignInWithGoogleOption) captor.getValue().getCredentialOptions().get(0)).getNonce());
  }

  @Test
  public void getCredential_passesNonceInNonButtonFlow() {
    final String nonce = "nonce";
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            nonce);

    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              // This test doesn't trigger the getCredentialsAsync callback that would call this,
              // so if this is reached something has gone wrong.
              fail();
              return null;
            }));

    ArgumentCaptor<GetCredentialRequest> captor =
        ArgumentCaptor.forClass(GetCredentialRequest.class);
    verify(mockCredentialManager)
        .getCredentialAsync(eq(mockActivity), captor.capture(), any(), any(), any());

    assertEquals(1, captor.getValue().getCredentialOptions().size());
    assertEquals(
        nonce, ((GetGoogleIdOption) captor.getValue().getCredentialOptions().get(0)).getNonce());
  }

  @Test
  public void getCredential_reportsMissingActivity() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(null);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.NO_ACTIVITY, failure.getType());
              return null;
            }));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsMissingServerClientId() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false, new GetCredentialRequestGoogleIdOptionParams(false, false), null, null, null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.MISSING_SERVER_CLIENT_ID, failure.getType());
              return null;
            }));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsWrongCredentialType() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    // PasswordCredential is used because it's easy to create without mocking; all that matters is
    // that it's not a CustomCredential of type TYPE_GOOGLE_ID_TOKEN_CREDENTIAL.
    callbackCaptor
        .getValue()
        .onResult(new GetCredentialResponse(new PasswordCredential("wrong", "type")));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsCancellation() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.CANCELED, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onError(new GetCredentialCancellationException());
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsInterrupted() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.INTERRUPTED, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onError(new GetCredentialInterruptedException());
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsProviderConfigurationIssue() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(
                  GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onError(new GetCredentialProviderConfigurationException());
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsUnsupported() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.UNSUPPORTED, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onError(new GetCredentialUnsupportedException());
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsNoCredential() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.NO_CREDENTIAL, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onError(new NoCredentialException());
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void getCredential_reportsUnknown() {
    GetCredentialRequestParams params =
        new GetCredentialRequestParams(
            false,
            new GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.setActivity(mockActivity);
    plugin.getCredential(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              GetCredentialResult result = reply.getOrNull();
              assertTrue(result instanceof GetCredentialFailure);
              GetCredentialFailure failure = (GetCredentialFailure) result;
              assertEquals(GetCredentialFailureType.UNKNOWN, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>
        callbackCaptor = ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any(GetCredentialRequest.class),
            any(),
            any(),
            callbackCaptor.capture());

    callbackCaptor.getValue().onError(new GetCredentialUnknownException());
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_passesNullParamaters() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    final String accessToken = "accessToken";
    final String serverAuthCode = "serverAuthCode";
    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);

    plugin.authorize(
        params,
        false,
        ResultCompat.asCompatCallback(
            reply -> {
              // This test doesn't trigger the getCredentialsAsync callback that would call this,
              // so if this is reached something has gone wrong.
              fail();
              return null;
            }));

    ArgumentCaptor<AuthorizationRequest> authRequestCaptor =
        ArgumentCaptor.forClass(AuthorizationRequest.class);
    verify(mockAuthorizationClient).authorize(authRequestCaptor.capture());

    AuthorizationRequest request = authRequestCaptor.getValue();
    assertNull(request.getHostedDomain());
    assertNull(request.getServerClientId());
    assertNull(request.getAccount());
  }

  @Test
  public void authorize_passesOptionalParameters() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    final String hostedDomain = "example.com";
    final String accountEmail = "someone@example.com";
    final String serverClientId = "serverClientId";
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, hostedDomain, accountEmail, serverClientId);

    final String accessToken = "accessToken";
    final String serverAuthCode = "serverAuthCode";
    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);

    plugin.authorize(
        params,
        false,
        ResultCompat.asCompatCallback(
            reply -> {
              // This test doesn't trigger the getCredentialsAsync callback that would call this,
              // so if this is reached something has gone wrong.
              fail();
              return null;
            }));

    ArgumentCaptor<AuthorizationRequest> authRequestCaptor =
        ArgumentCaptor.forClass(AuthorizationRequest.class);
    verify(mockAuthorizationClient).authorize(authRequestCaptor.capture());

    AuthorizationRequest request = authRequestCaptor.getValue();
    assertEquals(hostedDomain, request.getHostedDomain());
    assertEquals(serverClientId, request.getServerClientId());
    // Account is mostly opaque, so just verify that one was set if an email was provided.
    assertNotNull(request.getAccount());
  }

  @Test
  public void authorize_returnsImmediateResult() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    final String accessToken = "accessToken";
    final String serverAuthCode = "serverAuthCode";
    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        false,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof PlatformAuthorizationResult);
              PlatformAuthorizationResult auth = (PlatformAuthorizationResult) result;
              assertEquals(accessToken, auth.getAccessToken());
              assertEquals(serverAuthCode, auth.getServerAuthCode());
              assertEquals(scopes, auth.getGrantedScopes());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<AuthorizationResult>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture());

    callbackCaptor
        .getValue()
        .onSuccess(
            new AuthorizationResult(serverAuthCode, accessToken, "idToken", scopes, null, null));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_reportsImmediateException() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    when(mockAuthorizationClient.authorize(any())).thenThrow(new RuntimeException());

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        false,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof AuthorizeFailure);
              AuthorizeFailure failure = (AuthorizeFailure) result;
              assertEquals(AuthorizeFailureType.API_EXCEPTION, failure.getType());
              return null;
            }));

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_reportsFailureIfUnauthorizedAndNoPromptAllowed() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);

    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        false,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof AuthorizeFailure);
              AuthorizeFailure failure = (AuthorizeFailure) result;
              assertEquals(AuthorizeFailureType.UNAUTHORIZED, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<AuthorizationResult>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture());

    callbackCaptor
        .getValue()
        .onSuccess(
            new AuthorizationResult(null, null, null, scopes, null, mockAuthorizationIntent));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_reportsFailureIfUnauthorizedAndNoActivity() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);

    plugin.setActivity(null);
    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        true,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof AuthorizeFailure);
              AuthorizeFailure failure = (AuthorizeFailure) result;
              assertEquals(AuthorizeFailureType.NO_ACTIVITY, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<AuthorizationResult>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture());

    callbackCaptor
        .getValue()
        .onSuccess(
            new AuthorizationResult(null, null, null, scopes, null, mockAuthorizationIntent));
    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_returnsPostIntentResult() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    final String accessToken = "accessToken";
    final String serverAuthCode = "serverAuthCode";
    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);
    try {
      when(mockAuthorizationClient.getAuthorizationResultFromIntent(any()))
          .thenReturn(
              new AuthorizationResult(serverAuthCode, accessToken, "idToken", scopes, null, null));
    } catch (ApiException e) {
      fail();
    }

    plugin.setActivity(mockActivity);
    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        true,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof PlatformAuthorizationResult);
              PlatformAuthorizationResult auth = (PlatformAuthorizationResult) result;
              assertEquals(accessToken, auth.getAccessToken());
              assertEquals(serverAuthCode, auth.getServerAuthCode());
              assertEquals(scopes, auth.getGrantedScopes());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<AuthorizationResult>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture());
    callbackCaptor
        .getValue()
        .onSuccess(
            new AuthorizationResult(null, null, null, scopes, null, mockAuthorizationIntent));
    try {
      verify(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntent.getIntentSender(),
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null);
    } catch (IntentSender.SendIntentException e) {
      fail();
    }
    // Simulate the UI flow completing. The intent data can be null here because the mock of
    // mockAuthorizationClient.getAuthorizationResultFromIntent above ignores the parameter.
    plugin.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_reportsPendingIntentException() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);
    try {
      doThrow(new IntentSender.SendIntentException())
          .when(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntentSender,
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null);
    } catch (IntentSender.SendIntentException e) {
      fail();
    }

    plugin.setActivity(mockActivity);
    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        true,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof AuthorizeFailure);
              AuthorizeFailure failure = (AuthorizeFailure) result;
              assertEquals(AuthorizeFailureType.PENDING_INTENT_EXCEPTION, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<AuthorizationResult>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture());
    callbackCaptor
        .getValue()
        .onSuccess(
            new AuthorizationResult(null, null, null, scopes, null, mockAuthorizationIntent));

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void authorize_reportsPostIntentException() {
    final List<String> scopes = new ArrayList<>(Arrays.asList("scope1", "scope1"));
    PlatformAuthorizationRequest params =
        new PlatformAuthorizationRequest(scopes, null, null, null);

    when(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask);
    try {
      when(mockAuthorizationClient.getAuthorizationResultFromIntent(any()))
          .thenThrow(new ApiException(Status.RESULT_INTERNAL_ERROR));
    } catch (ApiException e) {
      fail();
    }

    plugin.setActivity(mockActivity);
    final Boolean[] callbackCalled = new Boolean[1];
    plugin.authorize(
        params,
        true,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              // This failure is a structured return value, not an exception.
              assertTrue(reply.isSuccess());
              AuthorizeResult result = reply.getOrNull();
              assertTrue(result instanceof AuthorizeFailure);
              AuthorizeFailure failure = (AuthorizeFailure) result;
              assertEquals(AuthorizeFailureType.API_EXCEPTION, failure.getType());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<AuthorizationResult>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture());
    callbackCaptor
        .getValue()
        .onSuccess(
            new AuthorizationResult(null, null, null, scopes, null, mockAuthorizationIntent));
    try {
      verify(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntent.getIntentSender(),
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null);
    } catch (IntentSender.SendIntentException e) {
      fail();
    }
    // Simulate the UI flow completing. The intent data can be null here because the mock of
    // mockAuthorizationClient.getAuthorizationResultFromIntent above ignores the parameter.
    plugin.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void clearCredentialState_reportsSuccess() {
    plugin.clearCredentialState(
        ResultCompat.asCompatCallback(
            reply -> {
              assertTrue(reply.isSuccess());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<Void, ClearCredentialException>> callbackCaptor =
        ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .clearCredentialStateAsync(
            any(ClearCredentialStateRequest.class), any(), any(), callbackCaptor.capture());

    callbackCaptor.getValue().onResult(null);
  }

  @Test
  public void clearCredentialState_reportsFailure() {
    plugin.clearCredentialState(
        ResultCompat.asCompatCallback(
            reply -> {
              assertTrue(reply.isFailure());
              return null;
            }));

    @SuppressWarnings("unchecked")
    ArgumentCaptor<CredentialManagerCallback<Void, ClearCredentialException>> callbackCaptor =
        ArgumentCaptor.forClass(CredentialManagerCallback.class);
    verify(mockCredentialManager)
        .clearCredentialStateAsync(
            any(ClearCredentialStateRequest.class), any(), any(), callbackCaptor.capture());

    callbackCaptor.getValue().onError(mock(ClearCredentialException.class));
  }

  @Test
  public void revokeAccess_callsClient() {
    final List<String> scopes = new ArrayList<>(List.of("openid"));
    final String accountEmail = "someone@example.com";
    PlatformRevokeAccessRequest params = new PlatformRevokeAccessRequest(accountEmail, scopes);
    when(mockAuthorizationClient.revokeAccess(any())).thenReturn(mockVoidTask);
    plugin.revokeAccess(
        params,
        ResultCompat.asCompatCallback(
            reply -> {
              return null;
            }));

    ArgumentCaptor<RevokeAccessRequest> requestCaptor =
        ArgumentCaptor.forClass(RevokeAccessRequest.class);
    verify(mockAuthorizationClient).revokeAccess(requestCaptor.capture());

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<Void>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockVoidTask).addOnSuccessListener(callbackCaptor.capture());
    callbackCaptor.getValue().onSuccess(null);

    RevokeAccessRequest request = requestCaptor.getValue();
    assertEquals(scopes.size(), request.getScopes().size());
    assertEquals(scopes.get(0), request.getScopes().get(0).getScopeUri());
    // Account is mostly opaque, so just verify that one was set.
    assertNotNull(request.getAccount());
  }

  @Test
  public void clearAuthorizationToken_callsClient() {
    final String testToken = "testToken";
    when(mockAuthorizationClient.clearToken(any())).thenReturn(mockVoidTask);
    plugin.clearAuthorizationToken(
        testToken,
        ResultCompat.asCompatCallback(
            reply -> {
              return null;
            }));

    ArgumentCaptor<ClearTokenRequest> authRequestCaptor =
        ArgumentCaptor.forClass(ClearTokenRequest.class);
    verify(mockAuthorizationClient).clearToken(authRequestCaptor.capture());

    @SuppressWarnings("unchecked")
    ArgumentCaptor<OnSuccessListener<Void>> callbackCaptor =
        ArgumentCaptor.forClass(OnSuccessListener.class);
    verify(mockVoidTask).addOnSuccessListener(callbackCaptor.capture());
    callbackCaptor.getValue().onSuccess(null);

    ClearTokenRequest request = authRequestCaptor.getValue();
    assertEquals(testToken, request.getToken());
  }
}
