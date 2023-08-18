// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static androidx.exifinterface.media.ExifInterface.*;
import android.util.Log;
import androidx.exifinterface.media.ExifInterface;
import java.util.Arrays;
import java.util.List;

class ExifDataCopier {
  void copyExif(String filePathOri, String filePathDest) {
    try {
      ExifInterface oldExif = new ExifInterface(filePathOri);
      ExifInterface newExif = new ExifInterface(filePathDest);

      List<String> attributes =
          Arrays.asList(
              TAG_IMAGE_DESCRIPTION,
              TAG_MAKE,
              TAG_MODEL,
              TAG_SOFTWARE,
              TAG_DATETIME,
              TAG_ARTIST,
              TAG_COPYRIGHT,
              TAG_EXPOSURE_TIME,
              TAG_F_NUMBER,
              TAG_EXPOSURE_PROGRAM,
              TAG_SPECTRAL_SENSITIVITY,
              TAG_PHOTOGRAPHIC_SENSITIVITY,
              TAG_ISO_SPEED_RATINGS,
              TAG_OECF,
              TAG_SENSITIVITY_TYPE,
              TAG_STANDARD_OUTPUT_SENSITIVITY,
              TAG_RECOMMENDED_EXPOSURE_INDEX,
              TAG_ISO_SPEED,
              TAG_ISO_SPEED_LATITUDE_YYY,
              TAG_ISO_SPEED_LATITUDE_ZZZ,
              TAG_EXIF_VERSION,
              TAG_DATETIME_ORIGINAL,
              TAG_DATETIME_DIGITIZED,
              TAG_OFFSET_TIME,
              TAG_OFFSET_TIME_ORIGINAL,
              TAG_OFFSET_TIME_DIGITIZED,
              TAG_SHUTTER_SPEED_VALUE,
              TAG_APERTURE_VALUE,
              TAG_BRIGHTNESS_VALUE,
              TAG_EXPOSURE_BIAS_VALUE,
              TAG_MAX_APERTURE_VALUE,
              TAG_SUBJECT_DISTANCE,
              TAG_METERING_MODE,
              TAG_LIGHT_SOURCE,
              TAG_FLASH,
              TAG_FOCAL_LENGTH,
              TAG_MAKER_NOTE,
              TAG_USER_COMMENT,
              TAG_SUBSEC_TIME,
              TAG_SUBSEC_TIME_ORIGINAL,
              TAG_SUBSEC_TIME_DIGITIZED,
              TAG_FLASHPIX_VERSION,
              TAG_FLASH_ENERGY,
              TAG_SPATIAL_FREQUENCY_RESPONSE,
              TAG_FOCAL_PLANE_X_RESOLUTION,
              TAG_FOCAL_PLANE_Y_RESOLUTION,
              TAG_FOCAL_PLANE_RESOLUTION_UNIT,
              TAG_EXPOSURE_INDEX,
              TAG_SENSING_METHOD,
              TAG_FILE_SOURCE,
              TAG_SCENE_TYPE,
              TAG_CFA_PATTERN,
              TAG_CUSTOM_RENDERED,
              TAG_EXPOSURE_MODE,
              TAG_WHITE_BALANCE,
              TAG_DIGITAL_ZOOM_RATIO,
              TAG_FOCAL_LENGTH_IN_35MM_FILM,
              TAG_SCENE_CAPTURE_TYPE,
              TAG_GAIN_CONTROL,
              TAG_CONTRAST,
              TAG_SATURATION,
              TAG_SHARPNESS,
              TAG_DEVICE_SETTING_DESCRIPTION,
              TAG_SUBJECT_DISTANCE_RANGE,
              TAG_IMAGE_UNIQUE_ID,
              TAG_CAMERA_OWNER_NAME,
              TAG_BODY_SERIAL_NUMBER,
              TAG_LENS_SPECIFICATION,
              TAG_LENS_MAKE,
              TAG_LENS_MODEL,
              TAG_LENS_SERIAL_NUMBER,
              TAG_GPS_VERSION_ID,
              TAG_GPS_LATITUDE_REF,
              TAG_GPS_LATITUDE,
              TAG_GPS_LONGITUDE_REF,
              TAG_GPS_LONGITUDE,
              TAG_GPS_ALTITUDE_REF,
              TAG_GPS_ALTITUDE,
              TAG_GPS_TIMESTAMP,
              TAG_GPS_SATELLITES,
              TAG_GPS_STATUS,
              TAG_GPS_MEASURE_MODE,
              TAG_GPS_DOP,
              TAG_GPS_SPEED_REF,
              TAG_GPS_SPEED,
              TAG_GPS_TRACK_REF,
              TAG_GPS_TRACK,
              TAG_GPS_IMG_DIRECTION_REF,
              TAG_GPS_IMG_DIRECTION,
              TAG_GPS_MAP_DATUM,
              TAG_GPS_DEST_LATITUDE_REF,
              TAG_GPS_DEST_LATITUDE,
              TAG_GPS_DEST_LONGITUDE_REF,
              TAG_GPS_DEST_LONGITUDE,
              TAG_GPS_DEST_BEARING_REF,
              TAG_GPS_DEST_BEARING,
              TAG_GPS_DEST_DISTANCE_REF,
              TAG_GPS_DEST_DISTANCE,
              TAG_GPS_PROCESSING_METHOD,
              TAG_GPS_AREA_INFORMATION,
              TAG_GPS_DATESTAMP,
              TAG_GPS_DIFFERENTIAL,
              TAG_GPS_H_POSITIONING_ERROR,
              TAG_INTEROPERABILITY_INDEX,
              TAG_ORIENTATION
      );
      for (String attribute : attributes) {
        setIfNotNull(oldExif, newExif, attribute);
      }

      newExif.saveAttributes();

    } catch (Exception ex) {
      Log.e("ExifDataCopier", "Error preserving Exif data on selected image: " + ex);
    }
  }

  private static void setIfNotNull(ExifInterface oldExif, ExifInterface newExif, String property) {
    if (oldExif.getAttribute(property) != null) {
      newExif.setAttribute(property, oldExif.getAttribute(property));
    }
  }
}
