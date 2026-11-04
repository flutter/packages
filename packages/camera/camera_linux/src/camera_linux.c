// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// V4L2 webcam capture for the camera_linux Flutter package.
//
// Each session owns one device and a background thread that streams frames
// from it with memory-mapped buffers and keeps the newest one. Readers get that
// frame as a JPEG, either passed through (MJPEG cameras) or encoded here from
// the raw pixels. Nothing outside libc and the kernel UAPI headers is used.

// scandir(), strdup() and the POSIX thread API.
#define _DEFAULT_SOURCE

#include "camera_linux.h"

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <poll.h>
#include <pthread.h>
#include <stdarg.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_WRITE_STATIC
#define STBI_WRITE_NO_STDIO
#include "third_party/stb/stb_image_write.h"

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_JPEG_QUALITY 85
#define BUFFER_COUNT 4
#define MAX_VIDEO_NODES 64
#define POLL_TIMEOUT_MS 500
// Largest frame edge accepted anywhere; keeps every size computation below
// well inside int32_t.
#define MAX_DIMENSION 16384

// ---------------------------------------------------------------------------
// Errors

// A fixed-size message slot. Each session carries one; camera_linux_open()
// uses a local one until the session exists.
typedef struct {
  char text[512];
  bool set;
} error_slot;

static void slot_vset(error_slot *slot, const char *fmt, va_list ap) {
  vsnprintf(slot->text, sizeof(slot->text), fmt, ap);
  slot->set = true;
}

static void slot_set(error_slot *slot, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  slot_vset(slot, fmt, ap);
  va_end(ap);
}

static void slot_set_errno(error_slot *slot, const char *what) {
  slot_set(slot, "%s: %s", what, strerror(errno));
}

static char *slot_take(error_slot *slot) {
  if (!slot->set) return NULL;
  slot->set = false;
  return strdup(slot->text);
}

void camera_linux_free(void *ptr) { free(ptr); }

// ---------------------------------------------------------------------------
// Pixel formats

static int format_rank(uint32_t fourcc) {
  // Lower ranks first. Uncompressed formats are preferred because the JPEG is
  // then produced here and is the same for every camera; MJPEG from the
  // camera is the fallback.
  switch (fourcc) {
    case V4L2_PIX_FMT_YUYV:
      return 0;
    case V4L2_PIX_FMT_UYVY:
    case V4L2_PIX_FMT_YVYU:
    case V4L2_PIX_FMT_VYUY:
      return 1;
    case V4L2_PIX_FMT_NV12:
    case V4L2_PIX_FMT_NV21:
    case V4L2_PIX_FMT_YUV420:
    case V4L2_PIX_FMT_YVU420:
      return 2;
    case V4L2_PIX_FMT_RGB24:
    case V4L2_PIX_FMT_BGR24:
      return 3;
    case V4L2_PIX_FMT_GREY:
      return 4;
    case V4L2_PIX_FMT_MJPEG:
    case V4L2_PIX_FMT_JPEG:
      return 5;
    default:
      return -1;
  }
}

static bool is_jpeg_format(uint32_t fourcc) {
  return fourcc == V4L2_PIX_FMT_MJPEG || fourcc == V4L2_PIX_FMT_JPEG;
}

static void fourcc_string(uint32_t fourcc, char out[5]) {
  for (int i = 0; i < 4; i++) {
    unsigned char c = (unsigned char)(fourcc >> (8 * i));
    out[i] = (c >= 32 && c < 127) ? (char)c : '?';
  }
  out[4] = '\0';
}

static inline uint8_t clamp8(int v) {
  return (uint8_t)(v < 0 ? 0 : (v > 255 ? 255 : v));
}

// ITU-R BT.601, limited range (Y 16..235, Cb/Cr 16..240), which is what UVC
// webcams produce.
static inline void yuv_to_rgb(int y, int u, int v, uint8_t *rgb) {
  int c = 298 * (y - 16) + 128;
  int d = u - 128;
  int e = v - 128;
  rgb[0] = clamp8((c + 409 * e) >> 8);
  rgb[1] = clamp8((c - 100 * d - 208 * e) >> 8);
  rgb[2] = clamp8((c + 516 * d) >> 8);
}

