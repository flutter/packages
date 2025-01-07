// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.cameraxexample;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import androidx.camera.lifecycle.ProcessCameraProvider;
import com.google.common.util.concurrent.ListenableFuture;
import android.os.Bundle;
import androidx.lifecycle.LifecycleOwner;
import androidx.camera.core.CameraSelector;
import androidx.core.content.ContextCompat;
import java.util.concurrent.ExecutionException;
import androidx.camera.core.Preview;
import androidx.camera.view.PreviewView;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;
    NativeViewFactory nativeViewFactory;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        nativeViewFactory = new NativeViewFactory();
        flutterEngine
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory("<platform-view-type>", nativeViewFactory);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.e("CAMILLE", "oncreate!");
        cameraProviderFuture = ProcessCameraProvider.getInstance(this);
        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                bindPreview(cameraProvider);
            } catch (ExecutionException | InterruptedException e) {
                // No errors need to be handled for this Future.
                // This should never be reached.
            }
        }, ContextCompat.getMainExecutor(this));

    }

    void bindPreview(@NonNull ProcessCameraProvider cameraProvider) {
    Preview preview = new Preview.Builder()
            .build();

    CameraSelector cameraSelector = new CameraSelector.Builder()
            .requireLensFacing(CameraSelector.LENS_FACING_BACK)
            .build();

    PreviewView previewView = (PreviewView) nativeViewFactory.getView2();
    preview.setSurfaceProvider(previewView.getSurfaceProvider());

    cameraProvider.bindToLifecycle((LifecycleOwner)this, cameraSelector, preview);
}
}
