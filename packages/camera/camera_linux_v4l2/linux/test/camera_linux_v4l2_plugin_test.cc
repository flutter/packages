// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/camera_linux_v4l2/camera_linux_v4l2_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <linux/videodev2.h>

#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "camera_linux_v4l2_plugin_private.h"
#include "fake_v4l2_system.h"
#include "messages.g.h"

// Re-declare opaque Pigeon response structs so tests can inspect FlValue
// payloads directly, matching url_launcher_linux_test.cc.
struct _FclCameraApiGetAvailableCamerasResponse {
  GObject parent_instance;
  FlValue* value;
};

struct _FclCameraApiCreateResponse {
  GObject parent_instance;
  FlValue* value;
};

struct _FclCameraApiInitializeResponse {
  GObject parent_instance;
  FlValue* value;
};

struct _FclCameraApiStartImageStreamResponse {
  GObject parent_instance;
  FlValue* value;
};

struct _FclCameraApiStopImageStreamResponse {
  GObject parent_instance;
  FlValue* value;
};

struct _FclCameraApiDisposeResponse {
  GObject parent_instance;
  FlValue* value;
};

// Minimal fake FlBinaryMessenger capturing outgoing platform->Dart messages.
struct RecordedMessengerCall {
  std::string channel;
  GBytes* payload = nullptr;
};

G_DECLARE_FINAL_TYPE(FakeBinaryMessenger, fake_binary_messenger, FAKE,
                     BINARY_MESSENGER, GObject)

struct _FakeBinaryMessenger {
  GObject parent_instance;
  GThread* main_thread;
  GHashTable* handlers;
  std::vector<RecordedMessengerCall>* sent_calls;
  std::vector<GTask*>* pending_send_tasks;
  bool defer_responses;
  int finished_send_count;
};

static void fake_binary_messenger_iface_init(FlBinaryMessengerInterface* iface);

G_DEFINE_TYPE_WITH_CODE(FakeBinaryMessenger, fake_binary_messenger,
                        G_TYPE_OBJECT,
                        G_IMPLEMENT_INTERFACE(fl_binary_messenger_get_type(),
                                              fake_binary_messenger_iface_init))

typedef struct {
  FlBinaryMessengerMessageHandler handler;
  gpointer user_data;
  GDestroyNotify destroy_notify;
} MessengerHandlerEntry;

static void messenger_handler_entry_free(gpointer data) {
  auto* entry = static_cast<MessengerHandlerEntry*>(data);
  if (entry->destroy_notify != nullptr) {
    entry->destroy_notify(entry->user_data);
  }
  g_free(entry);
}

static void fake_set_message_handler_on_channel(
    FlBinaryMessenger* messenger, const gchar* channel,
    FlBinaryMessengerMessageHandler handler, gpointer user_data,
    GDestroyNotify destroy_notify) {
  FakeBinaryMessenger* self = FAKE_BINARY_MESSENGER(messenger);
  if (self->handlers == nullptr) {
    if (destroy_notify != nullptr) {
      destroy_notify(user_data);
    }
    return;
  }
  if (handler == nullptr) {
    g_hash_table_remove(self->handlers, channel);
    return;
  }
  auto* entry = g_new0(MessengerHandlerEntry, 1);
  entry->handler = handler;
  entry->user_data = user_data;
  entry->destroy_notify = destroy_notify;
  g_hash_table_replace(self->handlers, g_strdup(channel), entry);
}

static gboolean fake_send_response(FlBinaryMessenger* messenger,
                                   FlBinaryMessengerResponseHandle* handle,
                                   GBytes* response, GError** error) {
  return TRUE;
}

static void fake_complete_send_task(GTask* task) {
  // StandardMessageCodec empty list reply: [type=list(12), len=0] -> [].
  static const uint8_t kEmptyReply[2] = {12, 0};
  g_task_return_pointer(task, g_bytes_new_static(kEmptyReply, 2),
                        reinterpret_cast<GDestroyNotify>(g_bytes_unref));
  g_object_unref(task);
}

