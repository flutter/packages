package hello.world;

import android.annotation.SuppressLint;
import android.app.sdksandbox.LoadSdkException;
import android.app.sdksandbox.SandboxedSdk;
import android.app.sdksandbox.SandboxedSdkProvider;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.os.ext.SdkExtensions;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresExtension;

@RequiresExtension(extension = SdkExtensions.AD_SERVICES, version = 4)
public class TestSdkProvider extends SandboxedSdkProvider {
  @NonNull
  @Override
  public SandboxedSdk onLoadSdk(@NonNull Bundle bundle) throws LoadSdkException {
    return new SandboxedSdk(new TestProvider(getContext()));
  }

  @NonNull
  @Override
  public View getView(@NonNull Context context, @NonNull Bundle bundle, int i, int i1) {
    throw new IllegalStateException("This getView method will not be used.");
  }
}