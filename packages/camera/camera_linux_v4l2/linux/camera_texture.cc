// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera_texture.h"

struct _FlCameraTexture {
  FlPixelBufferTexture parent_instance;

  GMutex mutex;
  camera_linux_v4l2::CameraPixelBuffer staging;
  uint32_t staging_width;
  uint32_t staging_height;
  gboolean staging_dirty;

  camera_linux_v4l2::CameraPixelBuffer front;
  uint32_t front_width;
  uint32_t front_height;
  gboolean has_front;
};

G_DEFINE_TYPE(FlCameraTexture, fl_camera_texture,
              fl_pixel_buffer_texture_get_type())

static gboolean fl_camera_texture_copy_pixels(FlPixelBufferTexture* texture,
                                              const uint8_t** buffer,
                                              uint32_t* width, uint32_t* height,
                                              GError** error) {
  FlCameraTexture* self = FL_CAMERA_TEXTURE(texture);
  g_mutex_lock(&self->mutex);

  if (self->staging_dirty) {
    camera_linux_v4l2::CameraPixelBufferSwap(&self->front, &self->staging);
    self->front_width = self->staging_width;
    self->front_height = self->staging_height;
    self->staging_dirty = FALSE;
    self->has_front = TRUE;
  }

  if (!self->has_front) {
    // Return a 1x1 black pixel before the first camera frame arrives so the
    // engine does not log a texture error on initial paint.
    static const uint8_t kEmptyPixel[4] = {0, 0, 0, 255};
    *buffer = kEmptyPixel;
    *width = 1;
    *height = 1;
    g_mutex_unlock(&self->mutex);
    return TRUE;
  }

  *buffer = self->front.data;
  *width = self->front_width;
  *height = self->front_height;
  g_mutex_unlock(&self->mutex);
  return TRUE;
}

static void fl_camera_texture_finalize(GObject* object) {
  FlCameraTexture* self = FL_CAMERA_TEXTURE(object);
  g_mutex_lock(&self->mutex);
  camera_linux_v4l2::CameraPixelBufferFree(&self->staging);
  camera_linux_v4l2::CameraPixelBufferFree(&self->front);
  g_mutex_unlock(&self->mutex);
  g_mutex_clear(&self->mutex);
  G_OBJECT_CLASS(fl_camera_texture_parent_class)->finalize(object);
}

static void fl_camera_texture_class_init(FlCameraTextureClass* klass) {
  G_OBJECT_CLASS(klass)->finalize = fl_camera_texture_finalize;
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels =
      fl_camera_texture_copy_pixels;
}

static void fl_camera_texture_init(FlCameraTexture* self) {
  g_mutex_init(&self->mutex);
}

FlCameraTexture* fl_camera_texture_new() {
  return FL_CAMERA_TEXTURE(g_object_new(fl_camera_texture_get_type(), nullptr));
}

gboolean fl_camera_texture_update_frame(
    FlCameraTexture* self, camera_linux_v4l2::CameraPixelBuffer* rgba_buffer,
    uint32_t width, uint32_t height) {
  g_return_val_if_fail(FL_IS_CAMERA_TEXTURE(self), FALSE);
  if (rgba_buffer == nullptr || rgba_buffer->data == nullptr || width == 0 ||
      height == 0) {
    return FALSE;
  }
  size_t required = 0;
  if (!camera_linux_v4l2::GetRgbaBufferSize(width, height, &required)) {
    return FALSE;
  }
  if (rgba_buffer->capacity < required) {
    return FALSE;
  }

  g_mutex_lock(&self->mutex);
  camera_linux_v4l2::CameraPixelBufferSwap(&self->staging, rgba_buffer);
  self->staging_width = width;
  self->staging_height = height;
  self->staging_dirty = TRUE;
  g_mutex_unlock(&self->mutex);
  return TRUE;
}
