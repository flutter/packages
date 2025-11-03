// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.util;

import android.app.Activity;
import android.view.WindowManager;

/**
 * Fake Activity class used only for JVM unit tests. It avoids dependency on the real Android
 * runtime and allows manual control of lifecycle states (isDestroyed, isFinishing) and the
 * WindowManager instance.
 */
public class FakeActivity extends Activity {
  private boolean destroyed;
  private boolean finishing;
  private WindowManager windowManager;

  public void setDestroyed(boolean destroyed) {
    this.destroyed = destroyed;
  }

  public void setFinishing(boolean finishing) {
    this.finishing = finishing;
  }

  public void setWindowManager(WindowManager windowManager) {
    this.windowManager = windowManager;
  }

  @Override
  public boolean isDestroyed() {
    return destroyed;
  }

  @Override
  public boolean isFinishing() {
    return finishing;
  }

  @Override
  public WindowManager getWindowManager() {
    return windowManager;
  }
}
