package com.example.platform_view_repro;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ReproPlatformViewFactory extends PlatformViewFactory {
  public ReproPlatformViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
    return new ReproPlatformView(context);
  }
}
