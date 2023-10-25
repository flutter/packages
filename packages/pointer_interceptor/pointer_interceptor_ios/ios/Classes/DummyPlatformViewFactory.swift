import Flutter
import UIKit

public class DummyPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  public func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return DummyPlatformView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }

  /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

public class CustomView: UIView {

  override public func hitTest(
    _ point: CGPoint,
    with event: UIEvent?
  ) -> UIView? {
    print("clicked")

    viewWithTag(1)?.removeFromSuperview();
    return super.hitTest(point, with: event)
  }
}

class DummyPlatformView: NSObject, FlutterPlatformView {
  private var _view: CustomView;

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    _view = CustomView()
    super.init()
    createNativeView(view: _view)
  }

  func view() -> UIView {
    return _view
  }

  func createNativeView(view _view: CustomView){
    let nativeLabel = UILabel()
    _view.isUserInteractionEnabled = true
    nativeLabel.tag = 1;
    nativeLabel.text = "Not Clicked"
    nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
    _view.addSubview(nativeLabel)
  }
}
