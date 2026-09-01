package com.example.platform_view_repro;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

public class ReproRedBoxView extends FrameLayout {
  private static final String TAG = "ReproRedBoxView";
  private final Paint paint;

  public ReproRedBoxView(Context context) {
    super(context);
    setBackgroundColor(Color.RED);
    setWillNotDraw(false);
    
    paint = new Paint();
    paint.setColor(Color.WHITE);
    paint.setStrokeWidth(20f);
    paint.setStyle(Paint.Style.STROKE);
  }

  @Override
  protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    int width = getWidth();
    int height = getHeight();
    Log.i(TAG, "onDraw: " + width + "x" + height + " (timestamp: " + System.currentTimeMillis() + "ms)");
    
    // Draw a white border around the exact width and height of the view
    canvas.drawRect(10, 10, width - 10, height - 10, paint);
    // Draw diagonal X to make scaling/stretching instantly visible
    canvas.drawLine(0, 0, width, height, paint);
    canvas.drawLine(0, height, width, 0, paint);
  }
}
