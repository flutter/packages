package com.example.privacy_sandbox_example

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.TextView
import androidx.privacysandbox.sdkruntime.client.SdkSandboxManagerCompat
import androidx.privacysandbox.sdkruntime.core.AppOwnedSdkSandboxInterfaceCompat
import androidx.privacysandbox.sdkruntime.core.LoadSdkCompatException
import androidx.privacysandbox.sdkruntime.core.SandboxedSdkCompat
import androidx.privacysandbox.ui.client.SandboxedUiAdapterFactory
import androidx.privacysandbox.ui.client.view.SandboxedSdkView
import hello.world.TestProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private lateinit var mSdkSandboxManager: SdkSandboxManagerCompat

  private var mSdkLoaded = false
  private lateinit var sdkApi: TestProvider

  private lateinit var webViewBannerView: SandboxedSdkView
  private lateinit var bottomBannerView: SandboxedSdkView
  private lateinit var resizableBannerView: SandboxedSdkView
//    private lateinit var newAdButton: Button
//    private lateinit var resizeButton: Button
//    private lateinit var resizeSdkButton: Button
//    private lateinit var mediationSwitch: SwitchMaterial
//    private lateinit var localWebViewToggle: SwitchMaterial
//    private lateinit var appOwnedMediateeToggleButton: SwitchMaterial
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    mSdkSandboxManager = SdkSandboxManagerCompat.from(applicationContext)

    Log.d(TAG, "Loading SDK")
    CoroutineScope(Dispatchers.Default).launch {
      try {
        //mSdkSandboxManager.loadSdk(MEDIATEE_SDK_NAME, Bundle())
        //val loadedSdk = mSdkSandboxManager.loadSdk(SDK_NAME, Bundle())
        sdkApi = TestProvider(applicationContext)
        mSdkSandboxManager.registerAppOwnedSdkSandboxInterface(
            AppOwnedSdkSandboxInterfaceCompat(
                MEDIATEE_SDK_NAME, /*version=*/ 0, sdkApi))
        //onLoadedSdk(loadedSdk)
      } catch (e: LoadSdkCompatException) {
        Log.i(
            TAG,
            "loadSdk failed with errorCode: " + e.loadSdkErrorCode + " and errorMsg: " + e.message)
      }
    }

    flutterEngine.platformViewsController.registry.registerViewFactory("myPlatformView", MyViewFactory())
  }

  private fun onLoadedSdk(sandboxedSdk: SandboxedSdkCompat) {
    //sdkApi = hello.world.ITestProvider.Stub.asInterface(sandboxedSdk.getInterface())
  }

  private inner class MyViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
      val view = SandboxedSdkView(context!!)
      view.setAdapter(SandboxedUiAdapterFactory.createFromCoreLibInfo(sdkApi.loadTestAdWithWaitInsideOnDraw(0)))
      return object : PlatformView {
        override fun getView(): View {
          return view
        }

        override fun dispose() {
          TODO("Not yet implemented")
        }
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
