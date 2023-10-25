import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    weak var registrar = self.registrar(forPlugin: "DummyPlatform");

    let factory = DummyPlatformViewFactory(messenger: registrar!.messenger())
    self.registrar(forPlugin: "<DummyPlatform>")!.register(
        factory,
        withId: "dummy_platform_view")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
