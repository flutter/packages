/// A mock implementation of `FLTEventChannel` that allows injecting a custom implementation
/// for setting a stream handler..
final class MockEventChannel: NSObject, FLTEventChannel {
  var setStreamHandlerStub: ((FlutterStreamHandler?) -> Void)?

  func setStreamHandler(_ handler: (FlutterStreamHandler & NSObjectProtocol)?) {
    setStreamHandlerStub?(handler)
  }
}
