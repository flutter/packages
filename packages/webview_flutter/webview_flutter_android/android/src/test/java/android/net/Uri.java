// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.net;

import androidx.annotation.NonNull;

public class Uri {
  private final String url;

  public static Uri parse(String url) {
    return new Uri(url);
  }

  private Uri(String url) {
    this.url = url;
  }

  @NonNull
  @Override
  public String toString() {
    return url;
  }
}
