// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PLATFORM_TESTS_TEST_PLUGIN_LINUX_TEST_UTILS_FAKE_HOST_MESSENGER_H_
#define PLATFORM_TESTS_TEST_PLUGIN_LINUX_TEST_UTILS_FAKE_HOST_MESSENGER_H_

#include <flutter_linux/flutter_linux.h>

typedef void (*FakeHostMessengerReplyHandler)(FlValue* reply,
                                              gpointer user_data);

// A BinaryMessenger that allows tests to act as the engine to call host APIs.
G_DECLARE_FINAL_TYPE(FakeHostMessenger, fake_host_messenger, FAKE,
                     HOST_MESSENGER, GObject)

FakeHostMessenger* fake_host_messenger_new(FlMessageCodec* codec);

// Calls the registered handler for the given channel, and calls reply_handler
// with the response.
//
// This allows a test to simulate a message from the Dart side, exercising the
// encoding and decoding logic generated for a host API.
void fake_host_messenger_send_host_message(
    FakeHostMessenger* messenger, const gchar* channel, FlValue* message,
    FakeHostMessengerReplyHandler reply_callback, gpointer user_data);

#endif  // PLATFORM_TESTS_TEST_PLUGIN_LINUX_TEST_UTILS_FAKE_HOST_MESSENGER_H_
