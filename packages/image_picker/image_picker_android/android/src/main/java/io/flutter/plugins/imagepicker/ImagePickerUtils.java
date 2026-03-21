// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.ext.SdkExtensions;
import android.provider.MediaStore;
import java.util.Arrays;

final class ImagePickerUtils {
  /** returns true, if permission present in manifest, otherwise false */
  private static boolean isPermissionPresentInManifest(Context context, String permissionName) {
    try {
      PackageManager packageManager = context.getPackageManager();
      PackageInfo packageInfo;
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        packageInfo =
            packageManager.getPackageInfo(
                context.getPackageName(),
                PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS));
      } else {
        packageInfo = getPermissionsPackageInfoPreApi33(packageManager, context.getPackageName());
      }

      String[] requestedPermissions = packageInfo.requestedPermissions;
      return Arrays.asList(requestedPermissions).contains(permissionName);
    } catch (PackageManager.NameNotFoundException e) {
      e.printStackTrace();
      return false;
    }
  }

  @SuppressWarnings("deprecation")
  private static PackageInfo getPermissionsPackageInfoPreApi33(
      PackageManager packageManager, String packageName)
      throws PackageManager.NameNotFoundException {
    return packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS);
  }

  /**
   * Camera permission needs to be requested if it is present in the manifest, even if the camera
   * permission is not used.
   *
   * <p>Camera permission may be used in another package, as example flutter_barcode_reader.
   * https://github.com/flutter/flutter/issues/29837
   *
   * @return returns true, if need request camera permission, otherwise false
   */
  static boolean needRequestCameraPermission(Context context) {
    return isPermissionPresentInManifest(context, Manifest.permission.CAMERA);
  }

  /**
   * The system photo picker has a maximum limit of selectable items returned by
   * [MediaStore.getPickImagesMaxLimit()] On devices supporting picker provided via
   * [ACTION_SYSTEM_FALLBACK_PICK_IMAGES], the limit may be ignored if it's higher than the allowed
   * limit. On devices not supporting the photo picker, the limit is ignored.
   *
   * @see MediaStore.EXTRA_PICK_IMAGES_MAX
   */
  @SuppressLint({"NewApi", "ClassVerificationFailure"})
  static int getMaxItems() {
    if (Build.VERSION.SDK_INT >= 33
        || (Build.VERSION.SDK_INT >= 30
            && SdkExtensions.getExtensionVersion(Build.VERSION_CODES.R) >= 2)) {
      return MediaStore.getPickImagesMaxLimit();
    } else {
      return Integer.MAX_VALUE;
    }
  }

  static int getLimitFromOption(Messages.GeneralOptions generalOptions) {
    Long limit = generalOptions.getLimit();
    int effectiveLimit = getMaxItems();

    if (limit != null && limit < effectiveLimit) {
      effectiveLimit = Math.toIntExact(limit);
    }

    return effectiveLimit;
  }

  /**
   * Returns whether gallery/media selection should use {@link
   * androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia} (Android Photo
   * Picker) instead of {@link android.content.Intent#ACTION_GET_CONTENT}.
   *
   * <p>On Android 16 (API 36), {@code ACTION_GET_CONTENT} for images may be handled by the system
   * photo picker's {@code PhotopickerGetContentActivity}. That path combined with {@code
   * startActivityForResult} can return {@link android.app.Activity#RESULT_OK} without {@link
   * android.content.Intent#getData()} or usable {@link android.content.ClipData}, so the plugin
   * would complete with no paths. The {@code PickVisualMedia} contract uses the Activity Result API
   * and receives URIs reliably.
   *
   * <p>See <a href="https://github.com/flutter/flutter/issues/182071">flutter/flutter#182071</a>.
   */
  static boolean effectiveUsePhotoPicker(boolean usePhotoPickerFromDart) {
    if (Build.VERSION.SDK_INT >= 36) {
      return true;
    }
    return usePhotoPickerFromDart;
  }
}
