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
import androidx.credentials.Credential
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
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.Task
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlesignin.GoogleSignInPlugin.AuthorizationClientFactory
import io.flutter.plugins.googlesignin.GoogleSignInPlugin.CredentialManagerFactory
import io.flutter.plugins.googlesignin.GoogleSignInPlugin.GoogleIdCredentialConverter
import java.lang.AutoCloseable
import java.util.concurrent.Executor
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations

class GoogleSignInTest {
  @Mock var mockContext: Context? = null

  @Mock var mockResources: Resources? = null

  @Mock var mockActivity: Activity? = null

  @Mock var mockActivityPluginBinding: ActivityPluginBinding? = null

  @Mock var mockAuthorizationIntent: PendingIntent? = null

  @Mock var mockAuthorizationIntentSender: IntentSender? = null

  @Mock var mockCredentialManager: CredentialManager? = null

  @Mock var mockAuthorizationClient: AuthorizationClient? = null

  @Mock var mockGenericCredential: CustomCredential? = null

  @Mock var mockGoogleCredential: GoogleIdTokenCredential? = null

  @Mock var mockAuthorizationTask: Task<AuthorizationResult?>? = null

  @Mock var mockVoidTask: Task<Void?>? = null

  private var flutterPlugin: GoogleSignInPlugin? = null

  // Technically this is not the plugin, but in practice almost all of the functionality is in this
  // class so it is given the simpler name.
  private var plugin: GoogleSignInPlugin.Delegate? = null
  private var mockCloseable: AutoCloseable? = null

