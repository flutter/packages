// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/test_plugin/test_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "pigeon/core_tests.gen.h"
#include "test_plugin_private.h"

struct _TestPlugin {
  GObject parent_instance;

  CoreTestsPigeonTestHostIntegrationCoreApi* host_core_api;

  CoreTestsPigeonTestHostSmallApi* host_small_api;

  CoreTestsPigeonTestFlutterIntegrationCoreApi* flutter_core_api;

  CoreTestsPigeonTestFlutterSmallApi* flutter_small_api;

  GCancellable* cancellable;
};

G_DEFINE_TYPE(TestPlugin, test_plugin, G_TYPE_OBJECT)

typedef struct {
  TestPlugin* self;
  FlBasicMessageChannelResponseHandle* response_handle;
} CallbackData;

static CallbackData* callback_data_new(
    TestPlugin* self, FlBasicMessageChannelResponseHandle* response_handle) {
  CallbackData* data = g_new0(CallbackData, 1);
  data->self = g_object_ref(self);
  data->response_handle = g_object_ref(response_handle);
  return data;
}

static void callback_data_free(CallbackData* data) {
  g_object_unref(data->self);
  g_object_unref(data->response_handle);
  free(data);
}

G_DEFINE_AUTOPTR_CLEANUP_FUNC(CallbackData, callback_data_free)

static CoreTestsPigeonTestHostIntegrationCoreApiNoopResponse* noop(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_noop_response_new();
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoAllTypesResponse*
echo_all_types(CoreTestsPigeonTestHostIntegrationCoreApi* api,
               CoreTestsPigeonTestAllTypes* everything, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_all_types_response_new(
      everything);
}

static CoreTestsPigeonTestHostIntegrationCoreApiThrowErrorResponse* throw_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_throw_error_response_new_error(
      "An error", "", nullptr);
}

static CoreTestsPigeonTestHostIntegrationCoreApiThrowErrorFromVoidResponse*
throw_error_from_void(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                      gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_throw_error_from_void_response_new_error(
      "An error", "", nullptr);
}

