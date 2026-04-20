// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;

import androidx.camera.view.PreviewView;

class CameraPreviewView implements PlatformView {
   @NonNull private final PreviewView previewView;

    CameraPreviewView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        previewView = new PreviewView(context);
    }

    @NonNull
    @Override
    public View getView() {
        return previewView;
    }

    @Override
    public void dispose() {}
}
