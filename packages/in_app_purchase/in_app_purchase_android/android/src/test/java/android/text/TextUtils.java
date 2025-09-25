// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.text;

public class TextUtils {
  public static boolean isEmpty(CharSequence str) {
    return str == null || str.length() == 0;
  }
}
