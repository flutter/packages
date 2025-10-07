// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

/** Represents an exception/error relevant to Dart VM service. */
public final class FlutterProtocolException extends RuntimeException {
  private static final long serialVersionUID = 0L;

  public FlutterProtocolException(String message) {
    super(message);
  }

  public FlutterProtocolException(Throwable t) {
    super(t);
  }

  public FlutterProtocolException(String message, Throwable t) {
    super(message, t);
  }
}
