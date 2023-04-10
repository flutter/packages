// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import androidx.annotation.NonNull;
import java.util.List;

/** SharedPreferencesPlugin */
public interface SharedPreferencesListEncoder {
  @NonNull
  String encode(@NonNull List<String> list);

  @NonNull
  List<String> decode(@NonNull String listString);
}
