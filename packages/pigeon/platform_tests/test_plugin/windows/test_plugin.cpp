// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "test_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <memory>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {

using core_tests_pigeontest::AllTypes;
using core_tests_pigeontest::AllWrapperTypes;
using core_tests_pigeontest::ErrorOr;
using core_tests_pigeontest::FlutterError;
using core_tests_pigeontest::HostIntegrationCoreApi;

// static
void TestPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<TestPlugin>();

  HostIntegrationCoreApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

TestPlugin::TestPlugin() {}

TestPlugin::~TestPlugin() {}

std::optional<FlutterError> TestPlugin::Noop() { return std::nullopt; }

ErrorOr<AllTypes> TestPlugin::EchoAllTypes(const AllTypes& everything) {
  return everything;
}

std::optional<FlutterError> TestPlugin::ThrowError() {
  return FlutterError("An error");
}

ErrorOr<std::optional<std::string>> TestPlugin::ExtractNestedString(
    const AllTypesWrapper& wrapper) {
  return wrapper.values().a_string();
}

ErrorOr<AllTypesWrapper> TestPlugin::CreateNestedString(
    const std::string& string) {
  AllTypes innerObject;
  innerObject.set_a_string(string);
  AllTypesWrapper wrapper;
  wrapper.set_values(innerObject);
  return wrapper;
}

}  // namespace test_plugin
