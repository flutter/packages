// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/file_selector_linux/file_selector_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtest/gtest.h>
#include <gtk/gtk.h>

#include "file_selector_plugin_private.h"
#include "messages.g.h"

// TODO(stuartmorgan): Restructure the helper to take a callback for showing
// the dialog, so that the tests can mock out that callback with something
// that changes the selection so that the return value path can be tested
// as well.
// TODO(stuartmorgan): Add an injectable wrapper around
// gtk_file_chooser_native_new to allow for testing values that are given as
// construction paramaters and can't be queried later.

// TODO(stuartmorgan): Remove this once
// https://github.com/flutter/flutter/issues/156100 is fixed. For now, this may
// need to be updated to make unit tests pass again any time the
// Pigeon-generated files are updated.
static const int platform_type_group_object_id = 130;

TEST(FileSelectorPlugin, TestOpenSimple) {
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, nullptr, nullptr, nullptr,
                                            nullptr);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr, FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_OPEN,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_OPEN);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
}

TEST(FileSelectorPlugin, TestOpenMultiple) {
  gboolean select_multiple = true;
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, nullptr, nullptr, nullptr,
                                            &select_multiple);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr, FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_OPEN,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_OPEN);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            true);
}

TEST(FileSelectorPlugin, TestOpenWithFilter) {
  g_autoptr(FlValue) type_groups = fl_value_new_list();

  {
    g_autoptr(FlValue) text_group_extensions = fl_value_new_list();

    g_autoptr(FlValue) text_group_mime_types = fl_value_new_list();
    fl_value_append_take(text_group_mime_types,
                         fl_value_new_string("text/plain"));

    g_autoptr(FfsPlatformTypeGroup) text_group = ffs_platform_type_group_new(
        "Text", text_group_extensions, text_group_mime_types);
    fl_value_append_take(
        type_groups, fl_value_new_custom_object(platform_type_group_object_id,
                                                G_OBJECT(text_group)));
  }

  {
    g_autoptr(FlValue) image_group_extensions = fl_value_new_list();
    fl_value_append_take(image_group_extensions, fl_value_new_string("*.png"));
    fl_value_append_take(image_group_extensions, fl_value_new_string("*.gif"));
    fl_value_append_take(image_group_extensions, fl_value_new_string("*.jpeg"));

    g_autoptr(FlValue) image_group_mime_types = fl_value_new_list();

    g_autoptr(FfsPlatformTypeGroup) image_group = ffs_platform_type_group_new(
        "Images", image_group_extensions, image_group_mime_types);
    fl_value_append_take(
        type_groups, fl_value_new_custom_object(platform_type_group_object_id,
                                                G_OBJECT(image_group)));
  }

  {
    g_autoptr(FlValue) any_group_extensions = fl_value_new_list();
    fl_value_append_take(any_group_extensions, fl_value_new_string("*"));

    g_autoptr(FlValue) any_group_mime_types = fl_value_new_list();

    g_autoptr(FfsPlatformTypeGroup) any_group = ffs_platform_type_group_new(
        "Any", any_group_extensions, any_group_mime_types);
    fl_value_append_take(
        type_groups, fl_value_new_custom_object(platform_type_group_object_id,
                                                G_OBJECT(any_group)));
  }

  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(type_groups, nullptr, nullptr,
                                            nullptr, nullptr);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr, FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_OPEN,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_OPEN);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
  // Validate filters.
  g_autoptr(GSList) type_group_list =
      gtk_file_chooser_list_filters(GTK_FILE_CHOOSER(dialog));
  EXPECT_EQ(g_slist_length(type_group_list), 3);
  GtkFileFilter* text_filter =
      GTK_FILE_FILTER(g_slist_nth_data(type_group_list, 0));
  GtkFileFilter* image_filter =
      GTK_FILE_FILTER(g_slist_nth_data(type_group_list, 1));
  GtkFileFilter* any_filter =
      GTK_FILE_FILTER(g_slist_nth_data(type_group_list, 2));
  // Filters can't be inspected, so query them to see that they match expected
  // filter behavior.
  GtkFileFilterInfo text_file_info = {};
  text_file_info.contains = static_cast<GtkFileFilterFlags>(
      GTK_FILE_FILTER_DISPLAY_NAME | GTK_FILE_FILTER_MIME_TYPE);
  text_file_info.display_name = "foo.txt";
  text_file_info.mime_type = "text/plain";
  GtkFileFilterInfo image_file_info = {};
  image_file_info.contains = static_cast<GtkFileFilterFlags>(
      GTK_FILE_FILTER_DISPLAY_NAME | GTK_FILE_FILTER_MIME_TYPE);
  image_file_info.display_name = "foo.png";
  image_file_info.mime_type = "image/png";
  EXPECT_TRUE(gtk_file_filter_filter(text_filter, &text_file_info));
  EXPECT_FALSE(gtk_file_filter_filter(text_filter, &image_file_info));
  EXPECT_FALSE(gtk_file_filter_filter(image_filter, &text_file_info));
  EXPECT_TRUE(gtk_file_filter_filter(image_filter, &image_file_info));
  EXPECT_TRUE(gtk_file_filter_filter(any_filter, &image_file_info));
  EXPECT_TRUE(gtk_file_filter_filter(any_filter, &text_file_info));
}

TEST(FileSelectorPlugin, TestSaveSimple) {
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, nullptr, nullptr, nullptr,
                                            nullptr);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr, FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_SAVE,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SAVE);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
}

TEST(FileSelectorPlugin, TestSaveWithArguments) {
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, "/tmp", "foo.txt", nullptr,
                                            nullptr);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr, FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_SAVE,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SAVE);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
  g_autofree gchar* current_name =
      gtk_file_chooser_get_current_name(GTK_FILE_CHOOSER(dialog));
  EXPECT_STREQ(current_name, "foo.txt");
  // TODO(stuartmorgan): gtk_file_chooser_get_current_folder doesn't seem to
  // return a value set by gtk_file_chooser_set_current_folder, or at least
  // doesn't in a test context, so that's not currently validated.
}

TEST(FileSelectorPlugin, TestGetDirectory) {
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, nullptr, nullptr, nullptr,
                                            nullptr);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr,
      FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_CHOOSE_DIRECTORY,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
}

TEST(FileSelectorPlugin, TestGetMultipleDirectories) {
  gboolean select_multiple = true;
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, nullptr, nullptr, nullptr,
                                            &select_multiple);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr,
      FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_CHOOSE_DIRECTORY,
      options);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            true);
}

static gint mock_run_dialog_cancel(GtkNativeDialog* dialog) {
  return GTK_RESPONSE_CANCEL;
}

TEST(FileSelectorPlugin, TestGetDirectoryCancel) {
  g_autoptr(FfsPlatformFileChooserOptions) options =
      ffs_platform_file_chooser_options_new(nullptr, nullptr, nullptr, nullptr,
                                            nullptr);

  g_autoptr(GtkFileChooserNative) dialog = create_dialog_of_type(
      nullptr,
      FILE_SELECTOR_LINUX_PLATFORM_FILE_CHOOSER_ACTION_TYPE_CHOOSE_DIRECTORY,
      options);

  ASSERT_NE(dialog, nullptr);

  g_autoptr(FfsFileSelectorApiShowFileChooserResponse) response =
      show_file_chooser(dialog, mock_run_dialog_cancel);

  EXPECT_NE(response, nullptr);
}
