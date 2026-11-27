// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/camera_linux_v4l2/camera_linux_v4l2_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>

#include <atomic>
#include <cstdint>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <utility>
#include <vector>

#include "camera_linux_v4l2_plugin_private.h"
#include "camera_session.h"
#include "camera_texture.h"
#include "messages.g.h"
#include "pixel_format.h"
#include "v4l2_system.h"

namespace {

using camera_linux_v4l2::CameraPixelBuffer;
using camera_linux_v4l2::CameraPixelBufferEnsure;
using camera_linux_v4l2::CameraPixelBufferFree;
using camera_linux_v4l2::CameraPixelBufferSwap;
using camera_linux_v4l2::CameraSession;
using camera_linux_v4l2::ConvertRgbaToBgra;
using camera_linux_v4l2::EnumerateVideoDevices;
using camera_linux_v4l2::GetRgbaBufferSize;
using camera_linux_v4l2::IsVideoDevicePath;
using camera_linux_v4l2::V4l2System;

// The generated *_finish functions release the GTask behind each event, so
// they must be called even though the (empty) responses are not used.
void OnCameraClosingComplete(GObject* object, GAsyncResult* result,
                             gpointer user_data) {
  g_autoptr(FclCameraEventApiCameraClosingResponse) response =
      fcl_camera_event_api_camera_closing_finish(FCL_CAMERA_EVENT_API(object),
                                                 result, nullptr);
}

void OnErrorEventComplete(GObject* object, GAsyncResult* result,
                          gpointer user_data) {
  g_autoptr(FclCameraEventApiErrorResponse) response =
      fcl_camera_event_api_error_finish(FCL_CAMERA_EVENT_API(object), result,
                                        nullptr);
}

struct CameraEntry {
  std::string device_path;
  uint32_t requested_width = 0;
  uint32_t requested_height = 0;

  FlTextureRegistrar* texture_registrar = nullptr;
  FlCameraTexture* texture = nullptr;
  FclCameraEventApi* event_api = nullptr;
  std::unique_ptr<CameraSession> session;

  std::atomic<bool> disposed{false};
  std::atomic<bool> streaming_images{false};
  std::atomic<bool> frame_dispatch_pending{false};

  // Touched exclusively on the main thread.
  bool frame_in_flight = false;
  CameraPixelBuffer dispatch_stream_bgra;

  // Touched exclusively by the capture thread.
  CameraPixelBuffer capture_work_bgra;

  // The most recent image-stream frame, handed from the capture thread to the
  // main thread under `stream_mutex`.
  std::mutex stream_mutex;
  CameraPixelBuffer pending_stream_bgra;
  uint32_t pending_stream_width = 0;
  uint32_t pending_stream_height = 0;
  bool has_pending_stream_frame = false;

  ~CameraEntry() { Dispose(false); }

