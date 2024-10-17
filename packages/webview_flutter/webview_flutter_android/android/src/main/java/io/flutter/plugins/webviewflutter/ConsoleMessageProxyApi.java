// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.ConsoleMessage;
import androidx.annotation.NonNull;

public class ConsoleMessageProxyApi extends PigeonApiConsoleMessage {
  public ConsoleMessageProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long lineNumber(@NonNull ConsoleMessage pigeon_instance) {
    return pigeon_instance.lineNumber();
  }

  @NonNull
  @Override
  public String message(@NonNull ConsoleMessage pigeon_instance) {
    return pigeon_instance.message();
  }

  @NonNull
  @Override
  public ConsoleMessageLevel level(@NonNull ConsoleMessage pigeon_instance) {
    switch (pigeon_instance.messageLevel()) {
      case TIP:
        return ConsoleMessageLevel.TIP;
      case LOG:
        return ConsoleMessageLevel.LOG;
      case WARNING:
        return ConsoleMessageLevel.WARNING;
      case ERROR:
        return ConsoleMessageLevel.ERROR;
      case DEBUG:
        return ConsoleMessageLevel.DEBUG;
      default:
        return ConsoleMessageLevel.UNKNOWN;
    }
  }

  @NonNull
  @Override
  public String sourceId(@NonNull ConsoleMessage pigeon_instance) {
    return pigeon_instance.sourceId();
  }
}