// Packed 4:2:2 with the given byte offsets of Y0, Y1 and the two chroma
// samples inside each 4-byte macropixel.
static void convert_yuv422(const uint8_t *src, int32_t stride, int32_t w,
                           int32_t h, int y0, int y1, int uo, int vo,
                           uint8_t *dst) {
  for (int32_t row = 0; row < h; row++) {
    const uint8_t *s = src + (size_t)row * stride;
    uint8_t *d = dst + (size_t)row * w * 3;
    for (int32_t x = 0; x < w; x += 2) {
      int u = s[uo], v = s[vo];
      yuv_to_rgb(s[y0], u, v, d);
      if (x + 1 < w) yuv_to_rgb(s[y1], u, v, d + 3);
      s += 4;
      d += 6;
    }
  }
}

int camera_linux_frame_to_rgb(const uint8_t *src, int32_t src_len,
                              uint32_t fourcc, int32_t w, int32_t h,
                              int32_t stride, uint8_t *dst) {
  if (!src || !dst || w <= 0 || h <= 0 || src_len < 0) return -1;
  if (w > MAX_DIMENSION || h > MAX_DIMENSION) return -1;
  int64_t need;
  switch (fourcc) {
    case V4L2_PIX_FMT_YUYV:
    case V4L2_PIX_FMT_YVYU:
    case V4L2_PIX_FMT_UYVY:
    case V4L2_PIX_FMT_VYUY: {
      int32_t min_stride = ((w + 1) / 2) * 4;
      if (stride < min_stride) stride = min_stride;
      need = (int64_t)stride * (h - 1) + min_stride;
      if (need > src_len) return -1;
      switch (fourcc) {
        case V4L2_PIX_FMT_YUYV:
          convert_yuv422(src, stride, w, h, 0, 2, 1, 3, dst);
          break;
        case V4L2_PIX_FMT_YVYU:
          convert_yuv422(src, stride, w, h, 0, 2, 3, 1, dst);
          break;
        case V4L2_PIX_FMT_UYVY:
          convert_yuv422(src, stride, w, h, 1, 3, 0, 2, dst);
          break;
        default:  // VYUY
          convert_yuv422(src, stride, w, h, 1, 3, 2, 0, dst);
          break;
      }
      return 0;
    }
    case V4L2_PIX_FMT_NV12:
    case V4L2_PIX_FMT_NV21: {
      if (stride < w) stride = w;
      int32_t ch = (h + 1) / 2;
      // Chroma rows hold 2 * ceil(w / 2) bytes; the last one may be shorter
      // than the stride.
      need = (int64_t)stride * h + (int64_t)stride * (ch - 1) + ((w + 1) / 2) * 2;
      if (need > src_len) return -1;
      const uint8_t *uv = src + (size_t)stride * h;
      bool nv21 = fourcc == V4L2_PIX_FMT_NV21;
      for (int32_t row = 0; row < h; row++) {
        const uint8_t *y = src + (size_t)row * stride;
        const uint8_t *c = uv + (size_t)(row / 2) * stride;
        uint8_t *d = dst + (size_t)row * w * 3;
        for (int32_t x = 0; x < w; x++) {
          int u = c[(x / 2) * 2 + (nv21 ? 1 : 0)];
          int v = c[(x / 2) * 2 + (nv21 ? 0 : 1)];
          yuv_to_rgb(y[x], u, v, d + (size_t)x * 3);
        }
      }
      return 0;
    }
    case V4L2_PIX_FMT_YUV420:
    case V4L2_PIX_FMT_YVU420: {
      if (stride < w) stride = w;
      int32_t cstride = (stride + 1) / 2;
      int32_t ch = (h + 1) / 2;
      need = (int64_t)stride * h + 2 * (int64_t)cstride * ch;
      if (need > src_len) return -1;
      const uint8_t *p1 = src + (size_t)stride * h;
      const uint8_t *p2 = p1 + (size_t)cstride * ch;
      const uint8_t *up = fourcc == V4L2_PIX_FMT_YUV420 ? p1 : p2;
      const uint8_t *vp = fourcc == V4L2_PIX_FMT_YUV420 ? p2 : p1;
      for (int32_t row = 0; row < h; row++) {
        const uint8_t *y = src + (size_t)row * stride;
        const uint8_t *u = up + (size_t)(row / 2) * cstride;
        const uint8_t *v = vp + (size_t)(row / 2) * cstride;
        uint8_t *d = dst + (size_t)row * w * 3;
        for (int32_t x = 0; x < w; x++) {
          yuv_to_rgb(y[x], u[x / 2], v[x / 2], d + (size_t)x * 3);
        }
      }
      return 0;
    }
    case V4L2_PIX_FMT_RGB24:
    case V4L2_PIX_FMT_BGR24: {
      if (stride < w * 3) stride = w * 3;
      need = (int64_t)stride * (h - 1) + (int64_t)w * 3;
      if (need > src_len) return -1;
      bool bgr = fourcc == V4L2_PIX_FMT_BGR24;
      for (int32_t row = 0; row < h; row++) {
        const uint8_t *s = src + (size_t)row * stride;
        uint8_t *d = dst + (size_t)row * w * 3;
        if (!bgr) {
          memcpy(d, s, (size_t)w * 3);
        } else {
          for (int32_t x = 0; x < w; x++) {
            d[x * 3 + 0] = s[x * 3 + 2];
            d[x * 3 + 1] = s[x * 3 + 1];
            d[x * 3 + 2] = s[x * 3 + 0];
          }
        }
      }
      return 0;
    }
    case V4L2_PIX_FMT_GREY: {
      if (stride < w) stride = w;
      need = (int64_t)stride * (h - 1) + w;
      if (need > src_len) return -1;
      for (int32_t row = 0; row < h; row++) {
        const uint8_t *s = src + (size_t)row * stride;
        uint8_t *d = dst + (size_t)row * w * 3;
        for (int32_t x = 0; x < w; x++) {
          d[x * 3] = d[x * 3 + 1] = d[x * 3 + 2] = s[x];
        }
      }
      return 0;
    }
    default:
      return -1;
  }
}

