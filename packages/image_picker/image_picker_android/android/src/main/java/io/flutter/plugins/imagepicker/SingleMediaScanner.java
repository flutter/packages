package io.flutter.plugins.imagepicker;

import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;

import java.io.File;

public class SingleMediaScanner {
    private final Context context;
    private final String filePath;
    private final OnScanCompletedListener onScanCompletedListener;

    public SingleMediaScanner(Context context, String filePath, OnScanCompletedListener onScanCompletedListener) {
        this.context = context;
        this.filePath = filePath;
        this.onScanCompletedListener = onScanCompletedListener;
    }

    public void scan() {
        File file = new File(filePath);
        Uri contentUri;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            contentUri = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);
        } else {
            contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        }

        ContentValues values = new ContentValues();
        values.put(MediaStore.Images.Media.DISPLAY_NAME, file.getName());
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg"); // Adjust MIME type if needed
        values.put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000);
        values.put(MediaStore.Images.Media.DATE_MODIFIED, file.lastModified() / 1000);
        values.put(MediaStore.Images.Media.SIZE, file.length());
        values.put(MediaStore.Images.Media.DATA, filePath);

        Uri uri = context.getContentResolver().insert(contentUri, values);

        if (uri != null) {
            onScanCompletedListener.completed(filePath, uri);
        } else {
            onScanCompletedListener.completed(filePath, null);
        }
    }

    public interface OnScanCompletedListener {
        void completed(String path, Uri uri);
    }
}