static CoreTestsPigeonTestHostIntegrationCoreApiThrowFlutterErrorResponse*
throw_flutter_error(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                    gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  return core_tests_pigeon_test_host_integration_core_api_throw_flutter_error_response_new_error(
      "code", "message", details);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoIntResponse* echo_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t an_int,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_int_response_new(
      an_int);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoDoubleResponse* echo_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double a_double,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_double_response_new(
      a_double);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoBoolResponse* echo_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean a_bool,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_bool_response_new(
      a_bool);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoStringResponse* echo_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_string_response_new(
      a_string);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoUint8ListResponse*
echo_uint8_list(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                const uint8_t* a_uint8_list, size_t a_uint8_list_length,
                gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_uint8_list_response_new(
      a_uint8_list, a_uint8_list_length);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoObjectResponse* echo_object(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* an_object,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_object_response_new(
      an_object);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoListResponse* echo_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_list_response_new(
      a_list);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoMapResponse* echo_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_map_response_new(
      a_map);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoClassWrapperResponse*
echo_class_wrapper(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   CoreTestsPigeonTestAllClassesWrapper* wrapper,
                   gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_class_wrapper_response_new(
      wrapper);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoEnumResponse* echo_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum an_enum, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_enum_response_new(
      an_enum);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNamedDefaultStringResponse*
echo_named_default_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                          const gchar* a_string, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_named_default_string_response_new(
      a_string);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoOptionalDefaultDoubleResponse*
echo_optional_default_double(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                             double a_double, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_optional_default_double_response_new(
      a_double);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoRequiredIntResponse*
echo_required_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                  int64_t an_int, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_required_int_response_new(
      an_int);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoAllNullableTypesResponse*
echo_all_nullable_types(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                        CoreTestsPigeonTestAllNullableTypes* everything,
                        gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_all_nullable_types_response_new(
      everything);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoAllNullableTypesWithoutRecursionResponse*
echo_all_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypesWithoutRecursion* everything,
    gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_all_nullable_types_without_recursion_response_new(
      everything);
}

static CoreTestsPigeonTestHostIntegrationCoreApiExtractNestedNullableStringResponse*
extract_nested_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                               CoreTestsPigeonTestAllClassesWrapper* wrapper,
                               gpointer user_data) {
  CoreTestsPigeonTestAllNullableTypes* types =
      core_tests_pigeon_test_all_classes_wrapper_get_all_nullable_types(
          wrapper);
  return core_tests_pigeon_test_host_integration_core_api_extract_nested_nullable_string_response_new(
      core_tests_pigeon_test_all_nullable_types_get_a_nullable_string(types));
}

static CoreTestsPigeonTestHostIntegrationCoreApiCreateNestedNullableStringResponse*
create_nested_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                              const gchar* nullable_string,
                              gpointer user_data) {
  // FIXME: Make new_full?
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) types =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullable_string, nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllClassesWrapper) wrapper =
      core_tests_pigeon_test_all_classes_wrapper_new(types, nullptr, nullptr);
  return core_tests_pigeon_test_host_integration_core_api_create_nested_nullable_string_response_new(
      wrapper);
}

static CoreTestsPigeonTestHostIntegrationCoreApiSendMultipleNullableTypesResponse*
send_multiple_nullable_types(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                             gboolean* a_nullable_bool, int64_t* a_nullable_int,
                             const gchar* a_nullable_string,
                             gpointer user_data) {
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) types =
      core_tests_pigeon_test_all_nullable_types_new(
          a_nullable_bool, a_nullable_int, nullptr, nullptr, nullptr, 0,
          nullptr, 0, nullptr, 0, nullptr, 0, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, a_nullable_string, nullptr, nullptr);
  return core_tests_pigeon_test_host_integration_core_api_send_multiple_nullable_types_response_new(
      types);
}

static CoreTestsPigeonTestHostIntegrationCoreApiSendMultipleNullableTypesWithoutRecursionResponse*
send_multiple_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_nullable_bool,
    int64_t* a_nullable_int, const gchar* a_nullable_string,
    gpointer user_data) {
  g_autoptr(CoreTestsPigeonTestAllNullableTypesWithoutRecursion) types =
      core_tests_pigeon_test_all_nullable_types_without_recursion_new(
          a_nullable_bool, a_nullable_int, nullptr, nullptr, nullptr, 0,
          nullptr, 0, nullptr, 0, nullptr, 0, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, a_nullable_string, nullptr);
  return core_tests_pigeon_test_host_integration_core_api_send_multiple_nullable_types_without_recursion_response_new(
      types);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableIntResponse*
echo_nullable_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                  int64_t* a_nullable_int, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_int_response_new(
      a_nullable_int);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableDoubleResponse*
echo_nullable_double(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                     double* a_nullable_double, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_double_response_new(
      a_nullable_double);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableBoolResponse*
echo_nullable_bool(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   gboolean* a_nullable_bool, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_bool_response_new(
      a_nullable_bool);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableStringResponse*
echo_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                     const gchar* a_nullable_string, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_string_response_new(
      a_nullable_string);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableUint8ListResponse*
echo_nullable_uint8_list(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                         const uint8_t* a_nullable_uint8_list,
                         size_t a_nullable_uint8_list_length,
                         gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_uint8_list_response_new(
      a_nullable_uint8_list, a_nullable_uint8_list_length);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableObjectResponse*
echo_nullable_object(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                     FlValue* a_nullable_object, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_object_response_new(
      a_nullable_object);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableListResponse*
echo_nullable_list(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   FlValue* a_nullable_list, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_list_response_new(
      a_nullable_list);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableMapResponse*
echo_nullable_map(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                  FlValue* a_nullable_map, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_map_response_new(
      a_nullable_map);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableEnumResponse*
echo_nullable_enum(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   CoreTestsPigeonTestAnEnum* an_enum, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_nullable_enum_response_new(
      an_enum);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoOptionalNullableIntResponse*
echo_optional_nullable_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           int64_t* a_nullable_int, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_optional_nullable_int_response_new(
      a_nullable_int);
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNamedNullableStringResponse*
echo_named_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           const gchar* a_nullable_string, gpointer user_data) {
  return core_tests_pigeon_test_host_integration_core_api_echo_named_nullable_string_response_new(
      a_nullable_string);
}

static void noop_async(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                       FlBasicMessageChannelResponseHandle* response_handle,
                       gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_noop_async(
      api, response_handle);
}

static void echo_async_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           int64_t an_int,
                           FlBasicMessageChannelResponseHandle* response_handle,
                           gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_int(
      api, response_handle, an_int);
}

static void echo_async_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_double(
      api, response_handle, a_double);
}

static void echo_async_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_bool(
      api, response_handle, a_bool);
}

static void echo_async_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_string(
      api, response_handle, a_string);
}

static void echo_async_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const uint8_t* a_uint8_list,
    size_t a_uint8_list_length,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_uint8_list(
      api, response_handle, a_uint8_list, a_uint8_list_length);
}

static void echo_async_object(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* an_object,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_object(
      api, response_handle, an_object);
}

static void echo_async_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_list(
      api, response_handle, a_list);
}

static void echo_async_map(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           FlValue* a_map,
                           FlBasicMessageChannelResponseHandle* response_handle,
                           gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_map(
      api, response_handle, a_map);
}

static void echo_async_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_enum(
      api, response_handle, an_enum);
}