static void fake_complete_next_send(FakeBinaryMessenger* messenger) {
  g_assert_false(messenger->pending_send_tasks->empty());
  GTask* task = messenger->pending_send_tasks->front();
  messenger->pending_send_tasks->erase(messenger->pending_send_tasks->begin());
  fake_complete_send_task(task);
}

static void fake_send_on_channel(FlBinaryMessenger* messenger,
                                 const gchar* channel, GBytes* message,
                                 GCancellable* cancellable,
                                 GAsyncReadyCallback callback,
                                 gpointer user_data) {
  FakeBinaryMessenger* self = FAKE_BINARY_MESSENGER(messenger);
  // The engine only accepts platform messages from the main thread.
  EXPECT_EQ(g_thread_self(), self->main_thread);
  self->sent_calls->push_back(
      RecordedMessengerCall{channel, g_bytes_ref(message)});
  if (callback != nullptr) {
    GTask* task = g_task_new(messenger, cancellable, callback, user_data);
    if (self->defer_responses) {
      self->pending_send_tasks->push_back(task);
    } else {
      fake_complete_send_task(task);
    }
  }
}

static GBytes* fake_send_on_channel_finish(FlBinaryMessenger* messenger,
                                           GAsyncResult* result,
                                           GError** error) {
  FAKE_BINARY_MESSENGER(messenger)->finished_send_count++;
  return static_cast<GBytes*>(g_task_propagate_pointer(G_TASK(result), error));
}

static void fake_resize_channel(FlBinaryMessenger*, const gchar*, int64_t) {}

static void fake_set_warns_on_channel_overflow(FlBinaryMessenger*, const gchar*,
                                               bool) {}

static void fake_binary_messenger_iface_init(
    FlBinaryMessengerInterface* iface) {
  iface->set_message_handler_on_channel = fake_set_message_handler_on_channel;
  iface->send_response = fake_send_response;
  iface->send_on_channel = fake_send_on_channel;
  iface->send_on_channel_finish = fake_send_on_channel_finish;
  iface->resize_channel = fake_resize_channel;
  iface->set_warns_on_channel_overflow = fake_set_warns_on_channel_overflow;
}

static void fake_binary_messenger_dispose(GObject* object) {
  FakeBinaryMessenger* self = FAKE_BINARY_MESSENGER(object);
  g_clear_pointer(&self->handlers, g_hash_table_destroy);
  if (self->sent_calls != nullptr) {
    for (RecordedMessengerCall& call : *self->sent_calls) {
      g_clear_pointer(&call.payload, g_bytes_unref);
    }
    delete self->sent_calls;
    self->sent_calls = nullptr;
  }
  if (self->pending_send_tasks != nullptr) {
    for (GTask* task : *self->pending_send_tasks) {
      g_object_unref(task);
    }
    delete self->pending_send_tasks;
    self->pending_send_tasks = nullptr;
  }
  G_OBJECT_CLASS(fake_binary_messenger_parent_class)->dispose(object);
}

static void fake_binary_messenger_class_init(FakeBinaryMessengerClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fake_binary_messenger_dispose;
}

static void fake_binary_messenger_init(FakeBinaryMessenger* self) {
  self->main_thread = g_thread_self();
  self->handlers = g_hash_table_new_full(g_str_hash, g_str_equal, g_free,
                                         messenger_handler_entry_free);
  self->sent_calls = new std::vector<RecordedMessengerCall>();
  self->pending_send_tasks = new std::vector<GTask*>();
}

static FakeBinaryMessenger* fake_binary_messenger_new() {
  return FAKE_BINARY_MESSENGER(
      g_object_new(fake_binary_messenger_get_type(), nullptr));
}

// Minimal fake FlTextureRegistrar assigning incrementing texture IDs.
G_DECLARE_FINAL_TYPE(FakeTextureRegistrar, fake_texture_registrar, FAKE,
                     TEXTURE_REGISTRAR, GObject)

