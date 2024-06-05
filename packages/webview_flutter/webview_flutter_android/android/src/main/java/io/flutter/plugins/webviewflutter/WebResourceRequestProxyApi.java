package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceRequest;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import java.util.Map;

public class WebResourceRequestProxyApi extends PigeonApiWebResourceRequest {
  public WebResourceRequestProxyApi(@NonNull PigeonProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @NonNull
  @Override
  public String url(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.getUrl().toString();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean isForMainFrame(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.isForMainFrame();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Nullable
  @Override
  public Boolean isRedirect(@NonNull WebResourceRequest pigeon_instance) {
    return null;
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean hasGesture(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.hasGesture();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @NonNull
  @Override
  public String method(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.getMethod();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Nullable
  @Override
  public Map<String, String> requestHeaders(@NonNull WebResourceRequest pigeon_instance) {
    return pigeon_instance.getRequestHeaders();
  }
}