  @Before
  fun setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this)

    // Wire up basic mock functionality that is not test-specific.
    Mockito.`when`<Resources?>(mockContext!!.getResources()).thenReturn(mockResources)
    Mockito.`when`<String?>(mockGenericCredential!!.type)
        .thenReturn(GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL)
    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationTask!!.addOnSuccessListener(
                ArgumentMatchers.any<OnSuccessListener<in AuthorizationResult?>?>()))
        .thenReturn(mockAuthorizationTask)
    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationTask!!.addOnFailureListener(
                ArgumentMatchers.any<OnFailureListener?>()))
        .thenReturn(mockAuthorizationTask)
    Mockito.`when`<Task<Void?>?>(
            mockVoidTask!!.addOnSuccessListener(
                ArgumentMatchers.any<OnSuccessListener<in Void?>?>()))
        .thenReturn(mockVoidTask)
    Mockito.`when`<Task<Void?>?>(
            mockVoidTask!!.addOnFailureListener(ArgumentMatchers.any<OnFailureListener?>()))
        .thenReturn(mockVoidTask)
    Mockito.`when`<IntentSender?>(mockAuthorizationIntent!!.getIntentSender())
        .thenReturn(mockAuthorizationIntentSender)
    Mockito.`when`<Activity?>(mockActivityPluginBinding!!.getActivity()).thenReturn(mockActivity)

    plugin =
        GoogleSignInPlugin.Delegate(
            mockContext!!,
            CredentialManagerFactory { c: Context -> mockCredentialManager!! },
            AuthorizationClientFactory { c: Context -> mockAuthorizationClient!! },
            GoogleIdCredentialConverter { cred: Credential -> mockGoogleCredential!! })
  }

  @After
  @Throws(Exception::class)
  fun tearDown() {
    mockCloseable!!.close()
  }

  @Test
  fun onAttachedToActivity_updatesDelegate() {
    flutterPlugin = GoogleSignInPlugin()
    flutterPlugin!!.initWithDelegate(
        Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java), plugin!!)
    flutterPlugin!!.onAttachedToActivity(mockActivityPluginBinding!!)

    Mockito.verify<ActivityPluginBinding?>(mockActivityPluginBinding)
        .addActivityResultListener(plugin!!)
    Assert.assertEquals(mockActivity, plugin!!.getActivity())
  }

  @Test
  fun onDetachedFromActivity_updatesDelegate() {
    flutterPlugin = GoogleSignInPlugin()
    flutterPlugin!!.initWithDelegate(
        Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java), plugin!!)
    flutterPlugin!!.onAttachedToActivity(mockActivityPluginBinding!!)
    flutterPlugin!!.onDetachedFromActivity()

    Mockito.verify<ActivityPluginBinding?>(mockActivityPluginBinding)
        .removeActivityResultListener(plugin!!)
    Assert.assertNull(plugin!!.getActivity())
  }

  @Test
  fun onReattachedToActivityForConfigChanges_updatesDelegate() {
    flutterPlugin = GoogleSignInPlugin()
    flutterPlugin!!.initWithDelegate(
        Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java), plugin!!)
    flutterPlugin!!.onReattachedToActivityForConfigChanges(mockActivityPluginBinding!!)

    Mockito.verify<ActivityPluginBinding?>(mockActivityPluginBinding)
        .addActivityResultListener(plugin!!)
    Assert.assertEquals(mockActivity, plugin!!.getActivity())
  }

  @Test
  fun onDetachedFromActivityForConfigChanges_updatesDelegate() {
    flutterPlugin = GoogleSignInPlugin()
    flutterPlugin!!.initWithDelegate(
        Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java), plugin!!)
    flutterPlugin!!.onAttachedToActivity(mockActivityPluginBinding!!)
    flutterPlugin!!.onDetachedFromActivityForConfigChanges()

    Mockito.verify<ActivityPluginBinding?>(mockActivityPluginBinding)
        .removeActivityResultListener(plugin!!)
    Assert.assertNull(plugin!!.getActivity())
  }

  @Test
  fun getGoogleServicesJsonServerClientId_loadsServerClientIdFromResources() {
    val packageName = "fakePackageName"
    val serverClientId = "fakeServerClientId"
    val resourceId = 1
    Mockito.`when`<String?>(mockContext!!.getPackageName()).thenReturn(packageName)
    Mockito.`when`<Int?>(
            mockResources!!.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(resourceId)
    Mockito.`when`<String?>(mockContext!!.getString(resourceId)).thenReturn(serverClientId)

    val returnedId = plugin!!.getGoogleServicesJsonServerClientId()
    Assert.assertEquals(serverClientId, returnedId)
  }

  @Test
  fun getGoogleServicesJsonServerClientId_returnsNullIfNotFound() {
    val packageName = "fakePackageName"
    Mockito.`when`<String?>(mockContext!!.getPackageName()).thenReturn(packageName)
    Mockito.`when`<Int?>(
            mockResources!!.getIdentifier("default_web_client_id", "string", packageName))
        .thenReturn(0)

    val returnedId = plugin!!.getGoogleServicesJsonServerClientId()
    Assert.assertNull(returnedId)
  }

  @Test
  fun getCredential_returnsAuthenticationInfo() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val displayName = "Jane User"
    val givenName = "Jane"
    val familyName = "User"
    val email = "someEmail"
    val uniqueId = "someAccountId"
    val idToken = "idToken"
    Mockito.`when`<String?>(mockGoogleCredential!!.displayName).thenReturn(displayName)
    Mockito.`when`<String?>(mockGoogleCredential!!.givenName).thenReturn(givenName)
    Mockito.`when`<String?>(mockGoogleCredential!!.familyName).thenReturn(familyName)
    Mockito.`when`<String?>(mockGoogleCredential!!.email).thenReturn(email)
    Mockito.`when`<String?>(mockGoogleCredential!!.uniqueId).thenReturn(uniqueId)
    Mockito.`when`<String?>(mockGoogleCredential!!.idToken).thenReturn(idToken)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialSuccess)
          val credential = (result as GetCredentialSuccess).credential
          Assert.assertEquals(displayName, credential.displayName)
          Assert.assertEquals(givenName, credential.givenName)
          Assert.assertEquals(familyName, credential.familyName)
          Assert.assertEquals(email, credential.email)
          Assert.assertEquals(idToken, credential.idToken)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onResult(GetCredentialResponse(mockGenericCredential!!))
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_usesGetSignInWithGoogleOptionForButtonFlow() {
    val params =
        GetCredentialRequestParams(
            true,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(params, {})

    val captor =
        ArgumentCaptor.forClass<GetCredentialRequest?, GetCredentialRequest?>(
            GetCredentialRequest::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            captor.capture(),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            ArgumentMatchers.any<
                CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?>())

    Assert.assertEquals(1, captor.getValue()!!.credentialOptions.size.toLong())
    Assert.assertTrue(captor.getValue()!!.credentialOptions.get(0) is GetSignInWithGoogleOption)
  }

  @Test
  fun getCredential_usesGetGoogleIdOptionForNonButtonFlow() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          // This test doesn't trigger the getCredentialsAsync callback that would call this,
          // so if this is reached something has gone wrong.
          Assert.fail()
          null
        })

    val captor =
        ArgumentCaptor.forClass<GetCredentialRequest?, GetCredentialRequest?>(
            GetCredentialRequest::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            captor.capture(),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            ArgumentMatchers.any<
                CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?>())

    Assert.assertEquals(1, captor.getValue()!!.credentialOptions.size.toLong())
    Assert.assertTrue(captor.getValue()!!.credentialOptions.get(0) is GetGoogleIdOption)
  }

  @Test
  fun getCredential_passesHostedDomainInButtonFlow() {
    val hostedDomain = "example.com"
    val params =
        GetCredentialRequestParams(
            true,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            hostedDomain,
            null)

    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          // This test doesn't trigger the getCredentialsAsync callback that would call this,
          // so if this is reached something has gone wrong.
          Assert.fail()
          null
        })

    val captor =
        ArgumentCaptor.forClass<GetCredentialRequest?, GetCredentialRequest?>(
            GetCredentialRequest::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            captor.capture(),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            ArgumentMatchers.any<
                CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?>())

    Assert.assertEquals(1, captor.getValue()!!.credentialOptions.size.toLong())
    Assert.assertEquals(
        hostedDomain,
        (captor.getValue()!!.credentialOptions.get(0) as GetSignInWithGoogleOption)
            .hostedDomainFilter)
  }

  @Test
  fun getCredential_passesNonceInButtonFlow() {
    val nonce = "nonce"
    val params =
        GetCredentialRequestParams(
            true,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            nonce)

    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          // This test doesn't trigger the getCredentialsAsync callback that would call this,
          // so if this is reached something has gone wrong.
          Assert.fail()
          null
        })

    val captor =
        ArgumentCaptor.forClass<GetCredentialRequest?, GetCredentialRequest?>(
            GetCredentialRequest::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            captor.capture(),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            ArgumentMatchers.any<
                CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?>())

    Assert.assertEquals(1, captor.getValue()!!.credentialOptions.size.toLong())
    Assert.assertEquals(
        nonce, (captor.getValue()!!.credentialOptions.get(0) as GetSignInWithGoogleOption).nonce)
  }

  @Test
  fun getCredential_passesNonceInNonButtonFlow() {
    val nonce = "nonce"
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            nonce)

    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          // This test doesn't trigger the getCredentialsAsync callback that would call this,
          // so if this is reached something has gone wrong.
          Assert.fail()
          null
        })

    val captor =
        ArgumentCaptor.forClass<GetCredentialRequest?, GetCredentialRequest?>(
            GetCredentialRequest::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            captor.capture(),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            ArgumentMatchers.any<
                CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?>())

    Assert.assertEquals(1, captor.getValue()!!.credentialOptions.size.toLong())
    Assert.assertEquals(
        nonce, (captor.getValue()!!.credentialOptions.get(0) as GetGoogleIdOption).nonce)
  }

  @Test
  fun getCredential_reportsMissingActivity() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(null)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.NO_ACTIVITY, failure.type)
          null
        })
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsMissingServerClientId() {
    val params =
        GetCredentialRequestParams(
            false, GetCredentialRequestGoogleIdOptionParams(false, false), null, null, null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.MISSING_SERVER_CLIENT_ID, failure.type)
          null
        })
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsWrongCredentialType() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    // PasswordCredential is used because it's easy to create without mocking; all that matters is
    // that it's not a CustomCredential of type TYPE_GOOGLE_ID_TOKEN_CREDENTIAL.
    callbackCaptor.getValue()!!.onResult(GetCredentialResponse(PasswordCredential("wrong", "type")))
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsCancellation() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.CANCELED, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onError(GetCredentialCancellationException())
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsInterrupted() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.INTERRUPTED, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onError(GetCredentialInterruptedException())
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsProviderConfigurationIssue() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onError(GetCredentialProviderConfigurationException())
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsUnsupported() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.UNSUPPORTED, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onError(GetCredentialUnsupportedException())
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsNoCredential() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.NO_CREDENTIAL, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onError(NoCredentialException())
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun getCredential_reportsUnknown() {
    val params =
        GetCredentialRequestParams(
            false,
            GetCredentialRequestGoogleIdOptionParams(false, false),
            "serverClientId",
            null,
            null)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.setActivity(mockActivity)
    plugin!!.getCredential(
        params,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is GetCredentialFailure)
          val failure = result as GetCredentialFailure
          Assert.assertEquals(GetCredentialFailureType.UNKNOWN, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<GetCredentialResponse?, GetCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .getCredentialAsync(
            ArgumentMatchers.eq<Activity?>(mockActivity),
            ArgumentMatchers.any<GetCredentialRequest?>(GetCredentialRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onError(GetCredentialUnknownException())
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun authorize_passesNullParamaters() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)

    plugin!!.authorize(
        params,
        false,
        { reply ->
          // This test doesn't trigger the getCredentialsAsync callback that would call this,
          // so if this is reached something has gone wrong.
          Assert.fail()
          null
        })

    val authRequestCaptor =
        ArgumentCaptor.forClass<AuthorizationRequest?, AuthorizationRequest?>(
            AuthorizationRequest::class.java)
    Mockito.verify<AuthorizationClient?>(mockAuthorizationClient)
        .authorize(authRequestCaptor.capture())

    val request = authRequestCaptor.getValue()
    Assert.assertNull(request.getHostedDomain())
    Assert.assertNull(request.getServerClientId())
    Assert.assertNull(request.getAccount())
  }

  @Test
  fun authorize_passesOptionalParameters() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val hostedDomain = "example.com"
    val accountEmail = "someone@example.com"
    val serverClientId = "serverClientId"
    val params = PlatformAuthorizationRequest(scopes, hostedDomain, accountEmail, serverClientId)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)

    plugin!!.authorize(
        params,
        false,
        { reply ->
          // This test doesn't trigger the getCredentialsAsync callback that would call this,
          // so if this is reached something has gone wrong.
          Assert.fail()
          null
        })

    val authRequestCaptor =
        ArgumentCaptor.forClass<AuthorizationRequest?, AuthorizationRequest?>(
            AuthorizationRequest::class.java)
    Mockito.verify<AuthorizationClient?>(mockAuthorizationClient)
        .authorize(authRequestCaptor.capture())

    val request = authRequestCaptor.getValue()
    Assert.assertEquals(hostedDomain, request.getHostedDomain())
    Assert.assertEquals(serverClientId, request.getServerClientId())
    // Account is mostly opaque, so just verify that one was set if an email was provided.
    Assert.assertNotNull(request.getAccount())
  }

  @Test
  fun authorize_returnsImmediateResult() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    val accessToken = "accessToken"
    val serverAuthCode = "serverAuthCode"
    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        false,
        { reply ->
          callbackCalled[0] = true
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is PlatformAuthorizationResult)
          val auth = result as PlatformAuthorizationResult
          Assert.assertEquals(accessToken, auth.accessToken)
          Assert.assertEquals(serverAuthCode, auth.serverAuthCode)
          Assert.assertEquals(scopes, auth.grantedScopes)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)

    callbackCaptor
        .getValue()!!
        .onSuccess(mockSuccessAuthorizationResult(serverAuthCode, accessToken, scopes))
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun authorize_reportsImmediateException() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenThrow(RuntimeException())

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        false,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is AuthorizeFailure)
          val failure = result as AuthorizeFailure
          Assert.assertEquals(AuthorizeFailureType.API_EXCEPTION, failure.type)
          null
        })

    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun authorize_reportsFailureIfUnauthorizedAndNoPromptAllowed() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)

    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        false,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is AuthorizeFailure)
          val failure = result as AuthorizeFailure
          Assert.assertEquals(AuthorizeFailureType.UNAUTHORIZED, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)

    callbackCaptor
        .getValue()!!
        .onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun authorize_reportsFailureIfUnauthorizedAndNoActivity() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)

    plugin!!.setActivity(null)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        true,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is AuthorizeFailure)
          val failure = result as AuthorizeFailure
          Assert.assertEquals(AuthorizeFailureType.NO_ACTIVITY, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)

    callbackCaptor
        .getValue()!!
        .onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun authorize_returnsPostIntentResult() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    val accessToken = "accessToken"
    val serverAuthCode = "serverAuthCode"
    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)
    val successResult = mockSuccessAuthorizationResult(serverAuthCode, accessToken, scopes)
    try {
      Mockito.`when`<AuthorizationResult?>(
              mockAuthorizationClient!!.getAuthorizationResultFromIntent(
                  ArgumentMatchers.any<Intent?>()))
          .thenReturn(successResult)
    } catch (e: ApiException) {
      Assert.fail()
    }

    plugin!!.setActivity(mockActivity)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        true,
        { reply ->
          callbackCalled[0] = true
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is PlatformAuthorizationResult)
          val auth = result as PlatformAuthorizationResult
          Assert.assertEquals(accessToken, auth.accessToken)
          Assert.assertEquals(serverAuthCode, auth.serverAuthCode)
          Assert.assertEquals(scopes, auth.grantedScopes)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)
    callbackCaptor
        .getValue()!!
        .onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    try {
      Mockito.verify<Activity?>(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntent!!.getIntentSender(),
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null)
    } catch (e: SendIntentException) {
      Assert.fail()
    }
    // Simulate the UI flow completing. The intent data can be null here because the mock of
    // mockAuthorizationClient.getAuthorizationResultFromIntent above ignores the parameter.
    plugin!!.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)

    Assert.assertTrue(callbackCalled[0]!!)
  }

  // Regression test for https://github.com/flutter/flutter/issues/188062
  // A re-delivered authorization activity result for REQUEST_CODE_AUTHORIZE (e.g. after a
  // configuration change or process death) must not resolve the same callback twice, which would
  // throw IllegalStateException ("Reply already submitted") on the real Pigeon reply.
  @Test
  fun authorize_ignoresDuplicateActivityResult() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    val accessToken = "accessToken"
    val serverAuthCode = "serverAuthCode"
    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)
    val successResult = mockSuccessAuthorizationResult(serverAuthCode, accessToken, scopes)
    try {
      Mockito.`when`<AuthorizationResult?>(
              mockAuthorizationClient!!.getAuthorizationResultFromIntent(
                  ArgumentMatchers.any<Intent?>()))
          .thenReturn(successResult)
    } catch (e: ApiException) {
      Assert.fail()
    }

    plugin!!.setActivity(mockActivity)
    val callbackCount = intArrayOf(0)
    plugin!!.authorize(
        params,
        true,
        { reply ->
          callbackCount[0] += 1
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)
    callbackCaptor
        .getValue()!!
        .onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))

    // The first delivery resolves the authorization and is consumed.
    val firstHandled =
        plugin!!.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)
    // A duplicate/re-delivered result for the same request code must be ignored, not re-resolved.
    val secondHandled =
        plugin!!.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)

    Assert.assertTrue(firstHandled)
    Assert.assertFalse(secondHandled)
    Assert.assertEquals(1, callbackCount[0].toLong())
  }

  @Test
  fun authorize_reportsPendingIntentException() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)
    try {
      Mockito.doThrow(SendIntentException())
          .`when`<Activity?>(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntentSender,
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null)
    } catch (e: SendIntentException) {
      Assert.fail()
    }

    plugin!!.setActivity(mockActivity)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        true,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is AuthorizeFailure)
          val failure = result as AuthorizeFailure
          Assert.assertEquals(AuthorizeFailureType.PENDING_INTENT_EXCEPTION, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)
    callbackCaptor
        .getValue()!!
        .onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))

    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun authorize_reportsPostIntentException() {
    val scopes: MutableList<String?> =
        ArrayList<String?>(mutableListOf<String?>("scope1", "scope1"))
    val params = PlatformAuthorizationRequest(scopes, null, null, null)

    Mockito.`when`<Task<AuthorizationResult?>?>(
            mockAuthorizationClient!!.authorize(ArgumentMatchers.any<AuthorizationRequest?>()))
        .thenReturn(mockAuthorizationTask)
    try {
      Mockito.`when`<AuthorizationResult?>(
              mockAuthorizationClient!!.getAuthorizationResultFromIntent(
                  ArgumentMatchers.any<Intent?>()))
          .thenThrow(ApiException(Status.RESULT_INTERNAL_ERROR))
    } catch (e: ApiException) {
      Assert.fail()
    }

    plugin!!.setActivity(mockActivity)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    plugin!!.authorize(
        params,
        true,
        { reply ->
          callbackCalled[0] = true
          // This failure is a structured return value, not an exception.
          Assert.assertTrue(reply!!.isSuccess)
          val result = reply.getOrNull()
          Assert.assertTrue(result is AuthorizeFailure)
          val failure = result as AuthorizeFailure
          Assert.assertEquals(AuthorizeFailureType.API_EXCEPTION, failure.type)
          null
        })

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<AuthorizationResult?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<AuthorizationResult?>?>(mockAuthorizationTask)
        .addOnSuccessListener(callbackCaptor.capture()!!)
    callbackCaptor
        .getValue()!!
        .onSuccess(mockResolutionAuthorizationResult(mockAuthorizationIntent))
    try {
      Mockito.verify<Activity?>(mockActivity)
          .startIntentSenderForResult(
              mockAuthorizationIntent!!.getIntentSender(),
              GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE,
              null,
              0,
              0,
              0,
              null)
    } catch (e: SendIntentException) {
      Assert.fail()
    }
    // Simulate the UI flow completing. The intent data can be null here because the mock of
    // mockAuthorizationClient.getAuthorizationResultFromIntent above ignores the parameter.
    plugin!!.onActivityResult(GoogleSignInPlugin.Delegate.REQUEST_CODE_AUTHORIZE, 0, null)

    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun clearCredentialState_reportsSuccess() {
    plugin!!.clearCredentialState({ reply ->
      Assert.assertTrue(reply!!.isSuccess)
      null
    })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<Void?, ClearCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .clearCredentialStateAsync(
            ArgumentMatchers.any<ClearCredentialStateRequest?>(
                ClearCredentialStateRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor.getValue()!!.onResult(null)
  }

  @Test
  fun clearCredentialState_reportsFailure() {
    plugin!!.clearCredentialState({ reply ->
      Assert.assertTrue(reply!!.isFailure)
      null
    })

    val callbackCaptor =
        ArgumentCaptor.forClass<
            CredentialManagerCallback<Void?, ClearCredentialException?>?,
            CredentialManagerCallback<*, *>?>(
            CredentialManagerCallback::class.java)
    Mockito.verify<CredentialManager?>(mockCredentialManager)
        .clearCredentialStateAsync(
            ArgumentMatchers.any<ClearCredentialStateRequest?>(
                ClearCredentialStateRequest::class.java),
            ArgumentMatchers.any<CancellationSignal?>(),
            ArgumentMatchers.any<Executor?>(),
            callbackCaptor.capture())

    callbackCaptor
        .getValue()!!
        .onError(Mockito.mock<ClearCredentialException?>(ClearCredentialException::class.java))
  }

  @Test
  fun revokeAccess_callsClient() {
    val scopes: MutableList<String?> = ArrayList<String?>(mutableListOf<String?>("openid"))
    val accountEmail = "someone@example.com"
    val params = PlatformRevokeAccessRequest(accountEmail, scopes)
    Mockito.`when`<Task<Void?>?>(
            mockAuthorizationClient!!.revokeAccess(ArgumentMatchers.any<RevokeAccessRequest?>()))
        .thenReturn(mockVoidTask)
    plugin!!.revokeAccess(params, { reply -> null })

    val requestCaptor =
        ArgumentCaptor.forClass<RevokeAccessRequest?, RevokeAccessRequest?>(
            RevokeAccessRequest::class.java)
    Mockito.verify<AuthorizationClient?>(mockAuthorizationClient)
        .revokeAccess(requestCaptor.capture())

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<Void?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<Void?>?>(mockVoidTask).addOnSuccessListener(callbackCaptor.capture()!!)
    callbackCaptor.getValue()!!.onSuccess(null)

    val request = requestCaptor.getValue()
    Assert.assertEquals(scopes.size.toLong(), request.getScopes().size.toLong())
    Assert.assertEquals(scopes.get(0), request.getScopes().get(0).getScopeUri())
    // Account is mostly opaque, so just verify that one was set.
    Assert.assertNotNull(request.getAccount())
  }

  @Test
  fun clearAuthorizationToken_callsClient() {
    val testToken = "testToken"
    Mockito.`when`<Task<Void?>?>(
            mockAuthorizationClient!!.clearToken(ArgumentMatchers.any<ClearTokenRequest?>()))
        .thenReturn(mockVoidTask)
    plugin!!.clearAuthorizationToken(testToken, { reply -> null })

    val authRequestCaptor =
        ArgumentCaptor.forClass<ClearTokenRequest?, ClearTokenRequest?>(
            ClearTokenRequest::class.java)
    Mockito.verify<AuthorizationClient?>(mockAuthorizationClient)
        .clearToken(authRequestCaptor.capture())

    val callbackCaptor =
        ArgumentCaptor.forClass<OnSuccessListener<Void?>?, OnSuccessListener<*>?>(
            OnSuccessListener::class.java)
    Mockito.verify<Task<Void?>?>(mockVoidTask).addOnSuccessListener(callbackCaptor.capture()!!)
    callbackCaptor.getValue()!!.onSuccess(null)

    val request = authRequestCaptor.getValue()
    Assert.assertEquals(testToken, request.getToken())
  }

  private fun mockSuccessAuthorizationResult(
      serverAuthCode: String?,
      accessToken: String?,
      scopes: MutableList<String?>?
  ): AuthorizationResult {
    val mockResult = Mockito.mock<AuthorizationResult>(AuthorizationResult::class.java)
    Mockito.`when`<Boolean?>(mockResult.hasResolution()).thenReturn(false)
    Mockito.`when`<String?>(mockResult.getAccessToken()).thenReturn(accessToken)
    Mockito.`when`<String?>(mockResult.getServerAuthCode()).thenReturn(serverAuthCode)
    Mockito.`when`<MutableList<String?>?>(mockResult.getGrantedScopes()).thenReturn(scopes)
    return mockResult
  }

  private fun mockResolutionAuthorizationResult(
      pendingIntent: PendingIntent?
  ): AuthorizationResult {
    val mockResult = Mockito.mock<AuthorizationResult>(AuthorizationResult::class.java)
    Mockito.`when`<Boolean?>(mockResult.hasResolution()).thenReturn(true)
    Mockito.`when`<PendingIntent?>(mockResult.getPendingIntent()).thenReturn(pendingIntent)
    return mockResult
  }
}