struct _FakeTextureRegistrar {
  GObject parent_instance;
  GThread* main_thread;
  int64_t next_id;
  bool fail_register;
  int mark_count;
  int unregister_count;
  std::map<int64_t, FlTexture*>* textures;
};

static void fake_texture_registrar_iface_init(
    FlTextureRegistrarInterface* iface);

G_DEFINE_TYPE_WITH_CODE(
    FakeTextureRegistrar, fake_texture_registrar, G_TYPE_OBJECT,
    G_IMPLEMENT_INTERFACE(fl_texture_registrar_get_type(),
                          fake_texture_registrar_iface_init))

static gboolean fake_register_texture(FlTextureRegistrar* registrar,
                                      FlTexture* texture) {
  FakeTextureRegistrar* self = FAKE_TEXTURE_REGISTRAR(registrar);
  if (self->fail_register) {
    return FALSE;
  }
  const int64_t id = self->next_id++;
  FlTextureInterface* iface = FL_TEXTURE_GET_IFACE(texture);
  if (iface->set_id != nullptr) {
    iface->set_id(texture, id);
  }
  (*self->textures)[id] = FL_TEXTURE(g_object_ref(texture));
  return TRUE;
}

static FlTexture* fake_lookup_texture(FlTextureRegistrar* registrar,
                                      int64_t id) {
  FakeTextureRegistrar* self = FAKE_TEXTURE_REGISTRAR(registrar);
  auto it = self->textures->find(id);
  return it == self->textures->end() ? nullptr : it->second;
}

static gboolean fake_mark_texture_frame_available(FlTextureRegistrar* registrar,
                                                  FlTexture* texture) {
  FakeTextureRegistrar* self = FAKE_TEXTURE_REGISTRAR(registrar);
  EXPECT_EQ(g_thread_self(), self->main_thread);
  self->mark_count++;
  return TRUE;
}

static gboolean fake_unregister_texture(FlTextureRegistrar* registrar,
                                        FlTexture* texture) {
  FakeTextureRegistrar* self = FAKE_TEXTURE_REGISTRAR(registrar);
  self->unregister_count++;
  const int64_t id = fl_texture_get_id(texture);
  auto it = self->textures->find(id);
  if (it != self->textures->end()) {
    g_object_unref(it->second);
    self->textures->erase(it);
  }
  return TRUE;
}

static void fake_texture_registrar_iface_init(
    FlTextureRegistrarInterface* iface) {
  iface->register_texture = fake_register_texture;
  iface->lookup_texture = fake_lookup_texture;
  iface->mark_texture_frame_available = fake_mark_texture_frame_available;
  iface->unregister_texture = fake_unregister_texture;
}

static void fake_texture_registrar_dispose(GObject* object) {
  FakeTextureRegistrar* self = FAKE_TEXTURE_REGISTRAR(object);
  if (self->textures != nullptr) {
    for (auto& kv : *self->textures) {
      g_object_unref(kv.second);
    }
    delete self->textures;
    self->textures = nullptr;
  }
  G_OBJECT_CLASS(fake_texture_registrar_parent_class)->dispose(object);
}

static void fake_texture_registrar_class_init(
    FakeTextureRegistrarClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fake_texture_registrar_dispose;
}

static void fake_texture_registrar_init(FakeTextureRegistrar* self) {
  self->main_thread = g_thread_self();
  self->next_id = 100;
  self->textures = new std::map<int64_t, FlTexture*>();
}

static FakeTextureRegistrar* fake_texture_registrar_new() {
  return FAKE_TEXTURE_REGISTRAR(
      g_object_new(fake_texture_registrar_get_type(), nullptr));
}

