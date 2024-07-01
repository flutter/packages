// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:js_interop';
import 'package:web/web.dart' as html;

@JSExport()
class FakeIFrameElement {
  @JSExport('src')
  String? src;
}

extension type MockHTMLIFrameElement(JSObject _)
    implements html.HTMLIFrameElement, JSObject {
  external set src(String? value);
  external String? get src;
}
