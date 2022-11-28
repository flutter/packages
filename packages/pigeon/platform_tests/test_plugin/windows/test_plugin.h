// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_PLUGIN_TEST_PLUGIN_H_
#define FLUTTER_PLUGIN_TEST_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "pigeon/all_datatypes.gen.h"
#include "pigeon/all_void.gen.h"

namespace test_plugin {

// This plugin handles the native side of the integration tests in
// example/integration_test/
class TestPlugin : public flutter::Plugin,
                   public all_datatypes_pigeontest::HostEverything,
                   public all_void_pigeontest::AllVoidHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  TestPlugin();

  virtual ~TestPlugin();

  // Disallow copy and assign.
  TestPlugin(const TestPlugin&) = delete;
  TestPlugin& operator=(const TestPlugin&) = delete;

  // AllVoidHostApi.
  std::optional<all_void_pigeontest::FlutterError> Doit() override;

  // HostEverything.
  all_datatypes_pigeontest::ErrorOr<all_datatypes_pigeontest::Everything>
  GiveMeEverything() override;
  all_datatypes_pigeontest::ErrorOr<all_datatypes_pigeontest::Everything> Echo(
      const all_datatypes_pigeontest::Everything& everything) override;
};

}  // namespace test_plugin

#endif  // FLUTTER_PLUGIN_TEST_PLUGIN_H_
