// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef CAMERA_LINUX_H
#define CAMERA_LINUX_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__GNUC__)
#define CAMERA_LINUX_EXPORT __attribute__((visibility("default")))
#else
#define CAMERA_LINUX_EXPORT
#endif

// Status values returned by camera_linux_status().
#define CAMERA_LINUX_RUNNING 1
#define CAMERA_LINUX_FAILED -1

// An open capture device with its streaming thread.
typedef struct camera_linux_session camera_linux_session;

// Lists capture devices that this library can use, one per line as
// "<path>\t<card name>\t<fourcc>". The string is malloc()ed (empty when there
// is none); free it with camera_linux_free().
CAMERA_LINUX_EXPORT char* camera_linux_list_devices(void);

// Opens a V4L2 capture device and starts a background thread that keeps the
// most recent frame.
//
// `device` is a path such as "/dev/video0". When it is NULL or empty the
// CAMERA_LINUX_DEVICE environment variable is used, and when that is unset the
// first /dev/video* node that can stream video in a supported pixel format.
// `width` and `height` are a request; the driver may pick a different size
// (see camera_linux_frame_size()). Pass 0 for the defaults (640x480).
// `jpeg_quality` is 1..100 and is used when frames need to be encoded; pass 0
// for the default.
//
// Returns the session, or NULL on failure. On failure, when `error` is not
// NULL, it receives a malloc()ed description (free with camera_linux_free()).
CAMERA_LINUX_EXPORT camera_linux_session* camera_linux_open(
    const char* device, int32_t width, int32_t height, int32_t jpeg_quality,
    char** error);

// Stops the capture thread, closes the device and frees the session. NULL is
// ignored.
CAMERA_LINUX_EXPORT void camera_linux_close(camera_linux_session* session);

// CAMERA_LINUX_RUNNING while frames are being captured, CAMERA_LINUX_FAILED
// when the capture thread stopped because of an error (see
// camera_linux_take_error()).
CAMERA_LINUX_EXPORT int camera_linux_status(camera_linux_session* session);

// Returns the newest frame as a JPEG in a malloc()ed buffer and stores its
// size in `*length`. Each frame is handed out once: the next call returns
// NULL with `*length` 0 until the camera delivers another frame. Also returns
// NULL when a frame could not be converted; in that case
// camera_linux_take_error() returns the reason. Free the buffer with
// camera_linux_free().
CAMERA_LINUX_EXPORT uint8_t* camera_linux_read_jpeg(
    camera_linux_session* session, int32_t* length);

// Takes the pending error message: a malloc()ed copy (free it with
// camera_linux_free()), or NULL when nothing failed since the previous call.
// Errors come from the capture thread (see camera_linux_status()) and frame
// conversion in camera_linux_read_jpeg().
CAMERA_LINUX_EXPORT char* camera_linux_take_error(
    camera_linux_session* session);

// Stores the negotiated frame size.
CAMERA_LINUX_EXPORT void camera_linux_frame_size(camera_linux_session* session,
                                                 int32_t* width,
                                                 int32_t* height);

// Path of the device in use. The string is malloc()ed; free it with
// camera_linux_free().
CAMERA_LINUX_EXPORT char* camera_linux_device_path(
    camera_linux_session* session);

// Frees memory returned by this library.
CAMERA_LINUX_EXPORT void camera_linux_free(void* ptr);

// Pure helpers, exported so they can be unit tested.

// Converts one frame to tightly packed RGB. `dst` must hold width*height*3
// bytes. Returns 0, or -1 if the fourcc is not supported, the dimensions are
// out of range or `src_len` is too short for the frame geometry.
CAMERA_LINUX_EXPORT int camera_linux_frame_to_rgb(
    const uint8_t* src, int32_t src_len, uint32_t fourcc, int32_t width,
    int32_t height, int32_t bytes_per_line, uint8_t* dst);

// Encodes packed RGB (comp 3) or grey (comp 1) pixels as a baseline JPEG.
// `pixels` must hold width*height*comp bytes. Returns a malloc()ed buffer and
// its size, or NULL.
CAMERA_LINUX_EXPORT uint8_t* camera_linux_encode_jpeg(
    const uint8_t* pixels, int32_t width, int32_t height, int32_t comp,
    int32_t quality, int32_t* length);

// Returns a malloc()ed copy of a (M)JPEG frame with the standard Huffman
// tables inserted when the frame has none, which is how many UVC cameras
// emit MJPEG. Returns NULL (and sets *length to 0) when the data is not a
// JPEG.
CAMERA_LINUX_EXPORT uint8_t* camera_linux_fix_mjpeg(const uint8_t* src,
                                                    int32_t src_len,
                                                    int32_t* length);

#ifdef __cplusplus
}
#endif

#endif  // CAMERA_LINUX_H
