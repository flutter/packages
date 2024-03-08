package hello.world;

import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Binder;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.privacysandbox.ui.core.SandboxedUiAdapter;
import androidx.privacysandbox.ui.provider.SandboxedUiAdapterProxy;
import java.util.Random;
import java.util.concurrent.Executor;

public class TestProvider extends Binder implements hello.world.ITestProvider {
  private final Context sdkContext;

  public TestProvider(Context sdkContext) {
    this.sdkContext = sdkContext;
  }

  private final Handler handler = new Handler(Looper.getMainLooper());

  private static final String TAG = "TestSandboxSdk";
  private static final String AD_URL = "https://www.google.com/";

  @Override
  public IBinder asBinder() {
    return this;
  }

  @Override
  public Bundle loadTestAdWithWaitInsideOnDraw(int count) {
    final BannerAd bannerAd = new BannerAd(count);
    return SandboxedUiAdapterProxy.toCoreLibInfo(bannerAd, sdkContext);
  }

  private class BannerAd implements SandboxedUiAdapter {
    private Executor sessionClientExecutor;
    private SandboxedUiAdapter.SessionClient sessionClient;
    private final int count;

    BannerAd(int count) {
      this.count = count;
    }

    @Override
    public void openSession(
        @NonNull Context context,
        @NonNull IBinder iBinder,
        int initialWidth,
        int initialHeight,
        boolean isZOrderOnTop,
        @NonNull Executor executor,
        @NonNull SessionClient client) {
      sessionClientExecutor = executor;
      sessionClient = client;
      handler.post(
          () -> {
            Log.i(TAG, "Session requested");
            final TestView adView = new TestView(context, count);
            sessionClientExecutor.execute(
                () -> {
                  client.onSessionOpened(new BannerAdSession(adView));
                });
          });
    }

    private class BannerAdSession implements SandboxedUiAdapter.Session {
      private final View view;

      private BannerAdSession(View view) {
        this.view = view;
      }

      @NonNull
      @Override
      public View getView() {
        return view;
      }

      @Override
      public void close() {
        Log.i(TAG, "Closing session");
      }

      @Override
      public void notifyConfigurationChanged(@NonNull Configuration configuration) {
        Log.i(TAG, "Configuration change");
      }

      @Override
      public void notifyResized(int width, int height) {
        Log.i(TAG, String.format("Resized %d %d", width, height));
        view.getLayoutParams().width = width;
        view.getLayoutParams().height = height;
      }

      @Override
      public void notifyZOrderChanged(boolean b) {
        Log.i(TAG, "Z order changed");
      }
    }
  }

  private class TestView extends View {
    private final Random random = new Random();
    private final int count;

    public TestView(Context context, int count) {
      super(context);
      this.count = count;
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
      // We are adding sleep to test the synchronization of the app and the sandbox view's
      // size changes.
      try {
        Thread.sleep(500);
      } catch (InterruptedException e) {
        Log.i(TAG, "Sleep exception");
      }
      super.onDraw(canvas);

      final Paint paint = new Paint();
      paint.setTextSize(50F);
      canvas.drawColor(Color.rgb(random.nextInt(256), random.nextInt(256), random.nextInt(256)));

      final String text = String.format("Mediated Ad %d", count);
      canvas.drawText(text, 75F, 75F, paint);

      setOnClickListener(
          view -> {
            Log.i(TAG, "Click on ad detected");
            final Intent visitUrl = new Intent(Intent.ACTION_VIEW);
            visitUrl.setData(Uri.parse(AD_URL));
            visitUrl.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            sdkContext.startActivity(visitUrl);
          });
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
      Log.i(TAG, "View notification - configuration of the app has changed");
    }
  }
}
