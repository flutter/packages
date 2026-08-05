package com.example.platform_view_repro;

import android.content.Context;
import android.view.View;
import androidx.annotation.NonNull;
import io.flutter.plugin.platform.PlatformView;

public class ReproPlatformView implements PlatformView {
  private final ReproSurfaceView surfaceView;

  public ReproPlatformView(@NonNull Context context) {
    this.surfaceView = new ReproSurfaceView(context);
  }

  @NonNull
  @Override
  public View getView() {
    return surfaceView;
  }

  @Override
  public void dispose() {
  }
}
