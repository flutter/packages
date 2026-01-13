// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/nullable_returns.gen.h"
#include "test/utils/fake_host_messenger.h"

static NullableReturnsPigeonTestNullableArgHostApiDoitResponse* arg_doit(
    int64_t* x, gpointer user_data) {
  return nullable_returns_pigeon_test_nullable_arg_host_api_doit_response_new(
      x == nullptr ? 42 : *x);
}

static NullableReturnsPigeonTestNullableArgHostApiVTable arg_vtable = {
    .doit = arg_doit};

static void arg_doit_reply_cb(FlValue* reply, gpointer user_data) {
  int64_t* result = reinterpret_cast<int64_t*>(user_data);
  *result = fl_value_get_int(fl_value_get_list_value(reply, 0));
}

TEST(NullableReturns, HostNullableArgNull) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  nullable_returns_pigeon_test_nullable_arg_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &arg_vtable, nullptr, nullptr);

  int64_t result = 0;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_null());
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.NullableArgHostApi.doit",
      message, arg_doit_reply_cb, &result);

  EXPECT_EQ(result, 42);
}

TEST(NullableReturns, HostNullableArgNonNull) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  nullable_returns_pigeon_test_nullable_arg_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &arg_vtable, nullptr, nullptr);

  int64_t result = 0;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_int(7));
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.NullableArgHostApi.doit",
      message, arg_doit_reply_cb, &result);

  EXPECT_EQ(result, 7);
}

static NullableReturnsPigeonTestNullableReturnHostApiDoitResponse*
return_null_doit(gpointer user_data) {
  return nullable_returns_pigeon_test_nullable_return_host_api_doit_response_new(
      nullptr);
}

static NullableReturnsPigeonTestNullableReturnHostApiVTable return_null_vtable =
    {.doit = return_null_doit};

static NullableReturnsPigeonTestNullableReturnHostApiDoitResponse*
return_nonnull_doit(gpointer user_data) {
  int64_t return_value = 42;
  return nullable_returns_pigeon_test_nullable_return_host_api_doit_response_new(
      &return_value);
}

static NullableReturnsPigeonTestNullableReturnHostApiVTable
    return_nonnull_vtable = {.doit = return_nonnull_doit};

static void return_doit_reply_cb(FlValue* reply, gpointer user_data) {
  int64_t** result = reinterpret_cast<int64_t**>(user_data);
  FlValue* value = fl_value_get_list_value(reply, 0);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
    *result = nullptr;
  } else {
    *result = reinterpret_cast<int64_t*>(malloc(sizeof(int64_t)));
    **result = fl_value_get_int(value);
  }
}

TEST(NullableReturns, HostNullableReturnNull) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  nullable_returns_pigeon_test_nullable_return_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &return_null_vtable, nullptr,
      nullptr);

  // Initialize to a non-null value to ensure that it's actually set to null,
  // rather than just never set.
  int64_t result_ = 99;
  int64_t* result = &result_;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_null());
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.NullableReturnHostApi.doit",
      message, return_doit_reply_cb, &result);

  EXPECT_EQ(result, nullptr);
}

TEST(NullableReturns, HostNullableReturnNonNull) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  nullable_returns_pigeon_test_nullable_return_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &return_nonnull_vtable, nullptr,
      nullptr);

  g_autofree int64_t* result = nullptr;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_null());
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.NullableReturnHostApi.doit",
      message, return_doit_reply_cb, &result);

  EXPECT_NE(result, nullptr);
  EXPECT_EQ(*result, 42);
}

// TODO(stuartmorgan): Add FlutterApi versions of the tests.
