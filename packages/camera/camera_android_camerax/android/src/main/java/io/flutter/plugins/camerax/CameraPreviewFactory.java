// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;
import androidx.camera.view.PreviewView;

class CameraPreviewFactory extends PlatformViewFactory {
    PreviewView previewView;

    CameraPreviewFactory(PreviewView previewView) {
        super(StandardMessageCodec.INSTANCE);
        this.previewView = previewView;
    }

    @NonNull
    @Override
    @SuppressWarnings("unchecked")
    public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
        // return previewView;
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new CameraPreviewView(context, viewId, creationParams, previewView);
    }
}