// ---------------------------------------------------------------------------
// JPEG

typedef struct {
  uint8_t *data;
  size_t len;
  size_t cap;
  bool failed;
} byte_buffer;

static bool buffer_append(byte_buffer *b, const void *src, size_t n) {
  if (b->failed) return false;
  if (b->len + n > b->cap) {
    size_t cap = b->cap ? b->cap * 2 : 64 * 1024;
    while (cap < b->len + n) cap *= 2;
    uint8_t *data = realloc(b->data, cap);
    if (!data) {
      b->failed = true;
      return false;
    }
    b->data = data;
    b->cap = cap;
  }
  memcpy(b->data + b->len, src, n);
  b->len += n;
  return true;
}

static void stb_write_callback(void *context, void *data, int size) {
  buffer_append((byte_buffer *)context, data, (size_t)size);
}

uint8_t *camera_linux_encode_jpeg(const uint8_t *pixels, int32_t w, int32_t h,
                                  int32_t comp, int32_t quality,
                                  int32_t *length) {
  if (length) *length = 0;
  if (!pixels || !length || w <= 0 || h <= 0 || (comp != 1 && comp != 3)) {
    return NULL;
  }
  if (w > MAX_DIMENSION || h > MAX_DIMENSION) return NULL;
  if (quality <= 0 || quality > 100) quality = DEFAULT_JPEG_QUALITY;
  byte_buffer out = {0};
  int ok = stbi_write_jpg_to_func(stb_write_callback, &out, w, h, comp, pixels,
                                  quality);
  if (!ok || out.failed || out.len > INT32_MAX) {
    free(out.data);
    return NULL;
  }
  *length = (int32_t)out.len;
  return out.data;
}

// Standard Huffman tables (JPEG Annex K.3), as a complete DHT segment. UVC
// cameras may omit them from MJPEG frames; decoders such as Skia and
// package:image then reject the frame.
static const uint8_t dht_dc_lum_counts[16] = {0, 1, 5, 1, 1, 1, 1, 1,
                                              1, 0, 0, 0, 0, 0, 0, 0};
static const uint8_t dht_dc_chr_counts[16] = {0, 3, 1, 1, 1, 1, 1, 1,
                                              1, 1, 1, 0, 0, 0, 0, 0};
static const uint8_t dht_dc_values[12] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
static const uint8_t dht_ac_lum_counts[16] = {0, 2, 1, 3, 3, 2, 4, 3,
                                              5, 5, 4, 4, 0, 0, 1, 0x7d};
static const uint8_t dht_ac_lum_values[162] = {
    0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06,
    0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xa1, 0x08,
    0x23, 0x42, 0xb1, 0xc1, 0x15, 0x52, 0xd1, 0xf0, 0x24, 0x33, 0x62, 0x72,
    0x82, 0x09, 0x0a, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x25, 0x26, 0x27, 0x28,
    0x29, 0x2a, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x43, 0x44, 0x45,
    0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
    0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x73, 0x74, 0x75,
    0x76, 0x77, 0x78, 0x79, 0x7a, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
    0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3,
    0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6,
    0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9,
    0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe1, 0xe2,
    0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xf1, 0xf2, 0xf3, 0xf4,
    0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa};
