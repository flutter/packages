package dev.flutter.packages.cross_file_android

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** CrossFileAndroidPlugin */
class CrossFileAndroidPlugin : FlutterPlugin {

  private lateinit var registrar: ProxyApiRegistrar

  override fun onAttachedToEngine(pluginBinding: FlutterPlugin.FlutterPluginBinding) {
    registrar =
        ProxyApiRegistrar(pluginBinding.binaryMessenger, context = pluginBinding.applicationContext)
    registrar.setUp()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    registrar.ignoreCallsToDart = true
    registrar.tearDown()
    registrar.instanceManager.clear()
  }
}
