// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "fake_host_messenger.h"

struct _FakeHostMessenger {
  GObject parent_instance;

  FlMessageCodec* codec;
  GHashTable* message_handlers;
};

G_DECLARE_FINAL_TYPE(FakeHostMessengerResponseHandle,
                     fake_host_messenger_response_handle, FAKE,
                     HOST_MESSENGER_RESPONSE_HANDLE,
                     FlBinaryMessengerResponseHandle)

struct _FakeHostMessengerResponseHandle {
  FlBinaryMessengerResponseHandle parent_instance;

  FakeHostMessengerReplyHandler reply_callback;
  gpointer user_data;
};

static void fake_host_messenger_response_handle_class_init(
    FakeHostMessengerResponseHandleClass* klass) {}

static void fake_host_messenger_response_handle_init(
    FakeHostMessengerResponseHandle* self) {}

G_DEFINE_TYPE(FakeHostMessengerResponseHandle,
              fake_host_messenger_response_handle,
              fl_binary_messenger_response_handle_get_type())

FakeHostMessengerResponseHandle* fake_host_messenger_response_handle_new(
    FakeHostMessengerReplyHandler reply_callback, gpointer user_data) {
  FakeHostMessengerResponseHandle* self = FAKE_HOST_MESSENGER_RESPONSE_HANDLE(
      g_object_new(fake_host_messenger_response_handle_get_type(), nullptr));

  self->reply_callback = reply_callback;
  self->user_data = user_data;

  return self;
}

typedef struct {
  FlBinaryMessengerMessageHandler message_handler;
  gpointer message_handler_data;
  GDestroyNotify message_handler_destroy_notify;
} MessageHandler;

static MessageHandler* message_handler_new(
    FlBinaryMessengerMessageHandler handler, gpointer user_data,
    GDestroyNotify destroy_notify) {
  MessageHandler* self =
      static_cast<MessageHandler*>(g_malloc0(sizeof(MessageHandler)));
  self->message_handler = handler;
  self->message_handler_data = user_data;
  self->message_handler_destroy_notify = destroy_notify;
  return self;
}

static void message_handler_free(gpointer data) {
  MessageHandler* self = static_cast<MessageHandler*>(data);
  if (self->message_handler_destroy_notify) {
    self->message_handler_destroy_notify(self->message_handler_data);
  }

  g_free(self);
}

static void fake_host_messenger_binary_messenger_iface_init(
    FlBinaryMessengerInterface* iface);

G_DEFINE_TYPE_WITH_CODE(
    FakeHostMessenger, fake_host_messenger, G_TYPE_OBJECT,
    G_IMPLEMENT_INTERFACE(fl_binary_messenger_get_type(),
                          fake_host_messenger_binary_messenger_iface_init))

static void set_message_handler_on_channel(
    FlBinaryMessenger* messenger, const gchar* channel,
    FlBinaryMessengerMessageHandler handler, gpointer user_data,
    GDestroyNotify destroy_notify) {
  FakeHostMessenger* self = FAKE_HOST_MESSENGER(messenger);
  g_hash_table_replace(self->message_handlers, g_strdup(channel),
                       message_handler_new(handler, user_data, destroy_notify));
}

static gboolean send_response(FlBinaryMessenger* messenger,
                              FlBinaryMessengerResponseHandle* response_handle,
                              GBytes* response, GError** error) {
  FakeHostMessenger* self = FAKE_HOST_MESSENGER(messenger);
  g_autoptr(FakeHostMessengerResponseHandle) r =
      FAKE_HOST_MESSENGER_RESPONSE_HANDLE(response_handle);
  g_autoptr(FlValue) reply =
      fl_message_codec_decode_message(self->codec, response, error);
  if (reply == nullptr) {
    return FALSE;
  }

  if (r->reply_callback != nullptr) {
    r->reply_callback(reply, r->user_data);
  }

  return TRUE;
}

static void send_on_channel(FlBinaryMessenger* messenger, const gchar* channel,
                            GBytes* message, GCancellable* cancellable,
                            GAsyncReadyCallback callback, gpointer user_data) {}

static GBytes* send_on_channel_finish(FlBinaryMessenger* messenger,
                                      GAsyncResult* result, GError** error) {
  return g_bytes_new(nullptr, 0);
}

static void resize_channel(FlBinaryMessenger* messenger, const gchar* channel,
                           int64_t new_size) {}

static void set_warns_on_channel_overflow(FlBinaryMessenger* messenger,
                                          const gchar* channel, bool warns) {}

static void fake_host_messenger_dispose(GObject* object) {
  FakeHostMessenger* self = FAKE_HOST_MESSENGER(object);

  g_clear_pointer(&self->message_handlers, g_hash_table_unref);
  g_clear_object(&self->codec);

  G_OBJECT_CLASS(fake_host_messenger_parent_class)->dispose(object);
}

static void fake_host_messenger_class_init(FakeHostMessengerClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fake_host_messenger_dispose;
}

static void fake_host_messenger_binary_messenger_iface_init(
    FlBinaryMessengerInterface* iface) {
  iface->set_message_handler_on_channel = set_message_handler_on_channel;
  iface->send_response = send_response;
  iface->send_on_channel = send_on_channel;
  iface->send_on_channel_finish = send_on_channel_finish;
  iface->resize_channel = resize_channel;
  iface->set_warns_on_channel_overflow = set_warns_on_channel_overflow;
}

static void fake_host_messenger_init(FakeHostMessenger* self) {
  self->message_handlers = g_hash_table_new_full(g_str_hash, g_str_equal,
                                                 g_free, message_handler_free);
}

FakeHostMessenger* fake_host_messenger_new(FlMessageCodec* codec) {
  FakeHostMessenger* self = FAKE_HOST_MESSENGER(
      g_object_new(fake_host_messenger_get_type(), nullptr));

  self->codec = FL_MESSAGE_CODEC(g_object_ref(codec));

  return self;
}

void fake_host_messenger_send_host_message(
    FakeHostMessenger* self, const gchar* channel, FlValue* message,
    FakeHostMessengerReplyHandler reply_callback, gpointer user_data) {
  MessageHandler* handler = static_cast<MessageHandler*>(
      g_hash_table_lookup(self->message_handlers, channel));
  if (handler == nullptr) {
    return;
  }

  g_autoptr(GError) error = nullptr;
  g_autoptr(GBytes) encoded_message =
      fl_message_codec_encode_message(self->codec, message, &error);
  if (encoded_message == nullptr) {
    g_warning("Failed to encode message: %s", error->message);
    return;
  }

  FakeHostMessengerResponseHandle* response_handle =
      fake_host_messenger_response_handle_new(reply_callback, user_data);
  handler->message_handler(FL_BINARY_MESSENGER(self), channel, encoded_message,
                           FL_BINARY_MESSENGER_RESPONSE_HANDLE(response_handle),
                           handler->message_handler_data);
}