static const uint8_t dht_ac_chr_counts[16] = {0, 2, 1, 2, 4, 4, 3, 4,
                                              7, 5, 4, 4, 0, 1, 2, 0x77};
static const uint8_t dht_ac_chr_values[162] = {
    0x00, 0x01, 0x02, 0x03, 0x11, 0x04, 0x05, 0x21, 0x31, 0x06, 0x12, 0x41,
    0x51, 0x07, 0x61, 0x71, 0x13, 0x22, 0x32, 0x81, 0x08, 0x14, 0x42, 0x91,
    0xa1, 0xb1, 0xc1, 0x09, 0x23, 0x33, 0x52, 0xf0, 0x15, 0x62, 0x72, 0xd1,
    0x0a, 0x16, 0x24, 0x34, 0xe1, 0x25, 0xf1, 0x17, 0x18, 0x19, 0x1a, 0x26,
    0x27, 0x28, 0x29, 0x2a, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x43, 0x44,
    0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
    0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x73, 0x74,
    0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
    0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a,
    0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4,
    0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
    0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda,
    0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xf2, 0xf3, 0xf4,
    0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa};

// 2 (length) + 2 * (1 + 16 + 12) + 2 * (1 + 16 + 162) = 418 = 0x1a2.
#define DHT_SEGMENT_LENGTH 418

static bool append_dht_segment(byte_buffer *b) {
  static const uint8_t header[4] = {0xff, 0xc4, DHT_SEGMENT_LENGTH >> 8,
                                    DHT_SEGMENT_LENGTH & 0xff};
  static const uint8_t cls_dc_lum = 0x00, cls_dc_chr = 0x01;
  static const uint8_t cls_ac_lum = 0x10, cls_ac_chr = 0x11;
  // Same table order as stb_image_write, so a repaired frame matches what
  // this library encodes itself.
  return buffer_append(b, header, sizeof(header)) &&
         buffer_append(b, &cls_dc_lum, 1) &&
         buffer_append(b, dht_dc_lum_counts, 16) &&
         buffer_append(b, dht_dc_values, 12) &&
         buffer_append(b, &cls_ac_lum, 1) &&
         buffer_append(b, dht_ac_lum_counts, 16) &&
         buffer_append(b, dht_ac_lum_values, 162) &&
         buffer_append(b, &cls_dc_chr, 1) &&
         buffer_append(b, dht_dc_chr_counts, 16) &&
         buffer_append(b, dht_dc_values, 12) &&
         buffer_append(b, &cls_ac_chr, 1) &&
         buffer_append(b, dht_ac_chr_counts, 16) &&
         buffer_append(b, dht_ac_chr_values, 162);
}

uint8_t *camera_linux_fix_mjpeg(const uint8_t *src, int32_t src_len,
                                int32_t *length) {
  if (length) *length = 0;
  if (!src || !length || src_len < 4 || src[0] != 0xff || src[1] != 0xd8) {
    return NULL;
  }
  // Walk the marker segments up to the first scan. Insert the tables in
  // front of the scan when no DHT was seen. Anything unexpected is passed
  // through unchanged and left to the decoder.
  int32_t pos = 2;
  int32_t insert_at = -1;
  while (pos + 4 <= src_len) {
    if (src[pos] != 0xff) break;
    uint8_t marker = src[pos + 1];
    if (marker == 0xff) {  // fill byte
      pos++;
      continue;
    }
    if (marker == 0xd8 || marker == 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
      pos += 2;  // standalone markers
      continue;
    }
    if (marker == 0xc4) break;  // has Huffman tables
    if (marker == 0xda) {       // start of scan
      insert_at = pos;
      break;
    }
    int32_t seg_len = (src[pos + 2] << 8) | src[pos + 3];
    if (seg_len < 2) break;
    pos += 2 + seg_len;
  }
  byte_buffer out = {0};
  if (insert_at < 0) {
    buffer_append(&out, src, (size_t)src_len);
  } else {
    buffer_append(&out, src, (size_t)insert_at);
    append_dht_segment(&out);
    buffer_append(&out, src + insert_at, (size_t)(src_len - insert_at));
  }
  if (out.failed || out.len > INT32_MAX) {
    free(out.data);
    return NULL;
  }
  *length = (int32_t)out.len;
  return out.data;
}

// ---------------------------------------------------------------------------
// Device probing

typedef struct {
  char path[256];
  char card[33];  // v4l2_capability.card is 32 bytes, not always NUL-terminated
  uint32_t fourcc;
} device_info;

