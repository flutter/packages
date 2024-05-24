import 'dart:js_interop';
import 'package:web/web.dart' as html;

@JSExport()
class FakeIFrameElement {
  @JSExport('src')
  String? src;
}

extension type MockHTMLIFrameElement(JSObject _)
    implements html.HTMLIFrameElement, JSObject {
  external String? src;
}
