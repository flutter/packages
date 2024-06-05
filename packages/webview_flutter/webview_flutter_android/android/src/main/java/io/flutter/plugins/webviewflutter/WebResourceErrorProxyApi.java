package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebResourceError;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

@RequiresApi(api = Build.VERSION_CODES.M)
public class WebResourceErrorProxyApi extends PigeonApiWebResourceError {
  public WebResourceErrorProxyApi(@NonNull PigeonProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long errorCode(@NonNull WebResourceError pigeon_instance) {
    return pigeon_instance.getErrorCode();
  }

  @NonNull
  @Override
  public String description(@NonNull WebResourceError pigeon_instance) {
    return pigeon_instance.getDescription().toString();
  }
}