static int xioctl(int fd, unsigned long request, void *arg) {
  int r;
  do {
    r = ioctl(fd, request, arg);
  } while (r == -1 && errno == EINTR);
  return r;
}

// Opens `path` and checks that it is a streaming video capture device with a
// pixel format this library understands. On success stores the preferred
// format in `info` and returns the open descriptor; otherwise returns -1 and,
// when `why` is given, a short reason.
static int probe_device(const char *path, device_info *info, const char **why) {
  int fd = open(path, O_RDWR | O_NONBLOCK | O_CLOEXEC);
  if (fd < 0) {
    if (why) *why = strerror(errno);
    return -1;
  }
  struct v4l2_capability cap;
  memset(&cap, 0, sizeof(cap));
  if (xioctl(fd, VIDIOC_QUERYCAP, &cap) < 0) {
    if (why) *why = "not a V4L2 device";
    close(fd);
    return -1;
  }
  uint32_t caps = (cap.capabilities & V4L2_CAP_DEVICE_CAPS) ? cap.device_caps
                                                             : cap.capabilities;
  if (!(caps & V4L2_CAP_VIDEO_CAPTURE) || !(caps & V4L2_CAP_STREAMING)) {
    if (why) *why = "not a streaming video capture device";
    close(fd);
    return -1;
  }
  int best_rank = -1;
  uint32_t best_fourcc = 0;
  for (uint32_t i = 0;; i++) {
    struct v4l2_fmtdesc desc;
    memset(&desc, 0, sizeof(desc));
    desc.index = i;
    desc.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (xioctl(fd, VIDIOC_ENUM_FMT, &desc) < 0) break;
    int rank = format_rank(desc.pixelformat);
    if (rank >= 0 && (best_rank < 0 || rank < best_rank)) {
      best_rank = rank;
      best_fourcc = desc.pixelformat;
    }
  }
  if (best_rank < 0) {
    if (why) *why = "no supported pixel format";
    close(fd);
    return -1;
  }
  snprintf(info->path, sizeof(info->path), "%s", path);
  snprintf(info->card, sizeof(info->card), "%.32s", (const char *)cap.card);
  info->fourcc = best_fourcc;
  return fd;
}

static int video_node_filter(const struct dirent *entry) {
  if (strncmp(entry->d_name, "video", 5) != 0) return 0;
  const char *digits = entry->d_name + 5;
  if (!*digits) return 0;
  for (const char *p = digits; *p; p++) {
    if (*p < '0' || *p > '9') return 0;
  }
  return 1;
}

// Node number of "videoN"; the filter above guarantees digits only.
static long video_node_number(const struct dirent *entry) {
  long n = 0;
  for (const char *p = entry->d_name + 5; *p && n < 1000000; p++) {
    n = n * 10 + (*p - '0');
  }
  return n;
}

static int video_node_compare(const struct dirent **a, const struct dirent **b) {
  long na = video_node_number(*a);
  long nb = video_node_number(*b);
  return na < nb ? -1 : (na > nb ? 1 : 0);
}

// Calls `fn` for each /dev/videoN in numeric order until it returns true.
static void for_each_video_node(bool (*fn)(const char *path, void *ctx),
                                void *ctx) {
  struct dirent **entries = NULL;
  int n = scandir("/dev", &entries, video_node_filter, video_node_compare);
  if (n < 0) return;
  for (int i = 0; i < n; i++) {
    if (i < MAX_VIDEO_NODES) {
      char path[sizeof("/dev/") + sizeof(entries[i]->d_name)];
      snprintf(path, sizeof(path), "/dev/%s", entries[i]->d_name);
      if (fn(path, ctx)) {
        for (int j = i; j < n; j++) free(entries[j]);
        break;
      }
    }
    free(entries[i]);
  }
  free(entries);
}

typedef struct {
  device_info info;
  int fd;
} first_device_ctx;

static bool take_first_device(const char *path, void *ctx) {
  first_device_ctx *c = ctx;
  c->fd = probe_device(path, &c->info, NULL);
  return c->fd >= 0;
}

static bool append_device_line(const char *path, void *ctx) {
  device_info info;
  int fd = probe_device(path, &info, NULL);
  if (fd < 0) return false;
  close(fd);
  char fourcc[5];
  fourcc_string(info.fourcc, fourcc);
  char line[sizeof(info.path) + sizeof(info.card) + 16];
  int n = snprintf(line, sizeof(line), "%s\t%s\t%s\n", info.path, info.card,
                   fourcc);
  buffer_append((byte_buffer *)ctx, line, (size_t)n);
  return false;
}

