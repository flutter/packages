// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package androidx.test.espresso.flutter.action;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.util.concurrent.Futures.immediateVoidFuture;

import android.os.SystemClock;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.test.espresso.UiController;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.common.Duration;
import com.google.common.util.concurrent.ListenableFuture;

/** An action that waits for up to a specified duration. */
public final class FlutterWaitForAction implements WidgetAction {
  private final Duration duration;
  private static final Duration WAIT_TIME_INTERVAL = Duration.ofMillis(50);

  /**
   * Constructs with the given duration.
   *
   * @param duration amount of time to be waited up for.
   */
  FlutterWaitForAction(@NonNull Duration duration) {
    this.duration = checkNotNull(duration);
  }

  @Override
  @NonNull
  public ListenableFuture<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @NonNull View flutterView,
      @NonNull FlutterTestingProtocol flutterTestingProtocol,
      @NonNull UiController androidUiController) {
    long durationInMillis = duration.toMillis();
    long startInMillis = SystemClock.elapsedRealtime();
    long elapsedInMillis = 0;
    while (elapsedInMillis < durationInMillis) {
      androidUiController.loopMainThreadForAtLeast(WAIT_TIME_INTERVAL.toMillis());
      elapsedInMillis = SystemClock.elapsedRealtime() - startInMillis;
    }
    return immediateVoidFuture();
  }
}
