// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/primitive.gen.h"
#include "test/utils/fake_host_messenger.h"

static PrimitivePigeonTestPrimitiveHostApiAnIntResponse* an_int(
    int64_t value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_an_int_response_new(value);
}

static PrimitivePigeonTestPrimitiveHostApiABoolResponse* a_bool(
    gboolean value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_bool_response_new(value);
}

static PrimitivePigeonTestPrimitiveHostApiAStringResponse* a_string(
    const gchar* value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_string_response_new(value);
}

static PrimitivePigeonTestPrimitiveHostApiADoubleResponse* a_double(
    double value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_double_response_new(value);
}

static PrimitivePigeonTestPrimitiveHostApiAMapResponse* a_map(
    FlValue* value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_map_response_new(value);
}

static PrimitivePigeonTestPrimitiveHostApiAListResponse* a_list(
    FlValue* value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_list_response_new(value);
}

static PrimitivePigeonTestPrimitiveHostApiAnInt32ListResponse* an_int32_list(
    const int32_t* value, size_t value_length, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_an_int32_list_response_new(
      value, value_length);
}

static PrimitivePigeonTestPrimitiveHostApiABoolListResponse* a_bool_list(
    FlValue* value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_bool_list_response_new(
      value);
}

static PrimitivePigeonTestPrimitiveHostApiAStringIntMapResponse*
a_string_int_map(FlValue* value, gpointer user_data) {
  return primitive_pigeon_test_primitive_host_api_a_string_int_map_response_new(
      value);
}

static PrimitivePigeonTestPrimitiveHostApiVTable vtable = {
    .an_int = an_int,
    .a_bool = a_bool,
    .a_string = a_string,
    .a_double = a_double,
    .a_map = a_map,
    .a_list = a_list,
    .an_int32_list = an_int32_list,
    .a_bool_list = a_bool_list,
    .a_string_int_map = a_string_int_map};

static void an_int_reply_cb(FlValue* reply, gpointer user_data) {
  int64_t* result = reinterpret_cast<int64_t*>(user_data);
  *result = fl_value_get_int(fl_value_get_list_value(reply, 0));
}

TEST(Primitive, HostInt) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  primitive_pigeon_test_primitive_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  int64_t result = 0;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_int(7));
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt",
      message, an_int_reply_cb, &result);

  EXPECT_EQ(result, 7);
}

static void a_bool_reply_cb(FlValue* reply, gpointer user_data) {
  gboolean* result = reinterpret_cast<gboolean*>(user_data);
  *result = fl_value_get_bool(fl_value_get_list_value(reply, 0));
}

TEST(Primitive, HostBool) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  primitive_pigeon_test_primitive_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  gboolean result = false;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_bool(TRUE));
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBool",
      message, a_bool_reply_cb, &result);

  EXPECT_EQ(result, true);
}

static void a_double_reply_cb(FlValue* reply, gpointer user_data) {
  double* result = reinterpret_cast<double*>(user_data);
  *result = fl_value_get_float(fl_value_get_list_value(reply, 0));
}

TEST(Primitive, HostDouble) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  primitive_pigeon_test_primitive_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  double result = 0.0;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_float(3.0));
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aDouble",
      message, a_double_reply_cb, &result);

  EXPECT_EQ(result, 3.0);
}

static void a_string_reply_cb(FlValue* reply, gpointer user_data) {
  gchar** result = reinterpret_cast<gchar**>(user_data);
  *result = g_strdup(fl_value_get_string(fl_value_get_list_value(reply, 0)));
}

TEST(Primitive, HostString) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  primitive_pigeon_test_primitive_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  g_autofree gchar* result = nullptr;
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_string("hello"));
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aString",
      message, a_string_reply_cb, &result);

  EXPECT_STREQ(result, "hello");
}

static void a_list_reply_cb(FlValue* reply, gpointer user_data) {
  FlValue** result = reinterpret_cast<FlValue**>(user_data);
  *result = fl_value_ref(fl_value_get_list_value(reply, 0));
}

TEST(Primitive, HostList) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  primitive_pigeon_test_primitive_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  g_autoptr(FlValue) result = nullptr;
  g_autoptr(FlValue) message = fl_value_new_list();
  g_autoptr(FlValue) list = fl_value_new_list();
  fl_value_append_take(list, fl_value_new_int(1));
  fl_value_append_take(list, fl_value_new_int(2));
  fl_value_append_take(list, fl_value_new_int(3));
  fl_value_append(message, list);
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aList",
      message, a_list_reply_cb, &result);

  EXPECT_EQ(fl_value_get_length(result), 3);
  EXPECT_EQ(fl_value_get_int(fl_value_get_list_value(result, 2)), 3);
}

static void a_map_reply_cb(FlValue* reply, gpointer user_data) {
  FlValue** result = reinterpret_cast<FlValue**>(user_data);
  *result = fl_value_ref(fl_value_get_list_value(reply, 0));
}

TEST(Primitive, HostMap) {
  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  g_autoptr(FakeHostMessenger) messenger =
      fake_host_messenger_new(FL_MESSAGE_CODEC(codec));
  primitive_pigeon_test_primitive_host_api_set_method_handlers(
      FL_BINARY_MESSENGER(messenger), nullptr, &vtable, nullptr, nullptr);

  g_autoptr(FlValue) result = nullptr;
  g_autoptr(FlValue) message = fl_value_new_list();
  g_autoptr(FlValue) map = fl_value_new_map();
  fl_value_set_string_take(map, "foo", fl_value_new_string("bar"));
  fl_value_append(message, map);
  fake_host_messenger_send_host_message(
      messenger,
      "dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aMap",
      message, a_map_reply_cb, &result);

  EXPECT_EQ(fl_value_get_length(result), 1);
  EXPECT_STREQ(fl_value_get_string(fl_value_lookup_string(result, "foo")),
               "bar");
}

// TODO(stuartmorgan): Add FlutterApi versions of the tests.
