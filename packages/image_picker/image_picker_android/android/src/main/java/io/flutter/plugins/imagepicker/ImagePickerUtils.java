// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.MediaStore;
import androidx.activity.result.contract.ActivityResultContracts;
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
   * Camera permission need request if it present in manifest, because for M or great for take Photo
   * ar Video by intent need it permission, even if the camera permission is not used.
   *
   * <p>Camera permission may be used in another package, as example flutter_barcode_reader.
   * https://github.com/flutter/flutter/issues/29837
   *
   * @return returns true, if need request camera permission, otherwise false
   */
  static boolean needRequestCameraPermission(Context context) {
    boolean greatOrEqualM = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M;
    return greatOrEqualM && isPermissionPresentInManifest(context, Manifest.permission.CAMERA);
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
    if (ActivityResultContracts.PickVisualMedia.isSystemPickerAvailable$activity_release()) {
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
}
