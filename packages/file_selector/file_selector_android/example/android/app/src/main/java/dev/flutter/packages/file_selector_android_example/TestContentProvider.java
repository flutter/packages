package dev.flutter.packages.file_selector_android_example;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.FileNotFoundException;

public class TestContentProvider extends ContentProvider {
  @Override
  public boolean onCreate() {
    return true;
  }

  @Nullable
  @Override
  public Cursor query(
      @NonNull Uri uri,
      @Nullable String[] strings,
      @Nullable String s,
      @Nullable String[] strings1,
      @Nullable String s1) {
    MatrixCursor cursor =
        new MatrixCursor(new String[] {OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE});
    cursor.addRow(new Object[] {"dummy.png", 1});
    return cursor;
  }

  @Nullable
  @Override
  public String getType(@NonNull Uri uri) {
    return "image/png";
  }

  @Nullable
  @Override
  public AssetFileDescriptor openAssetFile(@NonNull Uri uri, @NonNull String mode)
      throws FileNotFoundException {
    return getContext().getResources().openRawResourceFd(R.raw.ic_launcher);
  }

  @Nullable
  @Override
  public Uri insert(@NonNull Uri uri, @Nullable ContentValues contentValues) {
    return null;
  }

  @Override
  public int delete(@NonNull Uri uri, @Nullable String s, @Nullable String[] strings) {
    return 0;
  }

  @Override
  public int update(
      @NonNull Uri uri,
      @Nullable ContentValues contentValues,
      @Nullable String s,
      @Nullable String[] strings) {
    return 0;
  }
}
