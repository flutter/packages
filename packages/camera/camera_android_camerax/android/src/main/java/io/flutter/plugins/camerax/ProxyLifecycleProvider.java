// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.app.Application.ActivityLifecycleCallbacks;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.Lifecycle.Event;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

/**
 * This class provides a custom {@link LifecycleOwner} for the activity driven by {@link
 * ActivityLifecycleCallbacks}.
 *
 * <p>This is used in the case where a direct {@link LifecycleOwner} is not available.
 */
public class ProxyLifecycleProvider implements ActivityLifecycleCallbacks, LifecycleOwner {

  @VisibleForTesting @NonNull public LifecycleRegistry lifecycle = new LifecycleRegistry(this);
  private final int registrarActivityHashCode;

  ProxyLifecycleProvider(@NonNull Activity activity) {
    this.registrarActivityHashCode = activity.hashCode();
    activity.getApplication().registerActivityLifecycleCallbacks(this);
  }

  @Override
  public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    lifecycle.handleLifecycleEvent(Event.ON_CREATE);
  }

  @Override
  public void onActivityStarted(@NonNull Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    lifecycle.handleLifecycleEvent(Event.ON_START);
  }

  @Override
  public void onActivityResumed(@NonNull Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    lifecycle.handleLifecycleEvent(Event.ON_RESUME);
  }

  @Override
  public void onActivityPaused(@NonNull Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    lifecycle.handleLifecycleEvent(Event.ON_PAUSE);
  }

  @Override
  public void onActivityStopped(@NonNull Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    lifecycle.handleLifecycleEvent(Event.ON_STOP);
  }

  @Override
  public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {}

  @Override
  public void onActivityDestroyed(@NonNull Activity activity) {
    if (activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    activity.getApplication().unregisterActivityLifecycleCallbacks(this);
    lifecycle.handleLifecycleEvent(Event.ON_DESTROY);
  }

  @NonNull
  @Override
  public Lifecycle getLifecycle() {
    return lifecycle;
  }
}
