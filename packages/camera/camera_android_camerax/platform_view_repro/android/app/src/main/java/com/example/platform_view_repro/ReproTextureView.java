package com.example.platform_view_repro;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.SurfaceTexture;
import android.util.Log;
import android.view.TextureView;
import androidx.annotation.NonNull;

public class ReproTextureView extends TextureView implements TextureView.SurfaceTextureListener {
  private static final String TAG = "ReproTextureView";
  private final Paint paint;

  public ReproTextureView(@NonNull Context context) {
    super(context);
    setSurfaceTextureListener(this);
    paint = new Paint();
    paint.setColor(Color.CYAN); // Cyan for TextureView (SurfaceView uses Green)
    paint.setStrokeWidth(20f);
    paint.setStyle(Paint.Style.STROKE);
    setOpaque(false);
  }

  private void drawContent(int width, int height) {
    Canvas canvas = null;
    try {
      canvas = lockCanvas();
      if (canvas != null) {
        canvas.drawColor(Color.DKGRAY);
        // Draw cyan border around exact width and height of the surface
        canvas.drawRect(10, 10, width - 10, height - 10, paint);
        // Draw diagonal X to make scaling/stretching instantly visible
        canvas.drawLine(0, 0, width, height, paint);
        canvas.drawLine(0, height, width, 0, paint);
      }
    } finally {
      if (canvas != null) {
        unlockCanvasAndPost(canvas);
      }
    }
  }

  @Override
  public void onSurfaceTextureAvailable(@NonNull SurfaceTexture surface, int width, int height) {
    Log.i(TAG, "onSurfaceTextureAvailable: " + width + "x" + height + " (timestamp: " + System.currentTimeMillis() + "ms)");
    drawContent(width, height);
  }

  @Override
  public void onSurfaceTextureSizeChanged(@NonNull SurfaceTexture surface, int width, int height) {
    Log.i(TAG, "onSurfaceTextureSizeChanged: " + width + "x" + height + " (timestamp: " + System.currentTimeMillis() + "ms)");
    drawContent(width, height);
  }

  @Override
  public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
    Log.i(TAG, "onSurfaceTextureDestroyed (timestamp: " + System.currentTimeMillis() + "ms)");
    return true;
  }

  @Override
  public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surface) {
  }
}