  // Stops capture and releases the texture. Must be called on the main thread;
  // calling it again is a no-op.
  void Dispose(bool send_closing) {
    streaming_images.store(false);
    disposed.store(true);

    if (session != nullptr) {
      if (send_closing && event_api != nullptr) {
        fcl_camera_event_api_camera_closing(event_api, nullptr,
                                            OnCameraClosingComplete, nullptr);
      }
      // Joins the capture thread, so nothing below can race with it.
      session.reset();
    }

    has_pending_stream_frame = false;
    CameraPixelBufferFree(&pending_stream_bgra);
    CameraPixelBufferFree(&capture_work_bgra);
    CameraPixelBufferFree(&dispatch_stream_bgra);
    if (texture != nullptr) {
      fl_texture_registrar_unregister_texture(texture_registrar,
                                              FL_TEXTURE(texture));
    }
    g_clear_object(&event_api);
    g_clear_object(&texture);
    g_clear_object(&texture_registrar);
  }
};

struct CameraPluginState {
  FlBinaryMessenger* messenger = nullptr;
  FlTextureRegistrar* texture_registrar = nullptr;
  std::unique_ptr<V4l2System> v4l2_system;
  std::map<int64_t, std::shared_ptr<CameraEntry>> cameras;
};

struct CameraErrorEvent {
  std::shared_ptr<CameraEntry> entry;
  std::string message;
};

void ResolutionPresetToSize(FclPlatformResolutionPreset preset, uint32_t* width,
                            uint32_t* height) {
  switch (preset) {
    case CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_LOW:
      *width = 320;
      *height = 240;
      return;
    case CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_MEDIUM:
      *width = 640;
      *height = 480;
      return;
    case CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_HIGH:
      *width = 1280;
      *height = 720;
      return;
    case CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_VERY_HIGH:
      *width = 1920;
      *height = 1080;
      return;
    case CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_ULTRA_HIGH:
      *width = 3840;
      *height = 2160;
      return;
    case CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_MAX:
      *width = 4096;
      *height = 2160;
      return;
  }
  *width = 640;
  *height = 480;
}

void DeleteSharedEntry(gpointer data) {
  delete static_cast<std::shared_ptr<CameraEntry>*>(data);
}

void DeleteErrorEvent(gpointer data) {
  delete static_cast<CameraErrorEvent*>(data);
}

gboolean OnFrameMainThread(gpointer user_data);

// Requests a call to OnFrameMainThread() unless one is already queued.
// Callable from any thread.
//
// This uses g_idle_add_full() rather than g_main_context_invoke_full() because
// the latter runs the callback on the calling thread whenever no thread
// currently owns the main context, such as during shutdown.
void ScheduleFrameDispatch(const std::shared_ptr<CameraEntry>& entry) {
  if (!entry->disposed.load() &&
      !entry->frame_dispatch_pending.exchange(true)) {
    g_idle_add_full(G_PRIORITY_DEFAULT, OnFrameMainThread,
                    new std::shared_ptr<CameraEntry>(entry), DeleteSharedEntry);
  }
}

void OnFrameEventComplete(GObject* object, GAsyncResult* result,
                          gpointer user_data) {
  std::unique_ptr<std::shared_ptr<CameraEntry>> entry_holder(
      static_cast<std::shared_ptr<CameraEntry>*>(user_data));
  g_autoptr(FclCameraEventApiOnFrameAvailableResponse) response =
      fcl_camera_event_api_on_frame_available_finish(
          FCL_CAMERA_EVENT_API(object), result, nullptr);
  const std::shared_ptr<CameraEntry>& entry = *entry_holder;
  entry->frame_in_flight = false;

  // Deliver the frame that arrived while this one was in flight, if any.
  bool has_pending_frame = false;
  {
    std::lock_guard<std::mutex> lock(entry->stream_mutex);
    has_pending_frame = entry->has_pending_stream_frame;
  }
  if (has_pending_frame) {
    ScheduleFrameDispatch(entry);
  }
}

// Redraws the preview texture and, while image streaming, sends the pending
// frame to Dart.
//
// At most one frame is in flight to Dart at a time. Frames captured in the
// meantime replace the pending one, so a slow consumer drops frames instead of
// queueing them without bound.
gboolean OnFrameMainThread(gpointer user_data) {
  const std::shared_ptr<CameraEntry>& entry =
      *static_cast<std::shared_ptr<CameraEntry>*>(user_data);
  entry->frame_dispatch_pending.store(false);
  if (entry->disposed.load()) {
    return G_SOURCE_REMOVE;
  }

  fl_texture_registrar_mark_texture_frame_available(entry->texture_registrar,
                                                    FL_TEXTURE(entry->texture));

  if (entry->frame_in_flight) {
    return G_SOURCE_REMOVE;
  }
  uint32_t width = 0;
  uint32_t height = 0;
  {
    std::lock_guard<std::mutex> lock(entry->stream_mutex);
    if (!entry->has_pending_stream_frame) {
      return G_SOURCE_REMOVE;
    }
    CameraPixelBufferSwap(&entry->dispatch_stream_bgra,
                          &entry->pending_stream_bgra);
    width = entry->pending_stream_width;
    height = entry->pending_stream_height;
    entry->has_pending_stream_frame = false;
  }

  entry->frame_in_flight = true;
  fcl_camera_event_api_on_frame_available(
      entry->event_api, width, height, static_cast<int64_t>(width) * 4,
      entry->dispatch_stream_bgra.data, static_cast<size_t>(width) * height * 4,
      nullptr, OnFrameEventComplete, new std::shared_ptr<CameraEntry>(entry));
  return G_SOURCE_REMOVE;
}

gboolean OnErrorMainThread(gpointer user_data) {
  auto* event = static_cast<CameraErrorEvent*>(user_data);
  if (!event->entry->disposed.load()) {
    fcl_camera_event_api_error(event->entry->event_api, event->message.c_str(),
                               nullptr, OnErrorEventComplete, nullptr);
  }
  return G_SOURCE_REMOVE;
}

// Queues `message` for delivery to Dart as a camera error. Callable from any
// thread.
void PostError(const std::shared_ptr<CameraEntry>& entry, std::string message) {
  g_idle_add_full(G_PRIORITY_DEFAULT, OnErrorMainThread,
                  new CameraErrorEvent{entry, std::move(message)},
                  DeleteErrorEvent);
}

// Publishes a frame to the preview texture and, while image streaming, to the
// pending image-stream slot. Runs on the capture thread.
void OnCaptureFrame(const std::shared_ptr<CameraEntry>& entry,
                    CameraPixelBuffer* rgba_buffer, uint32_t width,
                    uint32_t height) {
  if (entry->streaming_images.load()) {
    size_t frame_bytes = 0;
    if (GetRgbaBufferSize(width, height, &frame_bytes) &&
        CameraPixelBufferEnsure(&entry->capture_work_bgra, frame_bytes)) {
      ConvertRgbaToBgra(rgba_buffer->data, entry->capture_work_bgra.data,
                        frame_bytes / 4);
      std::lock_guard<std::mutex> lock(entry->stream_mutex);
      // Checked again under the lock so that a concurrent stopImageStream,
      // which frees the pending frame, is not undone here.
      if (entry->streaming_images.load()) {
        CameraPixelBufferSwap(&entry->pending_stream_bgra,
                              &entry->capture_work_bgra);
        entry->pending_stream_width = width;
        entry->pending_stream_height = height;
        entry->has_pending_stream_frame = true;
      }
    } else if (entry->streaming_images.exchange(false)) {
      PostError(entry, "Failed to allocate image-stream frame buffer");
    }
  }

  // The texture takes `rgba_buffer` by swapping, so this must come after the
  // BGRA conversion above.
  fl_camera_texture_update_frame(entry->texture, rgba_buffer, width, height);
  ScheduleFrameDispatch(entry);
}

std::shared_ptr<CameraEntry> FindCamera(CameraPluginState* state,
                                        int64_t camera_id) {
  auto it = state->cameras.find(camera_id);
  return it == state->cameras.end() ? nullptr : it->second;
}

FclCameraApiInitializeResponse* NewInitializeResponse(
    const CameraSession& session) {
  g_autoptr(FclPlatformSize) size =
      fcl_platform_size_new(session.width(), session.height());
  return fcl_camera_api_initialize_response_new(size);
}

}  // namespace

