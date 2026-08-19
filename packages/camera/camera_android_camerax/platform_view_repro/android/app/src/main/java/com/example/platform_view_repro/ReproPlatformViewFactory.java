package com.example.platform_view_repro;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;

public class ReproPlatformViewFactory extends PlatformViewFactory {
  public ReproPlatformViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  @SuppressWarnings("unchecked")
  public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
    String nativeViewType = "surface";
    if (args instanceof Map) {
      Map<String, Object> params = (Map<String, Object>) args;
      Object type = params.get("nativeViewType");
      if (type instanceof String) {
        nativeViewType = (String) type;
      }
    }
    return new ReproPlatformView(context, nativeViewType);
  }
}

