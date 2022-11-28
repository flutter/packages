// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "test_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <memory>

#include "pigeon/all_datatypes.gen.h"
#include "pigeon/all_void.gen.h"

namespace test_plugin {

using all_datatypes_pigeontest::Everything;
using all_datatypes_pigeontest::HostEverything;
using all_void_pigeontest::AllVoidHostApi;

// static
void TestPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<TestPlugin>();

  AllVoidHostApi::SetUp(registrar->messenger(), plugin.get());
  HostEverything::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

TestPlugin::TestPlugin() {}

TestPlugin::~TestPlugin() {}

std::optional<all_void_pigeontest::FlutterError> TestPlugin::Doit() {
  // No-op.
  return std::nullopt;
}

// HostEverything.
all_datatypes_pigeontest::ErrorOr<Everything> TestPlugin::GiveMeEverything() {
  // Currently unused in integration tests, so just return an empty object.
  return Everything();
}

all_datatypes_pigeontest::ErrorOr<Everything> TestPlugin::Echo(
    const Everything& everything) {
  return everything;
}

}  // namespace test_plugin