struct _FlCameraLinuxV4l2Plugin {
  GObject parent_instance;

  CameraPluginState* state;
};

G_DEFINE_TYPE(FlCameraLinuxV4l2Plugin, fl_camera_linux_v4l2_plugin,
              G_TYPE_OBJECT)

FclCameraApiGetAvailableCamerasResponse* handle_get_available_cameras(
    gpointer user_data) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(user_data);
  g_autoptr(FlValue) list = fl_value_new_list();
  for (const std::string& path :
       EnumerateVideoDevices(self->state->v4l2_system.get())) {
    fl_value_append_take(list, fl_value_new_string(path.c_str()));
  }
  return fcl_camera_api_get_available_cameras_response_new(list);
}

FclCameraApiCreateResponse* handle_create(
    const gchar* camera_name, FclPlatformResolutionPreset resolution_preset,
    gpointer user_data) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(user_data);
  // Camera names come from Dart, so only open paths that
  // getAvailableCameras could have returned.
  if (camera_name == nullptr || !IsVideoDevicePath(camera_name)) {
    return fcl_camera_api_create_response_new_error(
        "camera_error", "Camera name must be a /dev/videoN device path.",
        nullptr);
  }

  g_autoptr(FlCameraTexture) texture = fl_camera_texture_new();
  if (!fl_texture_registrar_register_texture(self->state->texture_registrar,
                                             FL_TEXTURE(texture))) {
    return fcl_camera_api_create_response_new_error(
        "camera_error", "Failed to register camera texture.", nullptr);
  }

  const int64_t camera_id = fl_texture_get_id(FL_TEXTURE(texture));
  auto entry = std::make_shared<CameraEntry>();
  entry->device_path = camera_name;
  ResolutionPresetToSize(resolution_preset, &entry->requested_width,
                         &entry->requested_height);
  entry->texture = FL_CAMERA_TEXTURE(g_steal_pointer(&texture));
  entry->texture_registrar =
      FL_TEXTURE_REGISTRAR(g_object_ref(self->state->texture_registrar));
  self->state->cameras[camera_id] = std::move(entry);
  return fcl_camera_api_create_response_new(camera_id);
}