char *camera_linux_list_devices(void) {
  byte_buffer out = {0};
  for_each_video_node(append_device_line, &out);
  if (!buffer_append(&out, "", 1)) {
    free(out.data);
    return NULL;
  }
  return (char *)out.data;
}

// ---------------------------------------------------------------------------
// Capture session

typedef struct {
  void *start;
  size_t length;
} mapped_buffer;

struct camera_linux_session {
  pthread_mutex_t lock;  // guards `frame*`, `thread_failed` and `error`
  pthread_t thread;
  bool thread_started;
  atomic_bool stop;
  bool thread_failed;
  error_slot error;

  // Written before the thread starts and after it has been joined only.
  int fd;
  device_info info;
  uint32_t width, height, bytes_per_line;
  int jpeg_quality;
  mapped_buffer buffers[BUFFER_COUNT];
  unsigned buffer_count;
  bool streaming;

  // Newest frame, owned here until a reader takes it.
  uint8_t *frame;
  size_t frame_len;
  size_t frame_cap;
};

static void session_error(camera_linux_session *s, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  pthread_mutex_lock(&s->lock);
  slot_vset(&s->error, fmt, ap);
  pthread_mutex_unlock(&s->lock);
  va_end(ap);
}

static void session_errno(camera_linux_session *s, const char *what) {
  int saved = errno;
  session_error(s, "%s: %s", what, strerror(saved));
}

static void store_frame(camera_linux_session *s, const uint8_t *data,
                        size_t len) {
  pthread_mutex_lock(&s->lock);
  if (!s->frame || s->frame_cap < len) {
    uint8_t *grown = realloc(s->frame, len);
    if (!grown) {
      pthread_mutex_unlock(&s->lock);
      return;
    }
    s->frame = grown;
    s->frame_cap = len;
  }
  memcpy(s->frame, data, len);
  s->frame_len = len;
  pthread_mutex_unlock(&s->lock);
}

static void mark_thread_failed(camera_linux_session *s) {
  pthread_mutex_lock(&s->lock);
  s->thread_failed = true;
  pthread_mutex_unlock(&s->lock);
}

static void *capture_thread(void *arg) {
  camera_linux_session *s = arg;
  while (!atomic_load(&s->stop)) {
    struct pollfd pfd = {.fd = s->fd, .events = POLLIN};
    int r = poll(&pfd, 1, POLL_TIMEOUT_MS);
    if (r < 0) {
      if (errno == EINTR) continue;
      session_errno(s, "poll");
      mark_thread_failed(s);
      break;
    }
    if (r == 0) continue;
    if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL)) {
      session_error(s, "%s: device error or disconnect", s->info.path);
      mark_thread_failed(s);
      break;
    }
    struct v4l2_buffer buf;
    memset(&buf, 0, sizeof(buf));
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    if (xioctl(s->fd, VIDIOC_DQBUF, &buf) < 0) {
      if (errno == EAGAIN) continue;
      session_errno(s, "VIDIOC_DQBUF");
      mark_thread_failed(s);
      break;
    }
    if (buf.index < s->buffer_count && !(buf.flags & V4L2_BUF_FLAG_ERROR) &&
        buf.bytesused > 0) {
      size_t used = buf.bytesused;
      if (used > s->buffers[buf.index].length) {
        used = s->buffers[buf.index].length;
      }
      store_frame(s, s->buffers[buf.index].start, used);
    }
    if (xioctl(s->fd, VIDIOC_QBUF, &buf) < 0) {
      session_errno(s, "VIDIOC_QBUF");
      mark_thread_failed(s);
      break;
    }
  }
  return NULL;
}

// Stops the thread and releases the device; the struct itself stays.
static void teardown_session(camera_linux_session *s) {
  if (s->thread_started) {
    atomic_store(&s->stop, true);
    pthread_join(s->thread, NULL);
    s->thread_started = false;
  }
  if (s->fd >= 0) {
    if (s->streaming) {
      enum v4l2_buf_type type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
      xioctl(s->fd, VIDIOC_STREAMOFF, &type);
      s->streaming = false;
    }
    for (unsigned i = 0; i < s->buffer_count; i++) {
      if (s->buffers[i].start && s->buffers[i].start != MAP_FAILED) {
        munmap(s->buffers[i].start, s->buffers[i].length);
      }
      s->buffers[i].start = NULL;
      s->buffers[i].length = 0;
    }
    s->buffer_count = 0;
    close(s->fd);
    s->fd = -1;
  }
  free(s->frame);
  s->frame = NULL;
  s->frame_len = 0;
  s->frame_cap = 0;
}

