#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import Cocoa
  import FlutterMacOS
#endif

public class CrossFileDarwinPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif

    let channel = FlutterMethodChannel(name: "cross_file_darwin", binaryMessenger: messenger)
    let instance = CrossFileDarwinPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      #if os(iOS)
        result("iOS " + UIDevice.current.systemVersion)
      #elseif os(macOS)
        result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
      #else
        result(FlutterMethodNotImplemented)
      #endif
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