namespace camera_linux_v4l2 {
namespace test {
namespace {

// Runs the default main context, which is where the plugin delivers frames
// and errors, until `condition` holds or a generous timeout expires.
void PumpMainLoopUntil(const std::function<bool()>& condition) {
  const gint64 deadline = g_get_monotonic_time() + 5 * G_TIME_SPAN_SECOND;
  while (!condition() && g_get_monotonic_time() < deadline) {
    g_main_context_iteration(nullptr, FALSE);
    g_usleep(1000);
  }
}

void PumpMessengerUntilIdle(FakeBinaryMessenger* messenger) {
  PumpMainLoopUntil([&] {
    return messenger->pending_send_tasks->empty() &&
           !g_main_context_pending(nullptr);
  });
}

TEST(CameraLinuxV4l2PluginTest, GetAvailableCamerasListsSupportedDevices) {
  g_autoptr(FakeBinaryMessenger) messenger = fake_binary_messenger_new();
  g_autoptr(FakeTextureRegistrar) registrar = fake_texture_registrar_new();
  std::unique_ptr<FakeV4l2System> v4l2(new FakeV4l2System());
  v4l2->AddDevice("/dev/video0");
  FakeV4l2Device* unsupported = v4l2->AddDevice("/dev/video1");
  unsupported->formats = {V4L2_PIX_FMT_MJPEG};

  g_autoptr(FlCameraLinuxV4l2Plugin) plugin =
      fl_camera_linux_v4l2_plugin_new_with_dependencies(
          FL_BINARY_MESSENGER(messenger), FL_TEXTURE_REGISTRAR(registrar),
          std::move(v4l2));

  g_autoptr(FclCameraApiGetAvailableCamerasResponse) response =
      handle_get_available_cameras(plugin);
  ASSERT_NE(response, nullptr);
  ASSERT_EQ(fl_value_get_length(response->value), 1u);
  FlValue* list = fl_value_get_list_value(response->value, 0);
  ASSERT_EQ(fl_value_get_type(list), FL_VALUE_TYPE_LIST);
  ASSERT_EQ(fl_value_get_length(list), 1u);
  EXPECT_STREQ(fl_value_get_string(fl_value_get_list_value(list, 0)),
               "/dev/video0");
  g_object_run_dispose(G_OBJECT(messenger));
}

TEST(CameraLinuxV4l2PluginTest, CreateInitializeStreamAndDisposeLifecycle) {
  g_autoptr(FakeBinaryMessenger) messenger = fake_binary_messenger_new();
  g_autoptr(FakeTextureRegistrar) registrar = fake_texture_registrar_new();
  std::unique_ptr<FakeV4l2System> v4l2(new FakeV4l2System());
  FakeV4l2Device* dev = v4l2->AddDevice("/dev/video0");
  dev->negotiated_width = 4;
  dev->negotiated_height = 2;

  g_autoptr(FlCameraLinuxV4l2Plugin) plugin =
      fl_camera_linux_v4l2_plugin_new_with_dependencies(
          FL_BINARY_MESSENGER(messenger), FL_TEXTURE_REGISTRAR(registrar),
          std::move(v4l2));

  g_autoptr(FclCameraApiCreateResponse) create_resp = handle_create(
      "/dev/video0", CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_HIGH, plugin);
  ASSERT_EQ(fl_value_get_length(create_resp->value), 1u);
  const int64_t camera_id =
      fl_value_get_int(fl_value_get_list_value(create_resp->value, 0));
  EXPECT_EQ(camera_id, 100);
  EXPECT_EQ(registrar->textures->size(), 1u);

  g_autoptr(FclCameraApiInitializeResponse) init_resp =
      handle_initialize(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(init_resp->value), 1u);
  FlValue* size_val = fl_value_get_list_value(init_resp->value, 0);
  ASSERT_EQ(fl_value_get_type(size_val), FL_VALUE_TYPE_CUSTOM);
  FclPlatformSize* size =
      FCL_PLATFORM_SIZE(fl_value_get_custom_value_object(size_val));
  EXPECT_DOUBLE_EQ(fcl_platform_size_get_width(size), 4.0);
  EXPECT_DOUBLE_EQ(fcl_platform_size_get_height(size), 2.0);

  // Initializing again returns the negotiated size without reopening.
  g_autoptr(FclCameraApiInitializeResponse) reinit_resp =
      handle_initialize(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(reinit_resp->value), 1u);
  EXPECT_EQ(dev->open_count, 1);

  g_autoptr(FclCameraApiStartImageStreamResponse) start_resp =
      handle_start_image_stream(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(start_resp->value), 1u);

  // Push a 4x2 YUYV frame and pump the default main context to verify both
  // texture marking and Pigeon onFrameAvailable delivery.
  const std::vector<uint8_t> yuyv(4 * 2 * 2, 128);
  dev->PushFrame(yuyv);
  PumpMainLoopUntil([&] {
    return registrar->mark_count > 0 && !messenger->sent_calls->empty();
  });
  EXPECT_GE(registrar->mark_count, 1);
  ASSERT_FALSE(messenger->sent_calls->empty());
  EXPECT_EQ(messenger->sent_calls->front().channel,
            "dev.flutter.pigeon.camera_linux_v4l2.CameraEventApi."
            "onFrameAvailable.100");

  g_autoptr(FclCameraApiStopImageStreamResponse) stop_resp =
      handle_stop_image_stream(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(stop_resp->value), 1u);

  const size_t calls_before_dispose = messenger->sent_calls->size();
  g_autoptr(FclCameraApiDisposeResponse) dispose_resp =
      handle_dispose(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(dispose_resp->value), 1u);
  EXPECT_EQ(registrar->unregister_count, 1);
  EXPECT_TRUE(registrar->textures->empty());
  EXPECT_EQ(dev->close_count, 1);
  ASSERT_EQ(messenger->sent_calls->size(), calls_before_dispose + 1);
  EXPECT_EQ(
      messenger->sent_calls->back().channel,
      "dev.flutter.pigeon.camera_linux_v4l2.CameraEventApi.cameraClosing.100");
  PumpMessengerUntilIdle(messenger);
  g_object_run_dispose(G_OBJECT(messenger));
}

TEST(CameraLinuxV4l2PluginTest,
     DispatchesPendingFrameWhenPreviousDeliveryCompletes) {
  g_autoptr(FakeBinaryMessenger) messenger = fake_binary_messenger_new();
  g_autoptr(FakeTextureRegistrar) registrar = fake_texture_registrar_new();
  std::unique_ptr<FakeV4l2System> v4l2(new FakeV4l2System());
  FakeV4l2Device* dev = v4l2->AddDevice("/dev/video0");
  dev->negotiated_width = 2;
  dev->negotiated_height = 1;

  g_autoptr(FlCameraLinuxV4l2Plugin) plugin =
      fl_camera_linux_v4l2_plugin_new_with_dependencies(
          FL_BINARY_MESSENGER(messenger), FL_TEXTURE_REGISTRAR(registrar),
          std::move(v4l2));

  g_autoptr(FclCameraApiCreateResponse) create_response = handle_create(
      "/dev/video0", CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_LOW, plugin);
  const int64_t camera_id =
      fl_value_get_int(fl_value_get_list_value(create_response->value, 0));
  g_autoptr(FclCameraApiInitializeResponse) initialize_response =
      handle_initialize(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(initialize_response->value), 1u);
  g_autoptr(FclCameraApiStartImageStreamResponse) start_response =
      handle_start_image_stream(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(start_response->value), 1u);

  messenger->defer_responses = true;
  dev->PushFrame({16, 128, 16, 128});
  PumpMainLoopUntil([&] { return messenger->sent_calls->size() == 1; });
  ASSERT_EQ(messenger->sent_calls->size(), 1u);
  ASSERT_EQ(messenger->pending_send_tasks->size(), 1u);

  dev->PushFrame({235, 128, 235, 128});
  PumpMainLoopUntil([&] { return registrar->mark_count >= 2; });
  EXPECT_EQ(messenger->sent_calls->size(), 1u);

  fake_complete_next_send(messenger);
  PumpMainLoopUntil([&] { return messenger->sent_calls->size() == 2; });
  EXPECT_EQ(messenger->sent_calls->size(), 2u);
  ASSERT_EQ(messenger->pending_send_tasks->size(), 1u);

  fake_complete_next_send(messenger);
  messenger->defer_responses = false;
  PumpMainLoopUntil([&] {
    return messenger->finished_send_count == 2 &&
           !g_main_context_pending(nullptr);
  });
  EXPECT_EQ(messenger->finished_send_count, 2);

  g_autoptr(FclCameraApiDisposeResponse) dispose_response =
      handle_dispose(camera_id, plugin);
  ASSERT_EQ(fl_value_get_length(dispose_response->value), 1u);
  PumpMessengerUntilIdle(messenger);
  g_object_run_dispose(G_OBJECT(messenger));
}

TEST(CameraLinuxV4l2PluginTest, RejectsInvalidCameraStatesAndHandlesDispose) {
  g_autoptr(FakeBinaryMessenger) messenger = fake_binary_messenger_new();
  g_autoptr(FakeTextureRegistrar) registrar = fake_texture_registrar_new();
  std::unique_ptr<FakeV4l2System> v4l2(new FakeV4l2System());
  v4l2->AddDevice("/dev/video0");

  g_autoptr(FlCameraLinuxV4l2Plugin) plugin =
      fl_camera_linux_v4l2_plugin_new_with_dependencies(
          FL_BINARY_MESSENGER(messenger), FL_TEXTURE_REGISTRAR(registrar),
          std::move(v4l2));

  // Empty or non-/dev/videoN paths fail creation.
  g_autoptr(FclCameraApiCreateResponse) bad_create = handle_create(
      "", CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_MEDIUM, plugin);
  ASSERT_GT(fl_value_get_length(bad_create->value), 1u);
  for (const char* invalid_path :
       {"/etc/passwd", "/dev/video", "/dev/video0/../sda"}) {
    g_autoptr(FclCameraApiCreateResponse) bad_path = handle_create(
        invalid_path, CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_MEDIUM,
        plugin);
    ASSERT_GT(fl_value_get_length(bad_path->value), 1u) << invalid_path;
  }

  // Unknown camera IDs return camera_not_found.
  g_autoptr(FclCameraApiInitializeResponse) missing_init =
      handle_initialize(999, plugin);
  ASSERT_GT(fl_value_get_length(missing_init->value), 1u);
  EXPECT_STREQ(
      fl_value_get_string(fl_value_get_list_value(missing_init->value, 0)),
      "camera_not_found");

  // Uninitialized camera cannot stream.
  g_autoptr(FclCameraApiCreateResponse) create_resp = handle_create(
      "/dev/video0", CAMERA_LINUX_V4L2_PLATFORM_RESOLUTION_PRESET_LOW, plugin);
  const int64_t camera_id =
      fl_value_get_int(fl_value_get_list_value(create_resp->value, 0));

  g_autoptr(FclCameraApiStartImageStreamResponse) uninit_stream =
      handle_start_image_stream(camera_id, plugin);
  ASSERT_GT(fl_value_get_length(uninit_stream->value), 1u);
  EXPECT_STREQ(
      fl_value_get_string(fl_value_get_list_value(uninit_stream->value, 0)),
      "camera_not_initialized");

  // Disposing an unknown camera ID is a no-op.
  g_autoptr(FclCameraApiDisposeResponse) noop_dispose =
      handle_dispose(999, plugin);
  EXPECT_EQ(fl_value_get_length(noop_dispose->value), 1u);

  // Initialize then simulate engine messenger shutdown (which breaks the
  // messenger <-> handler ref cycle) and drop the plugin without explicit
  // dispose to verify fl_camera_linux_v4l2_plugin_dispose cleans up cleanly.
  g_autoptr(FclCameraApiInitializeResponse) init_resp =
      handle_initialize(camera_id, plugin);
  EXPECT_EQ(fl_value_get_length(init_resp->value), 1u);

  g_object_run_dispose(G_OBJECT(messenger));
  g_clear_object(&plugin);
  g_clear_object(&messenger);
  EXPECT_EQ(registrar->unregister_count, 1);
}

}  // namespace
}  // namespace test
}  // namespace camera_linux_v4l2
