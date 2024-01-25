
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CaptureRequestKeySupportedType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CaptureRequestOptionsHostApi;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Host API implementation for {@link CaptureRequestOptions}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class CaptureRequestOptionsHostApiImpl implements CaptureRequestOptionsHostApi {
  private final InstanceManager instanceManager;
  private final CaptureRequestOptionsProxy proxy;

  /** Proxy for constructors and static method of {@link CaptureRequestOptions}. */
  @VisibleForTesting
  public static class CaptureRequestOptionsProxy {

    /** Creates an instance of {@link CaptureRequestOptions}. */
    @SuppressWarnings("unchecked") // TODO(camsim99): If I keep this, explain why this is safe.
    public CaptureRequestOptions create(@NonNull Map<CaptureRequestKeySupportedType, Object> options) {
      CaptureRequestOptions.Builder builder = new CaptureRequestOptions.Builder();

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
            builder.setCaptureRequestOption((CaptureRequest.Key<Boolean>) optionKey, (Boolean) optionValue);
            break;
          default:
            throw new IllegalArgumentException(
              "The capture request key is not currently supported by the plugin.");
        }
      }

      return builder.build();
    }

    private CaptureRequest.Key<? extends Object> getCaptureRequestKey(CaptureRequestKeySupportedType type) {
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
    }


  /**
   * Constructs a {@link CaptureRequestOptionsHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public CaptureRequestOptionsHostApiImpl(
      @NonNull InstanceManager instanceManager) {
    this(instanceManager, new CaptureRequestOptionsProxy());
  }

  /**
   * Constructs a {@link CaptureRequestOptionsHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link CaptureRequestOptions}
   */
  @VisibleForTesting
  CaptureRequestOptionsHostApiImpl(
      @NonNull InstanceManager instanceManager,
      @NonNull CaptureRequestOptionsProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(@NonNull Long identifier, @NonNull Map<Long, Object> options) {
    Map<CaptureRequestKeySupportedType, Object> decodedOptions = new HashMap<CaptureRequestKeySupportedType, Object>();
    for (Map.Entry<Long, Object> option : options.entrySet()) {
      decodedOptions.put(CaptureRequestKeySupportedType.values()[option.getKey().intValue()], option.getValue());
    }
    instanceManager.addDartCreatedInstance(proxy.create(decodedOptions), identifier);
  }
}
