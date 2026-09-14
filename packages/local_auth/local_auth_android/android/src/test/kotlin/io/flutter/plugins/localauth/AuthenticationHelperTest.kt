// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth

import android.app.Application
import android.content.Context
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner

// TODO(stuartmorgan): Add injectable BiometricPrompt factory, and AlertDialog factor, and add
// testing of the rest of the flows.
@RunWith(RobolectricTestRunner::class)
class AuthenticationHelperTest {
    @Test
    fun onAuthenticationError_returnsUserCanceled() {
        val result = arrayOfNulls<AuthResult>(1)
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result[0] = authResult
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_USER_CANCELED, "")

        Assert.assertNotNull(result[0])
        Assert.assertEquals(AuthResultCode.USER_CANCELED, result[0]!!.code)
    }

    @Test
    fun onAuthenticationError_returnsNegativeButton() {
        val result = arrayOfNulls<AuthResult>(1)
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result[0] = authResult
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_NEGATIVE_BUTTON, "")

        Assert.assertNotNull(result[0])
        Assert.assertEquals(AuthResultCode.NEGATIVE_BUTTON, result[0]!!.code)
    }

    @Test
    fun onAuthenticationError_withoutDialogs_returnsNoCredential() {
        val result = arrayOfNulls<AuthResult>(1)
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result[0] = authResult
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL, "")

        Assert.assertNotNull(result[0])
        Assert.assertEquals(AuthResultCode.NO_CREDENTIALS, result[0]!!.code)
    }

    @Test
    fun onAuthenticationError_withoutDialogs_returnsNotEnrolledForNoBiometrics() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_NO_BIOMETRICS, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.NOT_ENROLLED, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsHardwareUnavailable() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_HW_UNAVAILABLE, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.HARDWARE_UNAVAILABLE, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsHardwareNotPresent() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_HW_NOT_PRESENT, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.NO_HARDWARE, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsTemporaryLockoutForLockout() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.LOCKED_OUT_TEMPORARILY, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsPermanentLockoutForLockoutPermanent() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_LOCKOUT_PERMANENT, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.LOCKED_OUT_PERMANENTLY, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_withoutSticky_returnsSystemCanceled() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_CANCELED, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.SYSTEM_CANCELED, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsTimeout() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_TIMEOUT, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.TIMEOUT, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsNoSpace() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_NO_SPACE, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.NO_SPACE, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsSecurityUpdateRequired() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_SECURITY_UPDATE_REQUIRED, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.SECURITY_UPDATE_REQUIRED, result.get(0)!!.code)
    }

    @Test
    fun onAuthenticationError_returnsUnknownForOtherCases() {
        val result = ArrayList<AuthResult?>()
        val helper =
            AuthenticationHelper(
                null,
                buildMockActivityWithContext(Mockito.mock(FragmentActivity::class.java)),
                defaultOptions,
                dummyStrings,
                ({ authResult: AuthResult? ->
                    result.add(authResult)
                    Unit
                }),
                true
            )

        helper.onAuthenticationError(BiometricPrompt.ERROR_UNABLE_TO_PROCESS, "")

        Assert.assertEquals(1, result.size.toLong())
        Assert.assertEquals(AuthResultCode.UNKNOWN_ERROR, result.get(0)!!.code)
    }

    private fun buildMockActivityWithContext(mockActivity: FragmentActivity): FragmentActivity {
        val mockApplication = Mockito.mock(Application::class.java)
        val mockContext = Mockito.mock(Context::class.java)
        Mockito.`when`<Context?>(mockActivity.getBaseContext()).thenReturn(mockContext)
        Mockito.`when`<Context?>(mockActivity.getApplicationContext()).thenReturn(mockContext)
        Mockito.`when`<Application?>(mockActivity.getApplication()).thenReturn(mockApplication)
        return mockActivity
    }

    companion object {
        val dummyStrings: AuthStrings = AuthStrings("a reason", "a hint", "cancel", "sign in")

        val defaultOptions: AuthOptions = AuthOptions( /* biometricOnly */
            false,  /* sensitiveTransaction */false,  /* sticky */false
        )
    }
}
