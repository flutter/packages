package com.example.platform_view_repro;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import androidx.annotation.NonNull;

public class ReproSurfaceView extends SurfaceView implements SurfaceHolder.Callback {
  private static final String TAG = "ReproSurfaceView";
  private final Paint paint;

  public ReproSurfaceView(Context context) {
    super(context);
    getHolder().addCallback(this);
    paint = new Paint();
    paint.setColor(Color.GREEN);
    paint.setStrokeWidth(20f);
    paint.setStyle(Paint.Style.STROKE);
  }

  @Override
  public void surfaceCreated(@NonNull SurfaceHolder holder) {
    Log.i(TAG, "surfaceCreated");
  }

  @Override
  public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {
    Log.i(TAG, "surfaceChanged: " + width + "x" + height + " (timestamp: " + System.currentTimeMillis() + "ms)");
    Canvas canvas = null;
    try {
      canvas = holder.lockCanvas();
      if (canvas != null) {
        canvas.drawColor(Color.DKGRAY);
        // Draw a green border around the exact width and height of the surface
        canvas.drawRect(10, 10, width - 10, height - 10, paint);
        // Draw diagonal X to make scaling/stretching instantly visible
        canvas.drawLine(0, 0, width, height, paint);
        canvas.drawLine(0, height, width, 0, paint);
      }
    } finally {
      if (canvas != null) {
        holder.unlockCanvasAndPost(canvas);
      }
    }
  }

  @Override
  public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
    Log.i(TAG, "surfaceDestroyed");
  }
}
