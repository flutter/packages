package com.example.platform_view_repro;

import android.content.Context;
import android.view.View;
import androidx.annotation.NonNull;
import io.flutter.plugin.platform.PlatformView;

public class ReproPlatformView implements PlatformView {
  private final View view;

  public ReproPlatformView(@NonNull Context context, @NonNull String nativeViewType) {
    if ("texture".equalsIgnoreCase(nativeViewType)) {
      this.view = new ReproTextureView(context);
    } else {
      this.view = new ReproSurfaceView(context);
    }
  }

  @NonNull
  @Override
  public View getView() {
    return view;
  }

  @Override
  public void dispose() {
  }
}

