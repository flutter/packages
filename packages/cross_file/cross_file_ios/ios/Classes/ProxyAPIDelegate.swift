import Foundation

/// Implementation of `FoundationPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation
/// and any additional resources needed by an implementation.
open class ProxyApiDelegate: FoundationPigeonProxyApiDelegate {
  /// Creates an error when the constructor of a class returns null.
    func createConstructorNullError(type: Any.Type, parameters: [String: Any?]) -> PigeonError {
      return PigeonError(
        code: "ConstructorReturnedNullError",
        message: "Failed to instantiate `\(String(describing: type))` with parameters: \(parameters)",
        details: nil)
    }
  
  func pigeonApiURL(_ registrar: FoundationPigeonProxyApiRegistrar) -> PigeonApiURL {
    return PigeonApiURL(pigeonRegistrar: registrar, delegate: URLProxyAPIDelegate())
  }
  
  func pigeonApiFileHandle(_ registrar: FoundationPigeonProxyApiRegistrar) -> PigeonApiFileHandle {
    return PigeonApiFileHandle(pigeonRegistrar: registrar, delegate: FileHandleProxyAPIDelegate())
  }
}