static int open_requested_device(camera_linux_session *s, const char *device,
                                 error_slot *err) {
  const char *why = "unknown";
  if (device && *device) {
    int fd = probe_device(device, &s->info, &why);
    if (fd < 0) slot_set(err, "%s: %s", device, why);
    return fd;
  }
  const char *env = getenv("CAMERA_LINUX_DEVICE");
  if (env && *env) {
    int fd = probe_device(env, &s->info, &why);
    if (fd < 0) slot_set(err, "%s (CAMERA_LINUX_DEVICE): %s", env, why);
    return fd;
  }
  first_device_ctx ctx = {.fd = -1};
  for_each_video_node(take_first_device, &ctx);
  if (ctx.fd < 0) {
    slot_set(err, "no usable video capture device found under /dev");
    return -1;
  }
  s->info = ctx.info;
  return ctx.fd;
}

static int setup_streaming(camera_linux_session *s, int32_t width,
                           int32_t height, error_slot *err) {
  struct v4l2_format fmt;
  memset(&fmt, 0, sizeof(fmt));
  fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
  fmt.fmt.pix.width = (uint32_t)width;
  fmt.fmt.pix.height = (uint32_t)height;
  fmt.fmt.pix.pixelformat = s->info.fourcc;
  fmt.fmt.pix.field = V4L2_FIELD_ANY;
  if (xioctl(s->fd, VIDIOC_S_FMT, &fmt) < 0) {
    slot_set_errno(err, "VIDIOC_S_FMT");
    return -1;
  }
  if (format_rank(fmt.fmt.pix.pixelformat) < 0) {
    char fourcc[5];
    fourcc_string(fmt.fmt.pix.pixelformat, fourcc);
    slot_set(err, "driver switched to unsupported pixel format %s", fourcc);
    return -1;
  }
  s->info.fourcc = fmt.fmt.pix.pixelformat;
  s->width = fmt.fmt.pix.width;
  s->height = fmt.fmt.pix.height;
  s->bytes_per_line = fmt.fmt.pix.bytesperline;
  if (s->width == 0 || s->height == 0 || s->width > MAX_DIMENSION ||
      s->height > MAX_DIMENSION) {
    slot_set(err, "driver reported frame size %ux%u", s->width, s->height);
    return -1;
  }

  struct v4l2_requestbuffers req;
  memset(&req, 0, sizeof(req));
  req.count = BUFFER_COUNT;
  req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
  req.memory = V4L2_MEMORY_MMAP;
  if (xioctl(s->fd, VIDIOC_REQBUFS, &req) < 0) {
    slot_set_errno(err, "VIDIOC_REQBUFS");
    return -1;
  }
  if (req.count < 2) {
    slot_set(err, "driver granted only %u buffers", req.count);
    return -1;
  }
  if (req.count > BUFFER_COUNT) req.count = BUFFER_COUNT;
  for (unsigned i = 0; i < req.count; i++) {
    struct v4l2_buffer buf;
    memset(&buf, 0, sizeof(buf));
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    buf.index = i;
    if (xioctl(s->fd, VIDIOC_QUERYBUF, &buf) < 0) {
      slot_set_errno(err, "VIDIOC_QUERYBUF");
      return -1;
    }
    void *start = mmap(NULL, buf.length, PROT_READ | PROT_WRITE, MAP_SHARED,
                       s->fd, buf.m.offset);
    if (start == MAP_FAILED) {
      slot_set_errno(err, "mmap");
      return -1;
    }
    s->buffers[i].start = start;
    s->buffers[i].length = buf.length;
    s->buffer_count = i + 1;
  }
  for (unsigned i = 0; i < s->buffer_count; i++) {
    struct v4l2_buffer buf;
    memset(&buf, 0, sizeof(buf));
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    buf.index = i;
    if (xioctl(s->fd, VIDIOC_QBUF, &buf) < 0) {
      slot_set_errno(err, "VIDIOC_QBUF");
      return -1;
    }
  }
  enum v4l2_buf_type type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
  if (xioctl(s->fd, VIDIOC_STREAMON, &type) < 0) {
    slot_set_errno(err, "VIDIOC_STREAMON");
    return -1;
  }
  s->streaming = true;
  return 0;
}

