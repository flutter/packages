package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceResponse;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class WebResourceResponseProxyApi extends PigeonApiWebResourceResponse {
  public WebResourceResponseProxyApi(@NonNull PigeonProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long statusCode(@NonNull WebResourceResponse pigeon_instance) {
    return pigeon_instance.getStatusCode();
  }
}
