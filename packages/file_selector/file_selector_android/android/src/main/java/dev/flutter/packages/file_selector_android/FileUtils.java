package dev.flutter.packages.file_selector_android;


import android.annotation.TargetApi;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class FileUtils {
    @TargetApi(19)
    public static String getRealPathFromURI(final Context context, final Uri uri) {
        String path = "";
        try {
            path = processUri(context, uri);
        } catch (Exception exception) {
            exception.printStackTrace();
        }
        if (TextUtils.isEmpty(path)) {
            path = copyFile(context, uri);
        }
        return path;
    }

    private static String processUri(Context context, Uri uri) {
        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;
        String path = "";
        // DocumentProvider
            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
				System.out.println("1");
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    path = Environment.getExternalStorageDirectory() + "/" + split[1];
                }
            } else if (isDownloadsDocument(uri)) { // DownloadsProvider
							System.out.println("2");

                final String id = DocumentsContract.getDocumentId(uri);
                //Starting with Android O, this "id" is not necessarily a long (row number),
                //but might also be a "raw:/some/file/path" URL
                if (id != null && id.startsWith("raw:/")) {
                    Uri rawuri = Uri.parse(id);
                    path = rawuri.getPath();
                } else {
                    String[] contentUriPrefixesToTry = new String[]{
                            "content://downloads/public_downloads",
                            "content://downloads/my_downloads"
                    };
                    for (String contentUriPrefix : contentUriPrefixesToTry) {
                        final Uri contentUri = ContentUris.withAppendedId(
                                Uri.parse(contentUriPrefix), Long.valueOf(id));
                        path = getDataColumn(context, contentUri, null, null);
                        if (!TextUtils.isEmpty(path)) {
                            break;
                        }
                    }
                }
            } else if (isMediaDocument(uri)) { // MediaProvider
							System.out.println("3");

                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];
                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[] {
                        split[1]
                };

                path = getDataColumn(context, contentUri, selection, selectionArgs);
            }  else if ("content".equalsIgnoreCase(uri.getScheme())) {
								System.out.println("4");

                path = getDataColumn(context, uri, null, null);
            }
        }
        return path;
    }

    static String copyFile(Context context, Uri uri) {
        try {
            InputStream attachment = context.getContentResolver().openInputStream(uri);
            if (attachment != null) {
                String filename = getContentName(context.getContentResolver(), uri);
                if (filename != null) {
                    File file = new File(context.getCacheDir(), filename);
                    FileOutputStream tmp = new FileOutputStream(file);
                    byte[] buffer = new byte[1024];
                    while (attachment.read(buffer) > 0) {
                        tmp.write(buffer);
                    }
                    tmp.close();
                    attachment.close();
                    return file.getAbsolutePath();
                }
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private static String getContentName(ContentResolver resolver, Uri uri) {
        Cursor cursor = resolver.query(uri, null, null, null, null);
        if (cursor != null) {
            cursor.moveToFirst();
            int nameIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME);
            if (nameIndex >= 0) {
                String name = cursor.getString(nameIndex);
                cursor.close();
                return name;
            }
        }
        return null;
    }

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context The context.
     * @param uri The Uri to query.
     * @param selection (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public static String getDataColumn(Context context, Uri uri, String selection,
                                       String[] selectionArgs) {
        Cursor cursor = null;
        String result = null;
        final String column = "_data";
        final String[] projection = { column };
        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int index = cursor.getColumnIndexOrThrow(column);
                result = cursor.getString(index);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return result;
    }


    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }
}