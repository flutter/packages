// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:async';
import 'dart:js_interop';

// window.adsbygoogle uses "duck typing", so let us set anything to it.
@JS('adsbygoogle')
external set _adsbygoogle(JSAny? value);

/// Mocks `adsbygoogle` [push] function.
///
/// `push` will run in the next tick (`Timer.run`) to ensure async behavior.
void mockAdsByGoogle(void Function() push) {
  _adsbygoogle = <String, Object>{
    'push': () {
      Timer.run(push);
    }.toJS,
  }.jsify();
}

/// Sets `adsbygoogle` to null.
void clearAdsByGoogleMock() {
  _adsbygoogle = null;
}
