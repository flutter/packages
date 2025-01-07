package io.flutter.plugins.cameraxexample;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;
import androidx.camera.view.PreviewView;
import androidx.annotation.Nullable;


class NativeView implements PlatformView {
   @NonNull private final TextView textView;
   @NonNull private final PreviewView previewView;

    NativeView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        textView = new TextView(context);
        textView.setTextSize(72);
        textView.setBackgroundColor(Color.rgb(255, 255, 255));
        textView.setText("Rendered on a native Android view (id: " + id + ")");

        previewView = new PreviewView(context);
    }

    @NonNull
    @Override
    public View getView() {
        return previewView;
    }

    @Override
    public void dispose() {}
}