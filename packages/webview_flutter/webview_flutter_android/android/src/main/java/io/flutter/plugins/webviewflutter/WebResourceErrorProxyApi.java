package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceError;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

public class WebResourceErrorProxyApi extends PigeonApiWebResourceError {
  public WebResourceErrorProxyApi(@NonNull PigeonProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public long errorCode(@NonNull WebResourceError pigeon_instance) {
    return pigeon_instance.getErrorCode();
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @NonNull
  @Override
  public String description(@NonNull WebResourceError pigeon_instance) {
    return pigeon_instance.getDescription().toString();
  }
}
