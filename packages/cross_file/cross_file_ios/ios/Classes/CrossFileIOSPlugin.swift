import Flutter
import UIKit

public class CrossFileIOSPlugin: NSObject, FlutterPlugin {
  var proxyApiRegistrar: FoundationPigeonProxyApiRegistrar?

    init(binaryMessenger: FlutterBinaryMessenger) {
      proxyApiRegistrar = FoundationPigeonProxyApiRegistrar(
        binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())
      proxyApiRegistrar?.setUp()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
      let plugin = CrossFileIOSPlugin(binaryMessenger: registrar.messenger())
      registrar.publish(plugin)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
      proxyApiRegistrar!.ignoreCallsToDart = true
      proxyApiRegistrar!.tearDown()
      proxyApiRegistrar = nil
    }
}
