// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CaptureRequestKeySupportedType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CaptureRequestOptionsHostApi;
import java.util.HashMap;
import java.util.Map;

/**
 * Host API implementation for {@link CaptureRequestOptions}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class CaptureRequestOptionsHostApiImpl implements CaptureRequestOptionsHostApi {
  private final InstanceManager instanceManager;
  private final CaptureRequestOptionsProxy proxy;

  /** Proxy for constructor of {@link CaptureRequestOptions}. */
  @VisibleForTesting
  public static class CaptureRequestOptionsProxy {
    /** Creates an instance of {@link CaptureRequestOptions}. */
    // Suppression is safe because the type shared between the key and value pairs that
    // represent capture request options is checked on the Dart side.
    @SuppressWarnings("unchecked")
    @OptIn(markerClass = androidx.camera.camera2.interop.ExperimentalCamera2Interop.class)
    public @NonNull CaptureRequestOptions create(
        @NonNull Map<CaptureRequestKeySupportedType, Object> options) {
      CaptureRequestOptions.Builder builder = getCaptureRequestOptionsBuilder();

      for (Map.Entry<CaptureRequestKeySupportedType, Object> option : options.entrySet()) {
        CaptureRequestKeySupportedType optionKeyType = option.getKey();
        CaptureRequest.Key<? extends Object> optionKey = getCaptureRequestKey(optionKeyType);
        Object optionValue = option.getValue();

        if (optionValue == null) {
          builder.clearCaptureRequestOption(optionKey);
          continue;
        }

        switch (optionKeyType) {
          case CONTROL_AE_LOCK:
            builder.setCaptureRequestOption(
                (CaptureRequest.Key<Boolean>) optionKey, (Boolean) optionValue);
            break;
          default:
            throw new IllegalArgumentException(
                "The capture request key "
                    + optionKeyType.toString()
                    + "is not currently supported by the plugin.");
        }
      }

      return builder.build();
    }

    private CaptureRequest.Key<? extends Object> getCaptureRequestKey(
        CaptureRequestKeySupportedType type) {
      CaptureRequest.Key<? extends Object> key;
      switch (type) {
        case CONTROL_AE_LOCK:
          key = CaptureRequest.CONTROL_AE_LOCK;
          break;
        default:
          throw new IllegalArgumentException(
              "The capture request key is not currently supported by the plugin.");
      }
      return key;
    }

    @VisibleForTesting
    @OptIn(markerClass = androidx.camera.camera2.interop.ExperimentalCamera2Interop.class)
    public @NonNull CaptureRequestOptions.Builder getCaptureRequestOptionsBuilder() {
      return new CaptureRequestOptions.Builder();
    }
  }

  /**
   * Constructs a {@link CaptureRequestOptionsHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public CaptureRequestOptionsHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new CaptureRequestOptionsProxy());
  }

  /**
   * Constructs a {@link CaptureRequestOptionsHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link CaptureRequestOptions}
   */
  @VisibleForTesting
  CaptureRequestOptionsHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull CaptureRequestOptionsProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(@NonNull Long identifier, @NonNull Map<Long, Object> options) {
    Map<CaptureRequestKeySupportedType, Object> decodedOptions =
        new HashMap<CaptureRequestKeySupportedType, Object>();
    for (Map.Entry<Long, Object> option : options.entrySet()) {
      Integer index = ((Number) option.getKey()).intValue();
      decodedOptions.put(CaptureRequestKeySupportedType.values()[index], option.getValue());
    }
    instanceManager.addDartCreatedInstance(proxy.create(decodedOptions), identifier);
  }
}
