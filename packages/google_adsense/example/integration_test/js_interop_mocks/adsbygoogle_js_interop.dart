// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:async';
import 'dart:js_interop';

/// A function that looks like `adsbygoogle.push` to our JS-interop.
typedef PushFn = void Function(JSAny? params);

// window.adsbygoogle uses "duck typing", so let us set anything to it.
@JS('adsbygoogle')
external set _adsbygoogle(JSAny? value);

/// Mocks `adsbygoogle` [push] function.
///
/// `push` will run in the next tick (`Timer.run`) to ensure async behavior.
void mockAdsByGoogle(PushFn push) {
  _adsbygoogle = <String, Object>{
    'push': (JSAny? params) {
      Timer.run(() {
        push(params);
      });
    }.toJS,
  }.jsify();
}

/// Sets `adsbygoogle` to null.
void clearAdsByGoogleMock() {
  _adsbygoogle = null;
}
