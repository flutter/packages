package io.flutter.plugins.googlemaps;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import com.google.android.gms.maps.model.BitmapDescriptor;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class PigeonTestHelper {
  public static final String FAKE_ASSET_NAME = "fake_asset_name";
  public static final String FAKE_ASSET_KEY = "fake_asset_key";
  public final Convert.FlutterInjectorWrapper flutterInjectorWrapper;

  public final AssetManager assetManager;

  public final Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  public final BitmapDescriptor mockBitmapDescriptor;

  public static InputStream buildImageInputStream() {
    Bitmap fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream.toByteArray();
    return new ByteArrayInputStream(byteArray);
  }

  public PigeonTestHelper() {
    flutterInjectorWrapper = mock(Convert.FlutterInjectorWrapper.class);
    assetManager = mock(AssetManager.class);
    bitmapDescriptorFactoryWrapper = mock(Convert.BitmapDescriptorFactoryWrapper.class);
    mockBitmapDescriptor = mock(BitmapDescriptor.class);
  }

  public void setupFakeAssetBitmap() throws IOException {
    when(flutterInjectorWrapper.getLookupKeyForAsset(FAKE_ASSET_NAME)).thenReturn(FAKE_ASSET_NAME);
    when(assetManager.open(FAKE_ASSET_KEY)).thenReturn(buildImageInputStream());
    when(bitmapDescriptorFactoryWrapper.fromAsset(any())).thenReturn(mockBitmapDescriptor);
  }
}
