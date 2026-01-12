// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.IOException;
import java.util.Objects;
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
    final SystemServicesManagerProxyApi api;

    SystemServicesManagerImpl(@NonNull SystemServicesManagerProxyApi api) {
      super(api.getPigeonRegistrar().getCameraPermissionsManager());
      this.api = api;
    }

    @Override
    public void onCameraError(@NonNull String errorDescription) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              new ProxyApiRegistrar.FlutterMethodRunnable() {
                @Override
                public void run() {
                  api.onCameraError(
                      SystemServicesManagerImpl.this,
                      errorDescription,
                      ResultCompat.asCompatCallback(
                          result -> {
                            if (result.isFailure()) {
                              onFailure(
                                  "SystemServicesManager.onCameraError",
                                  Objects.requireNonNull(result.exceptionOrNull()));
                            }
                            return null;
                          }));
                }
              });
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
      @NonNull SystemServicesManager pigeonInstance,
      boolean enableAudio,
      @NonNull Function1<? super Result<? extends CameraPermissionsError>, Unit> callback) {
    pigeonInstance.requestCameraPermissions(
        enableAudio, (isSuccessful, error) -> ResultCompat.success(error, callback));
  }

  @NonNull
  @Override
  public String getTempFilePath(
      @NonNull SystemServicesManager pigeonInstance,
      @NonNull String prefix,
      @NonNull String suffix) {
    try {
      return pigeonInstance.getTempFilePath(prefix, suffix);
    } catch (IOException e) {
      throw new RuntimeException(
          "getTempFilePath_failure",
          new Throwable(
              "SystemServicesHostApiImpl.getTempFilePath encountered an exception: " + e, e));
    }
  }
}
