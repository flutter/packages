// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringResultHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQuality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQualityData;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Host API implementation for {@link FocusMeteringResult}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class FocusMeteringResultHostApiImpl implements FocusMeteringResultHostApi {
  private final InstanceManager instanceManager;

  private final FocusMeteringResultProxy proxy;

  /** Proxy for constructors and static method of {@link FocusMeteringResult}. */
  @VisibleForTesting
  public static class FocusMeteringResultProxy {
    /** Returns whether or not the {@link FocusMeteringResult} was successful. */
    public @NonNull
  public Boolean isFocusSuccessful(@NonNull FocusMeteringResult focusMeteringResult) {
    return focusMeteringResult.isFocusSuccessful();
  }
  }

  /**
   * Constructs a {@link FocusMeteringResultHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public FocusMeteringResultHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new FocusMeteringResultProxy());
  }

  /**
   * Constructs a {@link FocusMeteringResultHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link FocusMeteringResult}
   */
  FocusMeteringResultHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull FocusMeteringResultProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }


  @Override
  @NonNull
  public Boolean isFocusSuccessful(@NonNull Long identifier) {
    return proxy.isFocusSuccessful(instanceManager.getInstance(identifier));
  }
}