static void destroy_session(camera_linux_session *s) {
  teardown_session(s);
  pthread_mutex_destroy(&s->lock);
  free(s);
}

camera_linux_session *camera_linux_open(const char *device, int32_t width,
                                        int32_t height, int32_t jpeg_quality,
                                        char **error) {
  if (error) *error = NULL;
  error_slot err = {.set = false};
  camera_linux_session *s = calloc(1, sizeof(*s));
  if (!s) {
    if (error) *error = strdup("out of memory");
    return NULL;
  }
  pthread_mutex_init(&s->lock, NULL);
  s->fd = -1;
  atomic_init(&s->stop, false);
  if (width <= 0 || height <= 0) {
    width = DEFAULT_WIDTH;
    height = DEFAULT_HEIGHT;
  }
  s->jpeg_quality = (jpeg_quality > 0 && jpeg_quality <= 100)
                        ? jpeg_quality
                        : DEFAULT_JPEG_QUALITY;
  s->fd = open_requested_device(s, device, &err);
  if (s->fd >= 0 && setup_streaming(s, width, height, &err) == 0) {
    int rc = pthread_create(&s->thread, NULL, capture_thread, s);
    if (rc == 0) {
      s->thread_started = true;
      return s;
    }
    slot_set(&err, "pthread_create: %s", strerror(rc));
  }
  destroy_session(s);
  if (error) *error = slot_take(&err);
  return NULL;
}

void camera_linux_close(camera_linux_session *s) {
  if (s) destroy_session(s);
}

int camera_linux_status(camera_linux_session *s) {
  pthread_mutex_lock(&s->lock);
  int status = s->thread_failed ? CAMERA_LINUX_FAILED : CAMERA_LINUX_RUNNING;
  pthread_mutex_unlock(&s->lock);
  return status;
}

char *camera_linux_take_error(camera_linux_session *s) {
  pthread_mutex_lock(&s->lock);
  char *copy = slot_take(&s->error);
  pthread_mutex_unlock(&s->lock);
  return copy;
}

void camera_linux_frame_size(camera_linux_session *s, int32_t *width,
                             int32_t *height) {
  if (width) *width = (int32_t)s->width;
  if (height) *height = (int32_t)s->height;
}

char *camera_linux_device_path(camera_linux_session *s) {
  return strdup(s->info.path);
}

uint8_t *camera_linux_read_jpeg(camera_linux_session *s, int32_t *length) {
  if (length) *length = 0;
  if (!length) return NULL;
  // Take the frame out of the session so the capture thread can allocate a
  // fresh one while this one is being converted.
  pthread_mutex_lock(&s->lock);
  uint8_t *raw = s->frame;
  size_t raw_len = s->frame_len;
  s->frame = NULL;
  s->frame_len = 0;
  s->frame_cap = 0;
  pthread_mutex_unlock(&s->lock);
  if (!raw || raw_len == 0 || raw_len > INT32_MAX) {
    free(raw);
    return NULL;
  }

  uint32_t fourcc = s->info.fourcc;
  int32_t w = (int32_t)s->width, h = (int32_t)s->height;
  int32_t stride = (int32_t)s->bytes_per_line;
  uint8_t *jpeg = NULL;
  if (is_jpeg_format(fourcc)) {
    jpeg = camera_linux_fix_mjpeg(raw, (int32_t)raw_len, length);
    if (!jpeg) session_error(s, "camera delivered a frame that is not a JPEG");
  } else if (fourcc == V4L2_PIX_FMT_GREY && stride == w &&
             raw_len >= (size_t)w * (size_t)h) {
    jpeg = camera_linux_encode_jpeg(raw, w, h, 1, s->jpeg_quality, length);
    if (!jpeg) session_error(s, "JPEG encoding failed");
  } else {
    uint8_t *rgb = malloc((size_t)w * (size_t)h * 3);
    if (!rgb) {
      session_error(s, "out of memory converting frame");
    } else if (camera_linux_frame_to_rgb(raw, (int32_t)raw_len, fourcc, w, h,
                                         stride, rgb) < 0) {
      char fcc[5];
      fourcc_string(fourcc, fcc);
      session_error(s, "cannot convert %s frame of %zu bytes (%dx%d, stride %d)",
                    fcc, raw_len, w, h, stride);
    } else {
      jpeg = camera_linux_encode_jpeg(rgb, w, h, 3, s->jpeg_quality, length);
      if (!jpeg) session_error(s, "JPEG encoding failed");
    }
    free(rgb);
  }
  free(raw);
  return jpeg;
}