FclCameraApiInitializeResponse* handle_initialize(int64_t camera_id,
                                                  gpointer user_data) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(user_data);
  std::shared_ptr<CameraEntry> entry = FindCamera(self->state, camera_id);
  if (entry == nullptr) {
    return fcl_camera_api_initialize_response_new_error(
        "camera_not_found", "Camera has not been created.", nullptr);
  }
  if (entry->session != nullptr) {
    return NewInitializeResponse(*entry->session);
  }

  g_autofree gchar* suffix = g_strdup_printf("%" G_GINT64_FORMAT, camera_id);
  entry->event_api = fcl_camera_event_api_new(self->state->messenger, suffix);

  std::unique_ptr<CameraSession> session(
      new CameraSession(self->state->v4l2_system.get(), entry->device_path,
                        entry->requested_width, entry->requested_height));

  // The entry owns the session, so the session's callbacks hold the entry
  // weakly to avoid a reference cycle.
  std::weak_ptr<CameraEntry> weak_entry(entry);
  std::string error_code;
  std::string error_message;
  const bool started = session->Start(
      [weak_entry](CameraPixelBuffer* rgba_buffer, uint32_t width,
                   uint32_t height) {
        if (std::shared_ptr<CameraEntry> locked = weak_entry.lock()) {
          OnCaptureFrame(locked, rgba_buffer, width, height);
        }
      },
      [weak_entry](const std::string& message) {
        if (std::shared_ptr<CameraEntry> locked = weak_entry.lock()) {
          PostError(locked, message);
        }
      },
      &error_code, &error_message);
  if (!started) {
    g_clear_object(&entry->event_api);
    return fcl_camera_api_initialize_response_new_error(
        error_code.c_str(), error_message.c_str(), nullptr);
  }

  entry->session = std::move(session);
  return NewInitializeResponse(*entry->session);
}

FclCameraApiStartImageStreamResponse* handle_start_image_stream(
    int64_t camera_id, gpointer user_data) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(user_data);
  std::shared_ptr<CameraEntry> entry = FindCamera(self->state, camera_id);
  if (entry == nullptr) {
    return fcl_camera_api_start_image_stream_response_new_error(
        "camera_not_found", "Camera has not been created.", nullptr);
  }
  if (entry->session == nullptr) {
    return fcl_camera_api_start_image_stream_response_new_error(
        "camera_not_initialized", "Camera is not initialized.", nullptr);
  }
  entry->streaming_images.store(true);
  return fcl_camera_api_start_image_stream_response_new();
}

