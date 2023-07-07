// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "file_selector_plugin.h"

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <functional>
#include <memory>
#include <string>
#include <variant>

#include "file_dialog_controller.h"
#include "string_utils.h"
#include "test/test_file_dialog_controller.h"
#include "test/test_utils.h"

namespace file_selector_windows {
namespace test {

namespace {

using flutter::CustomEncodableValue;
using flutter::EncodableList;
using flutter::EncodableValue;

}  // namespace

TEST(FileSelectorPlugin, TestOpenSimple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_file.file(),
                                        IID_PPV_ARGS(&fake_result_array));

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_EQ(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_EQ(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ false, EncodableList()),
      nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file.path()));
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestOpenWithArguments) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_file.file(),
                                        IID_PPV_ARGS(&fake_result_array));

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate arguments.
    EXPECT_EQ(dialog.GetDialogFolderPath(), L"C:\\Program Files");
    // Make sure that the folder was called via SetFolder, not SetDefaultFolder.
    EXPECT_EQ(dialog.GetSetFolderPath(), L"C:\\Program Files");
    EXPECT_EQ(dialog.GetOkButtonLabel(), L"Open it!");

    return MockShowResult(fake_result_array);
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  // This directory must exist.
  std::string initial_directory("C:\\Program Files");
  std::string confirm_button("Open it!");
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ false, EncodableList()),
      &initial_directory, &confirm_button);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file.path()));
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestOpenMultiple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestFileIdList fake_selected_file_1;
  ScopedTestFileIdList fake_selected_file_2;
  LPCITEMIDLIST fake_selected_files[] = {
      fake_selected_file_1.file(),
      fake_selected_file_2.file(),
  };
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromIDLists(2, fake_selected_files,
                                      &fake_result_array);

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_NE(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_EQ(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ true,
                       /* select folders = */ false, EncodableList()),
      nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 2);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file_1.path()));
  EXPECT_EQ(std::get<std::string>(paths[1]),
            Utf8FromUtf16(fake_selected_file_2.path()));
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestOpenWithFilter) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_file.file(),
                                        IID_PPV_ARGS(&fake_result_array));

  const EncodableValue text_group =
      CustomEncodableValue(TypeGroup("Text", EncodableList({
                                                 EncodableValue("txt"),
                                                 EncodableValue("json"),
                                             })));
  const EncodableValue image_group =
      CustomEncodableValue(TypeGroup("Images", EncodableList({
                                                   EncodableValue("png"),
                                                   EncodableValue("gif"),
                                                   EncodableValue("jpeg"),
                                               })));
  const EncodableValue any_group =
      CustomEncodableValue(TypeGroup("Any", EncodableList()));

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate filter.
    const std::vector<DialogFilter>& filters = dialog.GetFileTypes();
    EXPECT_EQ(filters.size(), 3U);
    if (filters.size() == 3U) {
      EXPECT_EQ(filters[0].name, L"Text");
      EXPECT_EQ(filters[0].spec, L"*.txt;*.json");
      EXPECT_EQ(filters[1].name, L"Images");
      EXPECT_EQ(filters[1].spec, L"*.png;*.gif;*.jpeg");
      EXPECT_EQ(filters[2].name, L"Any");
      EXPECT_EQ(filters[2].spec, L"*.*");
    }

    return MockShowResult(fake_result_array);
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result =
      plugin.ShowOpenDialog(SelectionOptions(/* allow multiple = */ false,
                                             /* select folders = */ false,
                                             EncodableList({
                                                 text_group,
                                                 image_group,
                                                 any_group,
                                             })),
                            nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file.path()));
  // The test dialog controller always reports the last group as
  // selected, so that should be what the plugin returns.
  ASSERT_NE(result.value().type_group_index(), nullptr);
  EXPECT_EQ(*(result.value().type_group_index()), 2);
}

