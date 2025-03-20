// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.IOException;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * ProxyApi implementation for {@link SystemServicesManager}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
public class SystemServicesManagerProxyApi extends PigeonApiSystemServicesManager {
  /**
   * Implementation of {@link SystemServicesManager} that passes arguments of callback methods to
   * Dart.
   */
  static class SystemServicesManagerImpl extends SystemServicesManager {
    private final SystemServicesManagerProxyApi api;

    SystemServicesManagerImpl(@NonNull SystemServicesManagerProxyApi api) {
      super(api.getPigeonRegistrar().getCameraPermissionsManager());
      this.api = api;
    }

    @Override
    public void onCameraError(@NonNull String errorDescription) {
      api.getPigeonRegistrar()
          .runOnMainThread(() -> api.onCameraError(this, errorDescription, reply -> null));
    }

    @NonNull
    @Override
    Context getContext() {
      return api.getPigeonRegistrar().getContext();
    }

    @Nullable
    @Override
    CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry() {
      return api.getPigeonRegistrar().getPermissionsRegistry();
    }
  }

  SystemServicesManagerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public SystemServicesManager pigeon_defaultConstructor() {
    return new SystemServicesManagerImpl(this);
  }

  @Override
  public void requestCameraPermissions(
      @NonNull SystemServicesManager pigeon_instance,
      boolean enableAudio,
      @NonNull Function1<? super Result<? extends CameraPermissionsError>, Unit> callback) {
    pigeon_instance.requestCameraPermissions(
        enableAudio, (isSuccessful, error) -> ResultCompat.success(error, callback));
  }

  @NonNull
  @Override
  public String getTempFilePath(
      @NonNull SystemServicesManager pigeon_instance,
      @NonNull String prefix,
      @NonNull String suffix) {
    try {
      return pigeon_instance.getTempFilePath(prefix, suffix);
    } catch (IOException e) {
      throw new RuntimeException(
          "getTempFilePath_failure",
          new Throwable(
              "SystemServicesHostApiImpl.getTempFilePath encountered an exception: " + e));
    }
  }
}