static void throw_async_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_pigeon_test_host_integration_core_api_respond_error_throw_async_error(
      api, response_handle, "code", "message", details);
}

static void throw_async_error_from_void(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_pigeon_test_host_integration_core_api_respond_error_throw_async_error_from_void(
      api, response_handle, "code", "message", details);
}

static void throw_async_flutter_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_pigeon_test_host_integration_core_api_respond_error_throw_async_flutter_error(
      api, response_handle, "code", "message", details);
}

static void echo_async_all_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_all_types(
      api, response_handle, everything);
}

static void echo_async_nullable_all_nullable_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_all_nullable_types(
      api, response_handle, everything);
}

static void echo_async_nullable_all_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypesWithoutRecursion* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_all_nullable_types_without_recursion(
      api, response_handle, everything);
}

static void echo_async_nullable_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t* an_int,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_int(
      api, response_handle, an_int);
}

static void echo_async_nullable_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double* a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_double(
      api, response_handle, a_double);
}

static void echo_async_nullable_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_bool(
      api, response_handle, a_bool);
}

static void echo_async_nullable_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_string(
      api, response_handle, a_string);
}

static void echo_async_nullable_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const uint8_t* a_uint8_list,
    size_t a_uint8_list_length,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_uint8_list(
      api, response_handle, a_uint8_list, a_uint8_list_length);
}

static void echo_async_nullable_object(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* an_object,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_object(
      api, response_handle, an_object);
}

static void echo_async_nullable_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_list(
      api, response_handle, a_list);
}

static void echo_async_nullable_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_map(
      api, response_handle, a_map);
}

static void echo_async_nullable_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum* an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_enum(
      api, response_handle, an_enum);
}

static void noop_cb(GObject* object, GAsyncResult* result, gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_noop_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_noop(
      data->self->host_core_api, data->response_handle);
}

static void call_flutter_noop(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_noop(
      self->flutter_core_api, nullptr, noop_cb,
      callback_data_new(self, response_handle));
}

