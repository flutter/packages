// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <flutter_linux/flutter_linux.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <memory>
#include <string>

#include "include/url_launcher_linux/url_launcher_plugin.h"
#include "url_launcher_plugin_private.h"

// Re-declare the opaque struct as a temporary workaround for the lack of
// APIs for reading host API response objects.
// TODO(stuartmorgan): Remove this once the following is fixed:
// https://github.com/flutter/flutter/issues/152166.
struct _FulUrlLauncherApiCanLaunchUrlResponse {
  GObject parent_instance;

  FlValue* value;
};

namespace url_launcher_plugin {
namespace test {

TEST(UrlLauncherPlugin, CanLaunchSuccess) {
  g_autoptr(FulUrlLauncherApiCanLaunchUrlResponse) response =
      handle_can_launch_url("https://flutter.dev", nullptr);
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(fl_value_get_type(response->value) == FL_VALUE_TYPE_LIST);
  ASSERT_TRUE(fl_value_get_length(response->value) == 1);
  g_autoptr(FlValue) expected = fl_value_new_bool(true);
  EXPECT_TRUE(
      fl_value_equal(fl_value_get_list_value(response->value, 0), expected));
}

TEST(UrlLauncherPlugin, CanLaunchFailureUnhandled) {
  g_autoptr(FulUrlLauncherApiCanLaunchUrlResponse) response =
      handle_can_launch_url("madeup:scheme", nullptr);
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(fl_value_get_type(response->value) == FL_VALUE_TYPE_LIST);
  ASSERT_TRUE(fl_value_get_length(response->value) == 1);
  g_autoptr(FlValue) expected = fl_value_new_bool(false);
  EXPECT_TRUE(
      fl_value_equal(fl_value_get_list_value(response->value, 0), expected));
}

TEST(UrlLauncherPlugin, CanLaunchFileSuccess) {
  g_autoptr(FulUrlLauncherApiCanLaunchUrlResponse) response =
      handle_can_launch_url("file:///", nullptr);
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(fl_value_get_type(response->value) == FL_VALUE_TYPE_LIST);
  ASSERT_TRUE(fl_value_get_length(response->value) == 1);
  g_autoptr(FlValue) expected = fl_value_new_bool(true);
  EXPECT_TRUE(
      fl_value_equal(fl_value_get_list_value(response->value, 0), expected));
}

TEST(UrlLauncherPlugin, CanLaunchFailureInvalidFileExtension) {
  g_autoptr(FulUrlLauncherApiCanLaunchUrlResponse) response =
      handle_can_launch_url("file:///madeup.madeupextension", nullptr);
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(fl_value_get_type(response->value) == FL_VALUE_TYPE_LIST);
  ASSERT_TRUE(fl_value_get_length(response->value) == 1);
  g_autoptr(FlValue) expected = fl_value_new_bool(false);
  EXPECT_TRUE(
      fl_value_equal(fl_value_get_list_value(response->value, 0), expected));
}

// For consistency with the established mobile implementations,
// an invalid URL should return false, not an error.
TEST(UrlLauncherPlugin, CanLaunchFailureInvalidUrl) {
  g_autoptr(FulUrlLauncherApiCanLaunchUrlResponse) response =
      handle_can_launch_url("", nullptr);
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(fl_value_get_type(response->value) == FL_VALUE_TYPE_LIST);
  ASSERT_TRUE(fl_value_get_length(response->value) == 1);
  g_autoptr(FlValue) expected = fl_value_new_bool(false);
  EXPECT_TRUE(
      fl_value_equal(fl_value_get_list_value(response->value, 0), expected));
}

}  // namespace test
}  // namespace url_launcher_plugin
