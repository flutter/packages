// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/multiple_arity.gen.h"
#include "test/utils/fake_host_messenger.h"

static MultipleArityPigeonTestMultipleArityHostApiSubtractResponse* subtract(
    int64_t x, int64_t y, gpointer user_data) {
  return multiple_arity_pigeon_test_multiple_arity_host_api_subtract_response_new(
      x - y);
}

static MultipleArityPigeonTestMultipleArityHostApiVTable vtable = {
    .subtract = subtract};

static void subtract_reply_cb(FlValue* reply, gpointer user_data) {
  int64_t* result = reinterpret_cast<int64_t*>(user_data);
  *result = fl_value_get_int(fl_value_get_list_value(reply, 0));
}

TEST(MultipleArity, HostSimple) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  multiple_arity_pigeon_test_multiple_arity_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  int64_t result = 0;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_int(30));
  fl_value_append_take(message, fl_value_new_int(10));
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.MultipleArityHostApi."
      "subtract",
      message, subtract_reply_cb, &result);

  EXPECT_EQ(result, 20);
}

// TODO(stuartmorgan): Add a FlutterApi version of the test.
