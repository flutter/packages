// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlesignin

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.content.IntentSender.SendIntentException
import android.content.res.Resources
import android.os.CancellationSignal
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.PasswordCredential
import androidx.credentials.exceptions.ClearCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.GetCredentialInterruptedException
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException
import androidx.credentials.exceptions.GetCredentialUnknownException
import androidx.credentials.exceptions.GetCredentialUnsupportedException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.gms.auth.api.identity.AuthorizationClient
import com.google.android.gms.auth.api.identity.AuthorizationRequest
import com.google.android.gms.auth.api.identity.AuthorizationResult
import com.google.android.gms.auth.api.identity.ClearTokenRequest
import com.google.android.gms.auth.api.identity.RevokeAccessRequest
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Status
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.Task
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import java.lang.AutoCloseable
import java.util.concurrent.Executor
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import org.mockito.kotlin.any
import org.mockito.kotlin.anyOrNull
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class GoogleSignInTest {
  var mockContext: Context = mock()

  var mockResources: Resources = mock()

  var mockActivity: Activity = mock()

  var mockActivityPluginBinding: ActivityPluginBinding = mock()

  var mockAuthorizationIntent: PendingIntent = mock()

  var mockAuthorizationIntentSender: IntentSender = mock()

  var mockCredentialManager: CredentialManager = mock()

  var mockAuthorizationClient: AuthorizationClient = mock()

  var mockGenericCredential: CustomCredential = mock()

  var mockGoogleCredential: GoogleIdTokenCredential = mock()

  var mockAuthorizationTask: Task<AuthorizationResult> = mock()

  var mockVoidTask: Task<Void> = mock()

  // Technically this is not the plugin, but in practice almost all of the functionality is in this
  // class so it is given the simpler name.
  private lateinit var plugin: GoogleSignInPlugin.Delegate
  private lateinit var mockCloseable: AutoCloseable

  @Before
  fun setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this)

    // Wire up basic mock functionality that is not test-specific.
    whenever(mockContext.resources).thenReturn(mockResources)
    whenever(mockGenericCredential.type)
        .thenReturn(GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL)
    whenever(mockAuthorizationTask.addOnSuccessListener(any())).thenReturn(mockAuthorizationTask)
    whenever(mockAuthorizationTask.addOnFailureListener(any())).thenReturn(mockAuthorizationTask)
    whenever(mockVoidTask.addOnSuccessListener(any())).thenReturn(mockVoidTask)
    whenever(mockVoidTask.addOnFailureListener(any())).thenReturn(mockVoidTask)
    whenever(mockAuthorizationIntent.intentSender).thenReturn(mockAuthorizationIntentSender)
    whenever(mockActivityPluginBinding.activity).thenReturn(mockActivity)

    plugin =
        GoogleSignInPlugin.Delegate(
            mockContext,
            { mockCredentialManager },
            { mockAuthorizationClient },
            { mockGoogleCredential })
  }

  @After
  @Throws(Exception::class)
  fun tearDown() {
    mockCloseable.close()
  }

  @Test
  fun onAttachedToActivity_updatesDelegate() {
    val flutterPlugin = GoogleSignInPlugin()
    flutterPlugin.initWithDelegate(mock<BinaryMessenger>(), plugin)
    flutterPlugin.onAttachedToActivity(mockActivityPluginBinding)

    verify(mockActivityPluginBinding).addActivityResultListener(plugin)
    Assert.assertEquals(mockActivity, plugin.activity)
  }

  @Test
  fun onDetachedFromActivity_updatesDelegate() {
    val flutterPlugin = GoogleSignInPlugin()
    flutterPlugin.initWithDelegate(mock<BinaryMessenger>(), plugin)
    flutterPlugin.onAttachedToActivity(mockActivityPluginBinding)
    flutterPlugin.onDetachedFromActivity()

    verify(mockActivityPluginBinding).removeActivityResultListener(plugin)
    Assert.assertNull(plugin.activity)
  }

  @Test
  fun onReattachedToActivityForConfigChanges_updatesDelegate() {
    val flutterPlugin = GoogleSignInPlugin()
    flutterPlugin.initWithDelegate(mock<BinaryMessenger>(), plugin)
    flutterPlugin.onReattachedToActivityForConfigChanges(mockActivityPluginBinding)

    verify(mockActivityPluginBinding).addActivityResultListener(plugin)
    Assert.assertEquals(mockActivity, plugin.activity)
  }

  @Test
  fun onDetachedFromActivityForConfigChanges_updatesDelegate() {
    val flutterPlugin = GoogleSignInPlugin()
    flutterPlugin.initWithDelegate(mock<BinaryMessenger>(), plugin)
    flutterPlugin.onAttachedToActivity(mockActivityPluginBinding)
    flutterPlugin.onDetachedFromActivityForConfigChanges()

    verify(mockActivityPluginBinding).removeActivityResultListener(plugin)
    Assert.assertNull(plugin.activity)
  }

  @Test
  fun getGoogleServicesJsonServerClientId_loadsServerClientIdFromResources() {
    val packageName = "fakePackageName"
    val serverClientId = "fakeServerClientId"
    val resourceId = 1
    whenever(mockContext.packageName).thenReturn(packageName)
    whenever(mockResources.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(resourceId)
    whenever(mockContext.getString(resourceId)).thenReturn(serverClientId)

    val returnedId = plugin.getGoogleServicesJsonServerClientId()
    Assert.assertEquals(serverClientId, returnedId)
  }

  @Test
  fun getGoogleServicesJsonServerClientId_returnsNullIfNotFound() {
    val packageName = "fakePackageName"
    whenever(mockContext.packageName).thenReturn(packageName)
    whenever(mockResources.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(0)

    val returnedId = plugin.getGoogleServicesJsonServerClientId()
    Assert.assertNull(returnedId)
  }

  @Test
  fun getCredential_returnsAuthenticationInfo() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    val displayName = "Jane User"
    val givenName = "Jane"
    val familyName = "User"
    val email = "someEmail"
    val uniqueId = "someAccountId"
    val idToken = "idToken"
    whenever(mockGoogleCredential.displayName).thenReturn(displayName)
    whenever(mockGoogleCredential.givenName).thenReturn(givenName)
    whenever(mockGoogleCredential.familyName).thenReturn(familyName)
    whenever(mockGoogleCredential.email).thenReturn(email)
    whenever(mockGoogleCredential.uniqueId).thenReturn(uniqueId)
    whenever(mockGoogleCredential.idToken).thenReturn(idToken)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialSuccess)
      val credential = (result as GetCredentialSuccess).credential
      Assert.assertEquals(displayName, credential.displayName)
      Assert.assertEquals(givenName, credential.givenName)
      Assert.assertEquals(familyName, credential.familyName)
      Assert.assertEquals(email, credential.email)
      Assert.assertEquals(idToken, credential.idToken)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onResult(GetCredentialResponse(mockGenericCredential))
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_usesGetSignInWithGoogleOptionForButtonFlow() {
    val params =
        GetCredentialRequestParams(
            true,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    plugin.activity = mockActivity
    plugin.getCredential(params) {}

    val captor = argumentCaptor<GetCredentialRequest>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            captor.capture(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            any<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>())

    Assert.assertEquals(1, captor.firstValue.credentialOptions.size.toLong())
    Assert.assertTrue(captor.firstValue.credentialOptions[0] is GetSignInWithGoogleOption)
  }

  @Test
  fun getCredential_usesGetGoogleIdOptionForNonButtonFlow() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    plugin.activity = mockActivity
    plugin.getCredential(params) {
      // This test doesn't trigger the getCredentialsAsync callback that would call this,
      // so if this is reached something has gone wrong.
      Assert.fail()
    }

    val captor = argumentCaptor<GetCredentialRequest>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            captor.capture(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            any<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>())

    Assert.assertEquals(1, captor.firstValue.credentialOptions.size.toLong())
    Assert.assertTrue(captor.firstValue.credentialOptions[0] is GetGoogleIdOption)
  }

  @Test
  fun getCredential_passesHostedDomainInButtonFlow() {
    val hostedDomain = "example.com"
    val params =
        GetCredentialRequestParams(
            true,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            hostedDomain,
            null)

    plugin.activity = mockActivity
    plugin.getCredential(params) {
      // This test doesn't trigger the getCredentialsAsync callback that would call this,
      // so if this is reached something has gone wrong.
      Assert.fail()
    }

    val captor = argumentCaptor<GetCredentialRequest>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            captor.capture(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            any<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>())

    Assert.assertEquals(1, captor.firstValue.credentialOptions.size.toLong())
    Assert.assertEquals(
        hostedDomain,
        (captor.firstValue.credentialOptions[0] as GetSignInWithGoogleOption).hostedDomainFilter)
  }

  @Test
  fun getCredential_passesNonceInButtonFlow() {
    val nonce = "nonce"
    val params =
        GetCredentialRequestParams(
            true,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            nonce)

    plugin.activity = mockActivity
    plugin.getCredential(params) {
      // This test doesn't trigger the getCredentialsAsync callback that would call this,
      // so if this is reached something has gone wrong.
      Assert.fail()
    }

    val captor = argumentCaptor<GetCredentialRequest>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            captor.capture(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            any<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>())

    Assert.assertEquals(1, captor.firstValue.credentialOptions.size.toLong())
    Assert.assertEquals(
        nonce, (captor.firstValue.credentialOptions[0] as GetSignInWithGoogleOption).nonce)
  }

  @Test
  fun getCredential_passesNonceInNonButtonFlow() {
    val nonce = "nonce"
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            nonce)

    plugin.activity = mockActivity
    plugin.getCredential(params) {
      // This test doesn't trigger the getCredentialsAsync callback that would call this,
      // so if this is reached something has gone wrong.
      Assert.fail()
    }

    val captor = argumentCaptor<GetCredentialRequest>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            captor.capture(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            any<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>())

    Assert.assertEquals(1, captor.firstValue.credentialOptions.size.toLong())
    Assert.assertEquals(nonce, (captor.firstValue.credentialOptions[0] as GetGoogleIdOption).nonce)
  }

  @Test
  fun getCredential_reportsMissingActivity() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = null
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.NO_ACTIVITY, failure.type)
    }
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsMissingServerClientId() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            null,
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.MISSING_SERVER_CLIENT_ID, failure.type)
    }
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsWrongCredentialType() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    // PasswordCredential is used because it's easy to create without mocking; all that matters is
    // that it's not a CustomCredential of type TYPE_GOOGLE_ID_TOKEN_CREDENTIAL.
    callbackCaptor.firstValue.onResult(GetCredentialResponse(PasswordCredential("wrong", "type")))
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsCancellation() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.CANCELED, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(GetCredentialCancellationException())
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsInterrupted() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.INTERRUPTED, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(GetCredentialInterruptedException())
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsProviderConfigurationIssue() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(GetCredentialProviderConfigurationException())
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsUnsupported() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.UNSUPPORTED, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(GetCredentialUnsupportedException())
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsNoCredential() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.NO_CREDENTIAL, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(NoCredentialException())
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun getCredential_reportsUnknown() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(
                filterToAuthorized = false, autoSelectEnabled = false),
            "serverClientId",
            null,
            null)

    var callbackCalled = false
    plugin.activity = mockActivity
    plugin.getCredential(params) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is GetCredentialFailure)
      val failure = result as GetCredentialFailure
      Assert.assertEquals(GetCredentialFailureType.UNKNOWN, failure.type)
    }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<GetCredentialResponse, GetCredentialException>>()
    verify(mockCredentialManager)
        .getCredentialAsync(
            eq(mockActivity),
            any<GetCredentialRequest>(),
            anyOrNull<CancellationSignal>(),
            any<Executor>(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(GetCredentialUnknownException())
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun authorize_passesNullParameters() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)

    plugin.authorize(params, false) {
      // This test doesn't trigger the getCredentialsAsync callback that would call this,
      // so if this is reached something has gone wrong.
      Assert.fail()
    }

    val authRequestCaptor = argumentCaptor<AuthorizationRequest>()
    verify(mockAuthorizationClient).authorize(authRequestCaptor.capture())

    val request = authRequestCaptor.firstValue
    Assert.assertNull(request.hostedDomain)
    Assert.assertNull(request.serverClientId)
    Assert.assertNull(request.account)
  }

  @Test
  fun authorize_passesOptionalParameters() {
    val scopes = mutableListOf("scope1", "scope1")
    val hostedDomain = "example.com"
    val accountEmail = "someone@example.com"
    val serverClientId = "serverClientId"
    val params = PlatformAuthorizationRequest(scopes, hostedDomain, accountEmail, serverClientId)

    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)

    plugin.authorize(params, false) {
      // This test doesn't trigger the getCredentialsAsync callback that would call this,
      // so if this is reached something has gone wrong.
      Assert.fail()
    }

    val authRequestCaptor = argumentCaptor<AuthorizationRequest>()
    verify(mockAuthorizationClient).authorize(authRequestCaptor.capture())

    val request = authRequestCaptor.firstValue
    Assert.assertEquals(hostedDomain, request.hostedDomain)
    Assert.assertEquals(serverClientId, request.serverClientId)
    // Account is mostly opaque, so just verify that one was set if an email was provided.
    Assert.assertNotNull(request.account)
  }

  @Test
  fun authorize_returnsImmediateResult() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    val accessToken = "accessToken"
    val serverAuthCode = "serverAuthCode"
    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)

    var callbackCalled = false
    plugin.authorize(params, false) { reply ->
      callbackCalled = true
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is PlatformAuthorizationResult)
      val auth = result as PlatformAuthorizationResult
      Assert.assertEquals(accessToken, auth.accessToken)
      Assert.assertEquals(serverAuthCode, auth.serverAuthCode)
      Assert.assertEquals(scopes, auth.grantedScopes)
    }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())

    callbackCaptor.firstValue.onSuccess(
        mockSuccessAuthorizationResult(serverAuthCode, accessToken, scopes))
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun authorize_reportsImmediateException() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    whenever(mockAuthorizationClient.authorize(any())).thenThrow(RuntimeException())

    var callbackCalled = false
    plugin.authorize(params, false) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is AuthorizeFailure)
      val failure = result as AuthorizeFailure
      Assert.assertEquals(AuthorizeFailureType.API_EXCEPTION, failure.type)
    }

    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun authorize_reportsFailureIfUnauthorizedAndNoPromptAllowed() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)

    var callbackCalled = false
    plugin.authorize(params, false) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is AuthorizeFailure)
      val failure = result as AuthorizeFailure
      Assert.assertEquals(AuthorizeFailureType.UNAUTHORIZED, failure.type)
    }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())

    callbackCaptor.firstValue.onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun authorize_reportsFailureIfUnauthorizedAndNoActivity() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)

    plugin.activity = null
    var callbackCalled = false
    plugin.authorize(params, true) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is AuthorizeFailure)
      val failure = result as AuthorizeFailure
      Assert.assertEquals(AuthorizeFailureType.NO_ACTIVITY, failure.type)
    }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())

    callbackCaptor.firstValue.onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun authorize_returnsPostIntentResult() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    val accessToken = "accessToken"
    val serverAuthCode = "serverAuthCode"
    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)
    val successResult = mockSuccessAuthorizationResult(serverAuthCode, accessToken, scopes)
    try {
      whenever(mockAuthorizationClient.getAuthorizationResultFromIntent(anyOrNull<Intent>()))
          .thenReturn(successResult)
    } catch (_: ApiException) {
      Assert.fail()
    }

    plugin.activity = mockActivity
    var callbackCalled = false
    plugin.authorize(params, true) { reply ->
      callbackCalled = true
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is PlatformAuthorizationResult)
      val auth = result as PlatformAuthorizationResult
      Assert.assertEquals(accessToken, auth.accessToken)
      Assert.assertEquals(serverAuthCode, auth.serverAuthCode)
      Assert.assertEquals(scopes, auth.grantedScopes)
    }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())
    callbackCaptor.firstValue.onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    try {
      verify(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntent.intentSender,
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null)
    } catch (_: SendIntentException) {
      Assert.fail()
    }
    // Simulate the UI flow completing. The intent data can be null here because
    // mockAuthorizationClient.getAuthorizationResultFromIntent above ignores the parameter.
    plugin.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)

    Assert.assertTrue(callbackCalled)
  }

  // Regression test for https://github.com/flutter/flutter/issues/188062
  // A re-delivered authorization activity result for REQUEST_CODE_AUTHORIZE (e.g. after a
  // configuration change or process death) must not resolve the same callback twice, which would
  // throw IllegalStateException ("Reply already submitted") on the real Pigeon reply.
  @Test
  fun authorize_ignoresDuplicateActivityResult() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    val accessToken = "accessToken"
    val serverAuthCode = "serverAuthCode"
    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)
    val successResult = mockSuccessAuthorizationResult(serverAuthCode, accessToken, scopes)
    try {
      whenever(mockAuthorizationClient.getAuthorizationResultFromIntent(anyOrNull<Intent>()))
          .thenReturn(successResult)
    } catch (_: ApiException) {
      Assert.fail()
    }

    plugin.activity = mockActivity
    var callbackCount = 0
    plugin.authorize(params, true) { callbackCount += 1 }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())
    callbackCaptor.firstValue.onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))

    // The first delivery resolves the authorization and is consumed.
    val firstHandled =
        plugin.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)
    // A duplicate/re-delivered result for the same request code must be ignored, not re-resolved.
    val secondHandled =
        plugin.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)

    Assert.assertTrue(firstHandled)
    Assert.assertFalse(secondHandled)
    Assert.assertEquals(1, callbackCount)
  }

  @Test
  fun authorize_reportsPendingIntentException() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)
    try {
      Mockito.doThrow(SendIntentException())
          .`when`(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntentSender,
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null)
    } catch (_: SendIntentException) {
      Assert.fail()
    }

    plugin.activity = mockActivity
    var callbackCalled = false
    plugin.authorize(params, true) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is AuthorizeFailure)
      val failure = result as AuthorizeFailure
      Assert.assertEquals(AuthorizeFailureType.PENDING_INTENT_EXCEPTION, failure.type)
    }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())
    callbackCaptor.firstValue.onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))

    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun authorize_reportsPostIntentException() {
    val scopes = mutableListOf("scope1", "scope1")
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    whenever(mockAuthorizationClient.authorize(any())).thenReturn(mockAuthorizationTask)
    try {
      whenever(mockAuthorizationClient.getAuthorizationResultFromIntent(anyOrNull()))
          .thenThrow(ApiException(Status.RESULT_INTERNAL_ERROR))
    } catch (_: ApiException) {
      Assert.fail()
    }

    plugin.activity = mockActivity
    var callbackCalled = false
    plugin.authorize(params, true) { reply ->
      callbackCalled = true
      // This failure is a structured return value, not an exception.
      Assert.assertTrue(reply.isSuccess)
      val result = reply.getOrNull()
      Assert.assertTrue(result is AuthorizeFailure)
      val failure = result as AuthorizeFailure
      Assert.assertEquals(AuthorizeFailureType.API_EXCEPTION, failure.type)
    }

    val callbackCaptor = argumentCaptor<OnSuccessListener<AuthorizationResult>>()
    verify(mockAuthorizationTask).addOnSuccessListener(callbackCaptor.capture())
    callbackCaptor.firstValue.onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    try {
      verify(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntent.intentSender,
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null)
    } catch (_: SendIntentException) {
      Assert.fail()
    }
    // Simulate the UI flow completing. The intent data can be null here because
    // mockAuthorizationClient.getAuthorizationResultFromIntent above ignores the parameter.
    plugin.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)

    Assert.assertTrue(callbackCalled)
  }

  @Test
  fun clearCredentialState_reportsSuccess() {
    plugin.clearCredentialState { reply -> Assert.assertTrue(reply.isSuccess) }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<Void?, ClearCredentialException>>()
    verify(mockCredentialManager)
        .clearCredentialStateAsync(
            any<ClearCredentialStateRequest>(),
            anyOrNull<CancellationSignal>(),
            any(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onResult(null)
  }

  @Test
  fun clearCredentialState_reportsFailure() {
    plugin.clearCredentialState { reply -> Assert.assertTrue(reply.isFailure) }

    val callbackCaptor =
        argumentCaptor<CredentialManagerCallback<Void?, ClearCredentialException>>()
    verify(mockCredentialManager)
        .clearCredentialStateAsync(
            any<ClearCredentialStateRequest>(),
            anyOrNull<CancellationSignal>(),
            any(),
            callbackCaptor.capture())

    callbackCaptor.firstValue.onError(mock<ClearCredentialException>())
  }

  @Test
  fun revokeAccess_callsClient() {
    val scopes = mutableListOf("openid")
    val accountEmail = "someone@example.com"
    val params = PlatformRevokeAccessRequest(accountEmail, scopes)
    whenever(mockAuthorizationClient.revokeAccess(any())).thenReturn(mockVoidTask)
    plugin.revokeAccess(params) {}

    val requestCaptor = argumentCaptor<RevokeAccessRequest>()
    verify(mockAuthorizationClient).revokeAccess(requestCaptor.capture())

    val callbackCaptor = argumentCaptor<OnSuccessListener<Void>>()
    verify(mockVoidTask).addOnSuccessListener(callbackCaptor.capture())
    callbackCaptor.firstValue.onSuccess(null)

    val request = requestCaptor.firstValue
    Assert.assertEquals(scopes.size.toLong(), request.scopes.size.toLong())
    Assert.assertEquals(scopes[0], request.scopes[0].scopeUri)
    // Account is mostly opaque, so just verify that one was set.
    Assert.assertNotNull(request.account)
  }

  @Test
  fun clearAuthorizationToken_callsClient() {
    val testToken = "testToken"
    whenever(mockAuthorizationClient.clearToken(any())).thenReturn(mockVoidTask)
    plugin.clearAuthorizationToken(testToken) {}

    val authRequestCaptor = argumentCaptor<ClearTokenRequest>()
    verify(mockAuthorizationClient).clearToken(authRequestCaptor.capture())

    val callbackCaptor = argumentCaptor<OnSuccessListener<Void>>()
    verify(mockVoidTask).addOnSuccessListener(callbackCaptor.capture())
    callbackCaptor.firstValue.onSuccess(null)

    val request = authRequestCaptor.firstValue
    Assert.assertEquals(testToken, request.token)
  }

  private fun mockSuccessAuthorizationResult(
      serverAuthCode: String,
      accessToken: String,
      scopes: MutableList<String>?
  ): AuthorizationResult {
    val mockResult = mock<AuthorizationResult>()
    whenever(mockResult.hasResolution()).thenReturn(false)
    whenever(mockResult.accessToken).thenReturn(accessToken)
    whenever(mockResult.serverAuthCode).thenReturn(serverAuthCode)
    whenever(mockResult.grantedScopes).thenReturn(scopes)
    return mockResult
  }

  private fun mockResolutionAuthorizationResult(pendingIntent: PendingIntent): AuthorizationResult {
    val mockResult = mock<AuthorizationResult>()
    whenever(mockResult.hasResolution()).thenReturn(true)
    whenever(mockResult.pendingIntent).thenReturn(pendingIntent)
    return mockResult
  }
}
