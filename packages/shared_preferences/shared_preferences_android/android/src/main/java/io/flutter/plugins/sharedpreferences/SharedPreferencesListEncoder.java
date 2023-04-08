// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import java.util.List;

/** SharedPreferencesPlugin */
public interface SharedPreferencesListEncoder {
  String encode(List<String> list);

  List<String> decode(String listString);
}