static void throw_error_cb(GObject* object, GAsyncResult* result,
                           gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(FlValue) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_throw_error_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_throw_error(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_throw_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_throw_error(
      self->flutter_core_api, nullptr, throw_error_cb,
      callback_data_new(self, response_handle));
}

static void throw_error_from_void_cb(GObject* object, GAsyncResult* result,
                                     gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_throw_error_from_void_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_throw_error_from_void(
      data->self->host_core_api, data->response_handle);
}

static void call_flutter_throw_error_from_void(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_throw_error_from_void(
      self->flutter_core_api, nullptr, throw_error_from_void_cb,
      callback_data_new(self, response_handle));
}

static void echo_all_types_cb(GObject* object, GAsyncResult* result,
                              gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(CoreTestsPigeonTestAllTypes) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_all_types_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_all_types(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_all_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_all_types(
      self->flutter_core_api, everything, self->cancellable, echo_all_types_cb,
      callback_data_new(self, response_handle));
}

static void echo_all_nullable_types_cb(GObject* object, GAsyncResult* result,
                                       gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_all_nullable_types_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_all_nullable_types(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_all_nullable_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_all_nullable_types(
      self->flutter_core_api, everything, self->cancellable,
      echo_all_nullable_types_cb, callback_data_new(self, response_handle));
}

static void send_multiple_nullable_types_cb(GObject* object,
                                            GAsyncResult* result,
                                            gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_send_multiple_nullable_types_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_send_multiple_nullable_types(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_send_multiple_nullable_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_nullable_bool,
    int64_t* a_nullable_int, const gchar* a_nullable_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_send_multiple_nullable_types(
      self->flutter_core_api, a_nullable_bool, a_nullable_int,
      a_nullable_string, self->cancellable, send_multiple_nullable_types_cb,
      callback_data_new(self, response_handle));
}

static void echo_all_nullable_types_without_recursion_cb(GObject* object,
                                                         GAsyncResult* result,
                                                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(CoreTestsPigeonTestAllNullableTypesWithoutRecursion) return_value =
      nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_all_nullable_types_without_recursion(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_all_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypesWithoutRecursion* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion(
      self->flutter_core_api, everything, self->cancellable,
      echo_all_nullable_types_without_recursion_cb,
      callback_data_new(self, response_handle));
}

static void send_multiple_nullable_types_without_recursion_cb(
    GObject* object, GAsyncResult* result, gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(CoreTestsPigeonTestAllNullableTypesWithoutRecursion) return_value =
      nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_send_multiple_nullable_types_without_recursion(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_send_multiple_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_nullable_bool,
    int64_t* a_nullable_int, const gchar* a_nullable_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion(
      self->flutter_core_api, a_nullable_bool, a_nullable_int,
      a_nullable_string, self->cancellable,
      send_multiple_nullable_types_without_recursion_cb,
      callback_data_new(self, response_handle));
}

static void echo_bool_cb(GObject* object, GAsyncResult* result,
                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  gboolean return_value;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_bool_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_bool(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_bool(
      self->flutter_core_api, a_bool, self->cancellable, echo_bool_cb,
      callback_data_new(self, response_handle));
}

static void echo_int_cb(GObject* object, GAsyncResult* result,
                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  int64_t return_value;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_int_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_int(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t an_int,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_int(
      self->flutter_core_api, an_int, self->cancellable, echo_int_cb,
      callback_data_new(self, response_handle));
}

static void echo_double_cb(GObject* object, GAsyncResult* result,
                           gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  double return_value;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_double_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_double(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_double(
      self->flutter_core_api, a_double, self->cancellable, echo_double_cb,
      callback_data_new(self, response_handle));
}

static void echo_string_cb(GObject* object, GAsyncResult* result,
                           gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree gchar* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_string_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_string(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_string(
      self->flutter_core_api, a_string, self->cancellable, echo_string_cb,
      callback_data_new(self, response_handle));
}

static void echo_uint8_list_cb(GObject* object, GAsyncResult* result,
                               gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree uint8_t* return_value = nullptr;
  size_t return_value_length;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_uint8_list_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &return_value_length, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_uint8_list(
      data->self->host_core_api, data->response_handle, return_value,
      return_value_length);
}

static void call_flutter_echo_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const uint8_t* a_list,
    size_t a_list_length, FlBasicMessageChannelResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_uint8_list(
      self->flutter_core_api, a_list, a_list_length, self->cancellable,
      echo_uint8_list_cb, callback_data_new(self, response_handle));
}

static void echo_list_cb(GObject* object, GAsyncResult* result,
                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(FlValue) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_list_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_list(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_list(
      self->flutter_core_api, a_list, self->cancellable, echo_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_map_cb(GObject* object, GAsyncResult* result,
                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(FlValue) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_map_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_map(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_map(
      self->flutter_core_api, a_map, self->cancellable, echo_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_enum_cb(GObject* object, GAsyncResult* result,
                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  CoreTestsPigeonTestAnEnum return_value;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_enum_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_enum(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_enum(
      self->flutter_core_api, an_enum, self->cancellable, echo_enum_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_bool_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree gboolean* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_bool_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_bool(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_bool(
      self->flutter_core_api, a_bool, self->cancellable, echo_nullable_bool_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_int_cb(GObject* object, GAsyncResult* result,
                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree int64_t* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_int_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_int(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t* an_int,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_int(
      self->flutter_core_api, an_int, self->cancellable, echo_nullable_int_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_double_cb(GObject* object, GAsyncResult* result,
                                    gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree double* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_double_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_double(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double* a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_double(
      self->flutter_core_api, a_double, self->cancellable,
      echo_nullable_double_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_string_cb(GObject* object, GAsyncResult* result,
                                    gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree gchar* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_string_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_string(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_string(
      self->flutter_core_api, a_string, self->cancellable,
      echo_nullable_string_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_uint8_list_cb(GObject* object, GAsyncResult* result,
                                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree uint8_t* return_value = nullptr;
  size_t return_value_length;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_uint8_list_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &return_value_length, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_uint8_list(
      data->self->host_core_api, data->response_handle, return_value,
      return_value_length);
}

static void call_flutter_echo_nullable_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const uint8_t* a_list,
    size_t a_list_length, FlBasicMessageChannelResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_uint8_list(
      self->flutter_core_api, a_list, a_list_length, self->cancellable,
      echo_nullable_uint8_list_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_list_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(FlValue) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_list_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_list(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_list(
      self->flutter_core_api, a_list, self->cancellable, echo_nullable_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_map_cb(GObject* object, GAsyncResult* result,
                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(FlValue) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_map_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_map(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_map(
      self->flutter_core_api, a_map, self->cancellable, echo_nullable_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_enum_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree CoreTestsPigeonTestAnEnum* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_enum_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
      &return_value, &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_echo_nullable_enum(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_echo_nullable_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum* an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_enum(
      self->flutter_core_api, an_enum, self->cancellable, echo_nullable_enum_cb,
      callback_data_new(self, response_handle));
}

static void small_api_echo_string_cb(GObject* object, GAsyncResult* result,
                                     gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autofree gchar* return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  // FIXME gboolean r =
  core_tests_pigeon_test_flutter_small_api_echo_string_finish(
      CORE_TESTS_PIGEON_TEST_FLUTTER_SMALL_API(object), result, &return_value,
      &error);

  core_tests_pigeon_test_host_integration_core_api_respond_call_flutter_small_api_echo_string(
      data->self->host_core_api, data->response_handle, return_value);
}

static void call_flutter_small_api_echo_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_pigeon_test_flutter_small_api_echo_string(
      self->flutter_small_api, a_string, self->cancellable,
      small_api_echo_string_cb, callback_data_new(self, response_handle));
}

static CoreTestsPigeonTestHostIntegrationCoreApiVTable host_core_api_vtable = {
    .noop = noop,
    .echo_all_types = echo_all_types,
    .throw_error = throw_error,
    .throw_error_from_void = throw_error_from_void,
    .throw_flutter_error = throw_flutter_error,
    .echo_int = echo_int,
    .echo_double = echo_double,
    .echo_bool = echo_bool,
    .echo_string = echo_string,
    .echo_uint8_list = echo_uint8_list,
    .echo_object = echo_object,
    .echo_list = echo_list,
    .echo_map = echo_map,
    .echo_class_wrapper = echo_class_wrapper,
    .echo_enum = echo_enum,
    .echo_named_default_string = echo_named_default_string,
    .echo_optional_default_double = echo_optional_default_double,
    .echo_required_int = echo_required_int,
    .echo_all_nullable_types = echo_all_nullable_types,
    .echo_all_nullable_types_without_recursion =
        echo_all_nullable_types_without_recursion,
    .extract_nested_nullable_string = extract_nested_nullable_string,
    .create_nested_nullable_string = create_nested_nullable_string,
    .send_multiple_nullable_types = send_multiple_nullable_types,
    .send_multiple_nullable_types_without_recursion =
        send_multiple_nullable_types_without_recursion,
    .echo_nullable_int = echo_nullable_int,
    .echo_nullable_double = echo_nullable_double,
    .echo_nullable_bool = echo_nullable_bool,
    .echo_nullable_string = echo_nullable_string,
    .echo_nullable_uint8_list = echo_nullable_uint8_list,
    .echo_nullable_object = echo_nullable_object,
    .echo_nullable_list = echo_nullable_list,
    .echo_nullable_map = echo_nullable_map,
    .echo_nullable_enum = echo_nullable_enum,
    .echo_optional_nullable_int = echo_optional_nullable_int,
    .echo_named_nullable_string = echo_named_nullable_string,
    .noop_async = noop_async,
    .echo_async_int = echo_async_int,
    .echo_async_double = echo_async_double,
    .echo_async_bool = echo_async_bool,
    .echo_async_string = echo_async_string,
    .echo_async_uint8_list = echo_async_uint8_list,
    .echo_async_object = echo_async_object,
    .echo_async_list = echo_async_list,
    .echo_async_map = echo_async_map,
    .echo_async_enum = echo_async_enum,
    .throw_async_error = throw_async_error,
    .throw_async_error_from_void = throw_async_error_from_void,
    .throw_async_flutter_error = throw_async_flutter_error,
    .echo_async_all_types = echo_async_all_types,
    .echo_async_nullable_all_nullable_types =
        echo_async_nullable_all_nullable_types,
    .echo_async_nullable_all_nullable_types_without_recursion =
        echo_async_nullable_all_nullable_types_without_recursion,
    .echo_async_nullable_int = echo_async_nullable_int,
    .echo_async_nullable_double = echo_async_nullable_double,
    .echo_async_nullable_bool = echo_async_nullable_bool,
    .echo_async_nullable_string = echo_async_nullable_string,
    .echo_async_nullable_uint8_list = echo_async_nullable_uint8_list,
    .echo_async_nullable_object = echo_async_nullable_object,
    .echo_async_nullable_list = echo_async_nullable_list,
    .echo_async_nullable_map = echo_async_nullable_map,
    .echo_async_nullable_enum = echo_async_nullable_enum,
    .call_flutter_noop = call_flutter_noop,
    .call_flutter_throw_error = call_flutter_throw_error,
    .call_flutter_throw_error_from_void = call_flutter_throw_error_from_void,
    .call_flutter_echo_all_types = call_flutter_echo_all_types,
    .call_flutter_echo_all_nullable_types =
        call_flutter_echo_all_nullable_types,
    .call_flutter_send_multiple_nullable_types =
        call_flutter_send_multiple_nullable_types,
    .call_flutter_echo_all_nullable_types_without_recursion =
        call_flutter_echo_all_nullable_types_without_recursion,
    .call_flutter_send_multiple_nullable_types_without_recursion =
        call_flutter_send_multiple_nullable_types_without_recursion,
    .call_flutter_echo_bool = call_flutter_echo_bool,
    .call_flutter_echo_int = call_flutter_echo_int,
    .call_flutter_echo_double = call_flutter_echo_double,
    .call_flutter_echo_string = call_flutter_echo_string,
    .call_flutter_echo_uint8_list = call_flutter_echo_uint8_list,
    .call_flutter_echo_list = call_flutter_echo_list,
    .call_flutter_echo_map = call_flutter_echo_map,
    .call_flutter_echo_enum = call_flutter_echo_enum,
    .call_flutter_echo_nullable_bool = call_flutter_echo_nullable_bool,
    .call_flutter_echo_nullable_int = call_flutter_echo_nullable_int,
    .call_flutter_echo_nullable_double = call_flutter_echo_nullable_double,
    .call_flutter_echo_nullable_string = call_flutter_echo_nullable_string,
    .call_flutter_echo_nullable_uint8_list =
        call_flutter_echo_nullable_uint8_list,
    .call_flutter_echo_nullable_list = call_flutter_echo_nullable_list,
    .call_flutter_echo_nullable_map = call_flutter_echo_nullable_map,
    .call_flutter_echo_nullable_enum = call_flutter_echo_nullable_enum,
    .call_flutter_small_api_echo_string = call_flutter_small_api_echo_string};

static void echo(CoreTestsPigeonTestHostSmallApi* api, const gchar* a_string,
                 FlBasicMessageChannelResponseHandle* response_handle,
                 gpointer user_data) {}

static void void_void(CoreTestsPigeonTestHostSmallApi* api,
                      FlBasicMessageChannelResponseHandle* response_handle,
                      gpointer user_data) {}

static CoreTestsPigeonTestHostSmallApiVTable host_small_api_vtable = {
    .echo = echo, .void_void = void_void};

// Called when a method call is received from Flutter.
static void test_plugin_handle_method_call(TestPlugin* self,
                                           FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = get_platform_version();
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);
  g_autofree gchar* version = g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void test_plugin_dispose(GObject* object) {
  TestPlugin* self = TEST_PLUGIN(object);

  g_cancellable_cancel(self->cancellable);

  g_clear_object(&self->host_core_api);
  g_clear_object(&self->host_small_api);
  g_clear_object(&self->flutter_core_api);
  g_clear_object(&self->flutter_small_api);
  g_clear_object(&self->cancellable);

  G_OBJECT_CLASS(test_plugin_parent_class)->dispose(object);
}

static void test_plugin_class_init(TestPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = test_plugin_dispose;
}

static void test_plugin_init(TestPlugin* self) {
  self->cancellable = g_cancellable_new();
}

static TestPlugin* test_plugin_new(FlBinaryMessenger* messenger) {
  TestPlugin* self = TEST_PLUGIN(g_object_new(test_plugin_get_type(), nullptr));

  self->host_core_api = core_tests_pigeon_test_host_integration_core_api_new(
      messenger, &host_core_api_vtable, g_object_ref(self), g_object_unref);
  self->host_small_api = core_tests_pigeon_test_host_small_api_new(
      messenger, &host_small_api_vtable, g_object_ref(self), g_object_unref);
  self->flutter_core_api =
      core_tests_pigeon_test_flutter_integration_core_api_new(messenger);
  self->flutter_small_api =
      core_tests_pigeon_test_flutter_small_api_new(messenger);

  return self;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  TestPlugin* plugin = TEST_PLUGIN(user_data);
  test_plugin_handle_method_call(plugin, method_call);
}

void test_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  g_autoptr(TestPlugin) plugin =
      test_plugin_new(fl_plugin_registrar_get_messenger(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "test_plugin", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);
}