FclCameraApiStopImageStreamResponse* handle_stop_image_stream(
    int64_t camera_id, gpointer user_data) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(user_data);
  std::shared_ptr<CameraEntry> entry = FindCamera(self->state, camera_id);
  if (entry == nullptr) {
    return fcl_camera_api_stop_image_stream_response_new_error(
        "camera_not_found", "Camera has not been created.", nullptr);
  }
  if (entry->session == nullptr) {
    return fcl_camera_api_stop_image_stream_response_new_error(
        "camera_not_initialized", "Camera is not initialized.", nullptr);
  }
  entry->streaming_images.store(false);
  {
    std::lock_guard<std::mutex> lock(entry->stream_mutex);
    entry->has_pending_stream_frame = false;
    CameraPixelBufferFree(&entry->pending_stream_bgra);
  }
  CameraPixelBufferFree(&entry->dispatch_stream_bgra);
  return fcl_camera_api_stop_image_stream_response_new();
}

FclCameraApiDisposeResponse* handle_dispose(int64_t camera_id,
                                            gpointer user_data) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(user_data);
  auto it = self->state->cameras.find(camera_id);
  if (it != self->state->cameras.end()) {
    it->second->Dispose(true);
    self->state->cameras.erase(it);
  }
  return fcl_camera_api_dispose_response_new();
}

static void fl_camera_linux_v4l2_plugin_dispose(GObject* object) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(object);
  if (self->state != nullptr) {
    if (self->state->messenger != nullptr) {
      fcl_camera_api_clear_method_handlers(self->state->messenger, nullptr);
    }
    for (auto& camera : self->state->cameras) {
      camera.second->Dispose(false);
    }
    g_clear_object(&self->state->messenger);
    g_clear_object(&self->state->texture_registrar);
    delete self->state;
    self->state = nullptr;
  }
  G_OBJECT_CLASS(fl_camera_linux_v4l2_plugin_parent_class)->dispose(object);
}

static void fl_camera_linux_v4l2_plugin_class_init(
    FlCameraLinuxV4l2PluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_camera_linux_v4l2_plugin_dispose;
}

static void fl_camera_linux_v4l2_plugin_init(FlCameraLinuxV4l2Plugin* self) {
  self->state = new CameraPluginState();
}

FlCameraLinuxV4l2Plugin* fl_camera_linux_v4l2_plugin_new_with_dependencies(
    FlBinaryMessenger* messenger, FlTextureRegistrar* texture_registrar,
    std::unique_ptr<V4l2System> v4l2_system) {
  FlCameraLinuxV4l2Plugin* self = FL_CAMERA_LINUX_V4L2_PLUGIN(
      g_object_new(fl_camera_linux_v4l2_plugin_get_type(), nullptr));

  self->state->messenger = FL_BINARY_MESSENGER(g_object_ref(messenger));
  self->state->texture_registrar =
      FL_TEXTURE_REGISTRAR(g_object_ref(texture_registrar));
  self->state->v4l2_system = std::move(v4l2_system);

  static const FclCameraApiVTable api_vtable = {
      handle_get_available_cameras,
      handle_create,
      handle_initialize,
      handle_start_image_stream,
      handle_stop_image_stream,
      handle_dispose,
  };
  fcl_camera_api_set_method_handlers(messenger, nullptr, &api_vtable,
                                     g_object_ref(self), g_object_unref);
  return self;
}

FlCameraLinuxV4l2Plugin* fl_camera_linux_v4l2_plugin_new(
    FlPluginRegistrar* registrar) {
  return fl_camera_linux_v4l2_plugin_new_with_dependencies(
      fl_plugin_registrar_get_messenger(registrar),
      fl_plugin_registrar_get_texture_registrar(registrar),
      std::unique_ptr<V4l2System>(new camera_linux_v4l2::PosixV4l2System()));
}

void camera_linux_v4l2_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FlCameraLinuxV4l2Plugin* plugin = fl_camera_linux_v4l2_plugin_new(registrar);
  g_object_unref(plugin);
}