TEST(FileSelectorPlugin, TestOpenCancel) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);

  bool shown = false;
  MockShow show_validator = [&shown, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    return MockShowResult();
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ false, EncodableList()),
      nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  EXPECT_EQ(paths.size(), 0);
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestSaveSimple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;

  bool shown = false;
  MockShow show_validator =
      [&shown, fake_result = fake_selected_file.file(), fake_window](
          const TestFileDialogController& dialog, HWND parent) {
        shown = true;
        EXPECT_EQ(parent, fake_window);

        // Validate options.
        FILEOPENDIALOGOPTIONS options;
        dialog.GetOptions(&options);
        EXPECT_EQ(options & FOS_ALLOWMULTISELECT, 0U);
        EXPECT_EQ(options & FOS_PICKFOLDERS, 0U);

        return MockShowResult(fake_result);
      };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowSaveDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ false, EncodableList()),
      nullptr, nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file.path()));
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestSaveWithArguments) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;

  bool shown = false;
  MockShow show_validator =
      [&shown, fake_result = fake_selected_file.file(), fake_window](
          const TestFileDialogController& dialog, HWND parent) {
        shown = true;
        EXPECT_EQ(parent, fake_window);

        // Validate arguments.
        EXPECT_EQ(dialog.GetDialogFolderPath(), L"C:\\Program Files");
        // Make sure that the folder was called via SetFolder, not
        // SetDefaultFolder.
        EXPECT_EQ(dialog.GetSetFolderPath(), L"C:\\Program Files");
        EXPECT_EQ(dialog.GetFileName(), L"a name");
        EXPECT_EQ(dialog.GetOkButtonLabel(), L"Save it!");

        return MockShowResult(fake_result);
      };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  // This directory must exist.
  std::string initial_directory("C:\\Program Files");
  std::string suggested_name("a name");
  std::string confirm_button("Save it!");
  ErrorOr<FileDialogResult> result = plugin.ShowSaveDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ false, EncodableList()),
      &initial_directory, &suggested_name, &confirm_button);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file.path()));
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestSaveWithFilter) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  ScopedTestShellItem fake_selected_file;

  const EncodableValue text_group =
      CustomEncodableValue(TypeGroup("Text", EncodableList({
                                                 EncodableValue("txt"),
                                                 EncodableValue("json"),
                                             })));
  const EncodableValue image_group =
      CustomEncodableValue(TypeGroup("Images", EncodableList({
                                                   EncodableValue("png"),
                                                   EncodableValue("gif"),
                                                   EncodableValue("jpeg"),
                                               })));

  bool shown = false;
  MockShow show_validator =
      [&shown, fake_result = fake_selected_file.file(), fake_window](
          const TestFileDialogController& dialog, HWND parent) {
        shown = true;
        EXPECT_EQ(parent, fake_window);

        // Validate filter.
        const std::vector<DialogFilter>& filters = dialog.GetFileTypes();
        EXPECT_EQ(filters.size(), 2U);
        if (filters.size() == 2U) {
          EXPECT_EQ(filters[0].name, L"Text");
          EXPECT_EQ(filters[0].spec, L"*.txt;*.json");
          EXPECT_EQ(filters[1].name, L"Images");
          EXPECT_EQ(filters[1].spec, L"*.png;*.gif;*.jpeg");
        }

        return MockShowResult(fake_result);
      };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result =
      plugin.ShowSaveDialog(SelectionOptions(/* allow multiple = */ false,
                                             /* select folders = */ false,
                                             EncodableList({
                                                 text_group,
                                                 image_group,
                                             })),
                            nullptr, nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_file.path()));
  // The test dialog controller always reports the last group as
  // selected, so that should be what the plugin returns.
  ASSERT_NE(result.value().type_group_index(), nullptr);
  EXPECT_EQ(*(result.value().type_group_index()), 1);
}

TEST(FileSelectorPlugin, TestSaveCancel) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);

  bool shown = false;
  MockShow show_validator = [&shown, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    return MockShowResult();
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowSaveDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ false, EncodableList()),
      nullptr, nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  EXPECT_EQ(paths.size(), 0);
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestGetDirectorySimple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  IShellItemPtr fake_selected_directory;
  // This must be a directory that actually exists.
  ::SHCreateItemFromParsingName(L"C:\\Program Files", nullptr,
                                IID_PPV_ARGS(&fake_selected_directory));
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromShellItem(fake_selected_directory,
                                        IID_PPV_ARGS(&fake_result_array));

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_EQ(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_NE(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ true, EncodableList()),
      nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 1);
  EXPECT_EQ(std::get<std::string>(paths[0]), "C:\\Program Files");
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestGetDirectoryMultiple) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);
  // These are actual files, but since the plugin implementation doesn't
  // validate the types of items returned from the system dialog, they are fine
  // to use for unit tests.
  ScopedTestFileIdList fake_selected_dir_1;
  ScopedTestFileIdList fake_selected_dir_2;
  LPCITEMIDLIST fake_selected_dirs[] = {
      fake_selected_dir_1.file(),
      fake_selected_dir_2.file(),
  };
  IShellItemArrayPtr fake_result_array;
  ::SHCreateShellItemArrayFromIDLists(2, fake_selected_dirs,
                                      &fake_result_array);

  bool shown = false;
  MockShow show_validator = [&shown, fake_result_array, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    EXPECT_EQ(parent, fake_window);

    // Validate options.
    FILEOPENDIALOGOPTIONS options;
    dialog.GetOptions(&options);
    EXPECT_NE(options & FOS_ALLOWMULTISELECT, 0U);
    EXPECT_NE(options & FOS_PICKFOLDERS, 0U);

    return MockShowResult(fake_result_array);
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ true, /* select folders = */ true,
                       EncodableList()),
      nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  ASSERT_EQ(paths.size(), 2);
  EXPECT_EQ(std::get<std::string>(paths[0]),
            Utf8FromUtf16(fake_selected_dir_1.path()));
  EXPECT_EQ(std::get<std::string>(paths[1]),
            Utf8FromUtf16(fake_selected_dir_2.path()));
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

TEST(FileSelectorPlugin, TestGetDirectoryCancel) {
  const HWND fake_window = reinterpret_cast<HWND>(1337);

  bool shown = false;
  MockShow show_validator = [&shown, fake_window](
                                const TestFileDialogController& dialog,
                                HWND parent) {
    shown = true;
    return MockShowResult();
  };

  FileSelectorPlugin plugin(
      [fake_window] { return fake_window; },
      std::make_unique<TestFileDialogControllerFactory>(show_validator));
  ErrorOr<FileDialogResult> result = plugin.ShowOpenDialog(
      SelectionOptions(/* allow multiple = */ false,
                       /* select folders = */ true, EncodableList()),
      nullptr, nullptr);

  EXPECT_TRUE(shown);
  ASSERT_FALSE(result.has_error());
  const EncodableList& paths = result.value().paths();
  EXPECT_EQ(paths.size(), 0);
  EXPECT_EQ(result.value().type_group_index(), nullptr);
}

}  // namespace test
}  // namespace file_selector_windows
