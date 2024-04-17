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

#define TEST_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), test_plugin_get_type(), TestPlugin))

struct _TestPlugin {
  GObject parent_instance;

  CoreTestsPigeonTestHostIntegrationCoreApi* host_core_api;

  CoreTestsPigeonTestFlutterIntegrationCoreApi* flutter_core_api;
};

G_DEFINE_TYPE(TestPlugin, test_plugin, g_object_get_type())

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
      an_string);
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
  // FIXME
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
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoOptionalDefaultDoubleResponse*
echo_optional_default_double(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                             double a_double, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoRequiredIntResponse*
echo_required_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                  int64_t an_int, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoAllNullableTypesResponse*
echo_all_nullable_types(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                        CoreTestsPigeonTestAllNullableTypes* everything,
                        gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoAllNullableTypesWithoutRecursionResponse*
echo_all_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypesWithoutRecursion* everything,
    gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiExtractNestedNullableStringResponse*
extract_nested_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                               CoreTestsPigeonTestAllClassesWrapper* wrapper,
                               gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiCreateNestedNullableStringResponse*
create_nested_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                              const gchar* nullable_string,
                              gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiSendMultipleNullableTypesResponse*
send_multiple_nullable_types(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                             gboolean* a_nullable_bool, int64_t* a_nullable_int,
                             const gchar* a_nullable_string,
                             gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiSendMultipleNullableTypesWithoutRecursionResponse*
send_multiple_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_nullable_bool,
    int64_t* a_nullable_int, const gchar* a_nullable_string,
    gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableIntResponse*
echo_nullable_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                  int64_t* a_nullable_int, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableDoubleResponse*
echo_nullable_double(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                     double* a_nullable_double, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableBoolResponse*
echo_nullable_bool(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   gboolean* a_nullable_bool, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableStringResponse*
echo_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                     const gchar* a_nullable_string, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableUint8ListResponse*
echo_nullable_uint8_list(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                         const uint8_t* a_nullable_uint8_list,
                         size_t a_nullable_uint8_list_length,
                         gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableObjectResponse*
echo_nullable_object(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                     FlValue* a_nullable_object, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableListResponse*
echo_nullable_list(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   FlValue* a_nullable_list, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableMapResponse*
echo_nullable_map(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                  FlValue* a_nullable_map, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNullableEnumResponse*
echo_nullable_enum(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                   CoreTestsPigeonTestAnEnum* an_enum, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoOptionalNullableIntResponse*
echo_optional_nullable_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           int64_t* a_nullable_int, gpointer user_data) {
  // FIXME
}

static CoreTestsPigeonTestHostIntegrationCoreApiEchoNamedNullableStringResponse*
echo_named_nullable_string(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           const gchar* a_nullable_string, gpointer user_data) {
  // FIXME
}

static void noop_async(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                       FlBasicMessageChannelResponseHandle* response_handle,
                       gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_noop(
      self, response_handle);
}

static void echo_async_int(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           int64_t an_int,
                           FlBasicMessageChannelResponseHandle* response_handle,
                           gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_int(
      self, response_handle, an_int);
}

static void echo_async_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_double(
      self, response_handle, a_double);
}

static void echo_async_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_bool(
      self, response_handle, a_bool);
}

static void echo_async_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_string(
      self, response_handle, a_string);
}

static void echo_async_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    const uint8_t* a_uint8_list, size_t a_uint8_list_length,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_uint8_list(
      self, response_handle, a_uint8_list, a_uint8_list_length);
}

static void echo_async_object(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* an_object,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_object(
      self, response_handle, a_object);
}

static void echo_async_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_list(
      self, response_handle, a_list);
}

static void echo_async_map(CoreTestsPigeonTestHostIntegrationCoreApi* api,
                           FlValue* a_map,
                           FlBasicMessageChannelResponseHandle* response_handle,
                           gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_map(
      self, response_handle, a_map);
}

static void echo_async_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_enum(
      self, response_handle, an_enum);
}

static void throw_async_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_pigeon_test_host_integration_core_api_respond_error_throw_async_error(
      self, response_handle, "code", "message", details);
}

static void throw_async_error_from_void(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_pigeon_test_host_integration_core_api_respond_error_throw_async_error_from_void(
      self, response_handle, "code", "message", details);
}

static void throw_async_flutter_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_pigeon_test_host_integration_core_api_respond_error_throw_async_flutter_error(
      self, response_handle, "code", "message", details);
}

static void echo_async_all_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_all_types(
      self, response_handle, everything);
}

