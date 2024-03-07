package com.example.test_rubidium

import android.os.Bundle
import android.util.Log
import androidx.privacysandbox.sdkruntime.client.SdkSandboxManagerCompat
import androidx.privacysandbox.sdkruntime.core.AppOwnedSdkSandboxInterfaceCompat
import androidx.privacysandbox.sdkruntime.core.LoadSdkCompatException
import androidx.privacysandbox.ui.client.view.SandboxedSdkView
import hello.world.TestProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
  private lateinit var mSdkSandboxManager: SdkSandboxManagerCompat

  private var mSdkLoaded = false
  // private lateinit var sdkApi: ISdkApi

  private lateinit var webViewBannerView: SandboxedSdkView
  private lateinit var bottomBannerView: SandboxedSdkView
  private lateinit var resizableBannerView: SandboxedSdkView
  //  private lateinit var newAdButton: Button
  //  private lateinit var resizeButton: Button
  //  private lateinit var resizeSdkButton: Button
  //  private lateinit var mediationSwitch: SwitchMaterial
  //  private lateinit var localWebViewToggle: SwitchMaterial
  //  private lateinit var appOwnedMediateeToggleButton: SwitchMaterial
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    mSdkSandboxManager = SdkSandboxManagerCompat.from(applicationContext)

    Log.i(TAG, "Loading SDK")
    CoroutineScope(Dispatchers.Default).launch {
      try {
        mSdkSandboxManager.loadSdk(MEDIATEE_SDK_NAME, Bundle())
        val loadedSdk = mSdkSandboxManager.loadSdk(SDK_NAME, Bundle())
        mSdkSandboxManager.registerAppOwnedSdkSandboxInterface(
            AppOwnedSdkSandboxInterfaceCompat(
                MEDIATEE_SDK_NAME, /*version=*/ 0, TestProvider(applicationContext)))
        // onLoadedSdk(loadedSdk)
      } catch (e: LoadSdkCompatException) {
        Log.i(
            TAG,
            "loadSdk failed with errorCode: " + e.loadSdkErrorCode + " and errorMsg: " + e.message)
      }
    }
  }

  companion object {
    private const val TAG = "TestSandboxClient"

    /** Name of the SDK to be loaded. */
    private const val SDK_NAME = "androidx.privacysandbox.ui.integration.testsdkprovider"
    private const val MEDIATEE_SDK_NAME =
        "androidx.privacysandbox.ui.integration.mediateesdkprovider"
  }
}