static void echo_async_nullable_all_nullable_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_all_nullable_types(
      self, response_handle, everything);
}

static void echo_async_nullable_all_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypesWithoutRecursion* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_all_nullable_types_without_recursion(
      self, response_handle, everything);
}

static void echo_async_nullable_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t* an_int,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_int(
      self, response_handle, an_int);
}

static void echo_async_nullable_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double* a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_double(
      self, response_handle, a_double);
}

static void echo_async_nullable_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_bool(
      self, response_handle, a_bool);
}

static void echo_async_nullable_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_string(
      self, response_handle, a_string);
}

static void echo_async_nullable_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    const uint8_t* a_uint8_list, size_t a_uint8_list_length,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_uint8_list(
      self, response_handle, a_uint8_list, a_uint8_list_length);
}

static void echo_async_nullable_object(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* an_object,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  core_tests_pigeon_test_host_integration_core_api_respond_echo_async_nullable_object(
      self, response_handle, a_object);
}

static void echo_async_nullable_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void echo_async_nullable_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void echo_async_nullable_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum* an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_noop(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_throw_error(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_throw_error_from_void(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_all_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_all_nullable_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypes* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_send_multiple_nullable_types(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_nullable_bool,
    int64_t* a_nullable_int, const gchar* a_nullable_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_all_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAllNullableTypesWithoutRecursion* everything,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_send_multiple_nullable_types_without_recursion(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_nullable_bool,
    int64_t* a_nullable_int, const gchar* a_nullable_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t an_int,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const uint8_t* a_list,
    size_t a_list_length, FlBasicMessageChannelResponseHandle* response_handle,
    gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_nullable_bool(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, gboolean* a_bool,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_nullable_int(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, int64_t* an_int,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_nullable_double(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, double* a_double,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_nullable_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_nullable_uint8_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const uint8_t* a_list,
    size_t a_list_length, FlBasicMessageChannelResponseHandle* response_handle,
    gpointer user_data) {
  // FIXME
}

static void echo_nullable_list_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(FLValue) return_value = nullptr;
  g_autoptr(GError) error = nullptr;
  gboolean r =
      core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_list_finish(
          CORE_TESTS_PIGEON_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &return_value, &error);
}

static void call_flutter_echo_nullable_list(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_list,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);
  core_tests_pigeon_test_flutter_integration_core_api_echo_nullable_list(
      self->flutter_core_api, a_list, nullptr, echo_nullable_list_cb,
      user_data);
}

static void call_flutter_echo_nullable_map(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, FlValue* a_map,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_echo_nullable_enum(
    CoreTestsPigeonTestHostIntegrationCoreApi* api,
    CoreTestsPigeonTestAnEnum* an_enum,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
}

static void call_flutter_small_api_echo_string(
    CoreTestsPigeonTestHostIntegrationCoreApi* api, const gchar* a_string,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  // FIXME
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
  g_clear_object(self->host_core_api);
  g_clear_object(self->flutter_core_api);
  G_OBJECT_CLASS(test_plugin_parent_class)->dispose(object);
}

static void test_plugin_class_init(TestPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = test_plugin_dispose;
}

static void test_plugin_init(TestPlugin* self) {}

static TestPlugin* test_plugin_new(FlBinaryMessenger* messenger) {
  TestPlugin* self = TEST_PLUGIN(g_object_new(test_plugin_get_type(), nullptr));

  self->host_core_api = core_tests_pigeon_test_host_integration_core_api_new(
      messenger, host_core_api_vtable, g_object_ref(self), g_object_unref);
  self->flutter_core_api =
      core_tests_pigeon_test_flutter_integration_core_api_new(messenger);

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
      fl_method_channel_new(messenger, "test_plugin", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);
}
