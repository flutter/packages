// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "test_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <memory>
#include <optional>
#include <string>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {

using core_tests_pigeontest::AllClassesWrapper;
using core_tests_pigeontest::AllNullableTypes;
using core_tests_pigeontest::AllNullableTypesWithoutRecursion;
using core_tests_pigeontest::AllTypes;
using core_tests_pigeontest::AnEnum;
using core_tests_pigeontest::ErrorOr;
using core_tests_pigeontest::FlutterError;
using core_tests_pigeontest::FlutterIntegrationCoreApi;
using core_tests_pigeontest::HostIntegrationCoreApi;
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// static
void TestPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<TestPlugin>(registrar->messenger());

  HostIntegrationCoreApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

TestPlugin::TestPlugin(flutter::BinaryMessenger* binary_messenger)
    : flutter_api_(
          std::make_unique<FlutterIntegrationCoreApi>(binary_messenger)) {}

TestPlugin::~TestPlugin() {}

std::optional<FlutterError> TestPlugin::Noop() { return std::nullopt; }

ErrorOr<AllTypes> TestPlugin::EchoAllTypes(const AllTypes& everything) {
  return everything;
}

ErrorOr<std::optional<AllNullableTypes>> TestPlugin::EchoAllNullableTypes(
    const AllNullableTypes* everything) {
  if (!everything) {
    return std::nullopt;
  }
  return *everything;
}

ErrorOr<std::optional<AllNullableTypesWithoutRecursion>>
TestPlugin::EchoAllNullableTypesWithoutRecursion(
    const AllNullableTypesWithoutRecursion* everything) {
  if (!everything) {
    return std::nullopt;
  }
  return *everything;
}

ErrorOr<std::optional<flutter::EncodableValue>> TestPlugin::ThrowError() {
  return FlutterError("An error");
}

std::optional<FlutterError> TestPlugin::ThrowErrorFromVoid() {
  return FlutterError("An error");
}

ErrorOr<std::optional<flutter::EncodableValue>>
TestPlugin::ThrowFlutterError() {
  return FlutterError("code", "message", EncodableValue("details"));
}

ErrorOr<int64_t> TestPlugin::EchoInt(int64_t an_int) { return an_int; }

ErrorOr<double> TestPlugin::EchoDouble(double a_double) { return a_double; }

ErrorOr<bool> TestPlugin::EchoBool(bool a_bool) { return a_bool; }

ErrorOr<std::string> TestPlugin::EchoString(const std::string& a_string) {
  return a_string;
}

ErrorOr<std::vector<uint8_t>> TestPlugin::EchoUint8List(
    const std::vector<uint8_t>& a_uint8_list) {
  return a_uint8_list;
}

ErrorOr<EncodableValue> TestPlugin::EchoObject(
    const EncodableValue& an_object) {
  return an_object;
}

ErrorOr<EncodableList> TestPlugin::EchoList(const EncodableList& a_list) {
  return a_list;
}

ErrorOr<EncodableMap> TestPlugin::EchoMap(const EncodableMap& a_map) {
  return a_map;
}

ErrorOr<AllClassesWrapper> TestPlugin::EchoClassWrapper(
    const AllClassesWrapper& wrapper) {
  return wrapper;
}

ErrorOr<AnEnum> TestPlugin::EchoEnum(const AnEnum& an_enum) { return an_enum; }

ErrorOr<std::string> TestPlugin::EchoNamedDefaultString(
    const std::string& a_string) {
  return a_string;
}

ErrorOr<double> TestPlugin::EchoOptionalDefaultDouble(double a_double) {
  return a_double;
}

ErrorOr<int64_t> TestPlugin::EchoRequiredInt(int64_t an_int) { return an_int; }

ErrorOr<std::optional<std::string>> TestPlugin::ExtractNestedNullableString(
    const AllClassesWrapper& wrapper) {
  const std::string* inner_string =
      wrapper.all_nullable_types().a_nullable_string();
  return inner_string ? std::optional<std::string>(*inner_string)
                      : std::nullopt;
}

ErrorOr<AllClassesWrapper> TestPlugin::CreateNestedNullableString(
    const std::string* nullable_string) {
  AllNullableTypes inner_object;
  // The string pointer can't be passed through directly since the setter for
  // a string takes a std::string_view rather than std::string so the pointer
  // types don't match.
  if (nullable_string) {
    inner_object.set_a_nullable_string(*nullable_string);
  } else {
    inner_object.set_a_nullable_string(nullptr);
  }
  AllClassesWrapper wrapper(inner_object);
  return wrapper;
}

ErrorOr<AllNullableTypes> TestPlugin::SendMultipleNullableTypes(
    const bool* a_nullable_bool, const int64_t* a_nullable_int,
    const std::string* a_nullable_string) {
  AllNullableTypes someTypes;
  someTypes.set_a_nullable_bool(a_nullable_bool);
  someTypes.set_a_nullable_int(a_nullable_int);
  // The string pointer can't be passed through directly since the setter for
  // a string takes a std::string_view rather than std::string so the pointer
  // types don't match.
  if (a_nullable_string) {
    someTypes.set_a_nullable_string(*a_nullable_string);
  } else {
    someTypes.set_a_nullable_string(nullptr);
  }
  return someTypes;
};

ErrorOr<AllNullableTypesWithoutRecursion>
TestPlugin::SendMultipleNullableTypesWithoutRecursion(
    const bool* a_nullable_bool, const int64_t* a_nullable_int,
    const std::string* a_nullable_string) {
  AllNullableTypesWithoutRecursion someTypes;
  someTypes.set_a_nullable_bool(a_nullable_bool);
  someTypes.set_a_nullable_int(a_nullable_int);
  // The string pointer can't be passed through directly since the setter for
  // a string takes a std::string_view rather than std::string so the pointer
  // types don't match.
  if (a_nullable_string) {
    someTypes.set_a_nullable_string(*a_nullable_string);
  } else {
    someTypes.set_a_nullable_string(nullptr);
  }
  return someTypes;
};

ErrorOr<std::optional<int64_t>> TestPlugin::EchoNullableInt(
    const int64_t* a_nullable_int) {
  if (!a_nullable_int) {
    return std::nullopt;
  }
  return *a_nullable_int;
};

ErrorOr<std::optional<double>> TestPlugin::EchoNullableDouble(
    const double* a_nullable_double) {
  if (!a_nullable_double) {
    return std::nullopt;
  }
  return *a_nullable_double;
};

ErrorOr<std::optional<bool>> TestPlugin::EchoNullableBool(
    const bool* a_nullable_bool) {
  if (!a_nullable_bool) {
    return std::nullopt;
  }
  return *a_nullable_bool;
};

ErrorOr<std::optional<std::string>> TestPlugin::EchoNullableString(
    const std::string* a_nullable_string) {
  if (!a_nullable_string) {
    return std::nullopt;
  }
  return *a_nullable_string;
};

ErrorOr<std::optional<std::vector<uint8_t>>> TestPlugin::EchoNullableUint8List(
    const std::vector<uint8_t>* a_nullable_uint8_list) {
  if (!a_nullable_uint8_list) {
    return std::nullopt;
  }
  return *a_nullable_uint8_list;
};

ErrorOr<std::optional<EncodableValue>> TestPlugin::EchoNullableObject(
    const EncodableValue* a_nullable_object) {
  if (!a_nullable_object) {
    return std::nullopt;
  }
  return *a_nullable_object;
};

ErrorOr<std::optional<EncodableList>> TestPlugin::EchoNullableList(
    const EncodableList* a_nullable_list) {
  if (!a_nullable_list) {
    return std::nullopt;
  }
  return *a_nullable_list;
};

ErrorOr<std::optional<EncodableMap>> TestPlugin::EchoNullableMap(
    const EncodableMap* a_nullable_map) {
  if (!a_nullable_map) {
    return std::nullopt;
  }
  return *a_nullable_map;
};

ErrorOr<std::optional<AnEnum>> TestPlugin::EchoNullableEnum(
    const AnEnum* an_enum) {
  if (!an_enum) {
    return std::nullopt;
  }
  return *an_enum;
}

ErrorOr<std::optional<int64_t>> TestPlugin::EchoOptionalNullableInt(
    const int64_t* a_nullable_int) {
  if (!a_nullable_int) {
    return std::nullopt;
  }
  return *a_nullable_int;
}

ErrorOr<std::optional<std::string>> TestPlugin::EchoNamedNullableString(
    const std::string* a_nullable_string) {
  if (!a_nullable_string) {
    return std::nullopt;
  }
  return *a_nullable_string;
}

void TestPlugin::NoopAsync(
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(std::nullopt);
}

void TestPlugin::ThrowAsyncError(
    std::function<void(ErrorOr<std::optional<EncodableValue>> reply)> result) {
  result(FlutterError("code", "message", EncodableValue("details")));
}

void TestPlugin::ThrowAsyncErrorFromVoid(
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError("code", "message", EncodableValue("details")));
}

void TestPlugin::ThrowAsyncFlutterError(
    std::function<void(ErrorOr<std::optional<EncodableValue>> reply)> result) {
  result(FlutterError("code", "message", EncodableValue("details")));
}

void TestPlugin::EchoAsyncAllTypes(
    const AllTypes& everything,
    std::function<void(ErrorOr<AllTypes> reply)> result) {
  result(everything);
}

void TestPlugin::EchoAsyncInt(
    int64_t an_int, std::function<void(ErrorOr<int64_t> reply)> result) {
  result(an_int);
}

void TestPlugin::EchoAsyncDouble(
    double a_double, std::function<void(ErrorOr<double> reply)> result) {
  result(a_double);
}

void TestPlugin::EchoAsyncBool(
    bool a_bool, std::function<void(ErrorOr<bool> reply)> result) {
  result(a_bool);
}

void TestPlugin::EchoAsyncString(
    const std::string& a_string,
    std::function<void(ErrorOr<std::string> reply)> result) {
  result(a_string);
}
void TestPlugin::EchoAsyncUint8List(
    const std::vector<uint8_t>& a_uint8_list,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) {
  result(a_uint8_list);
}

void TestPlugin::EchoAsyncObject(
    const EncodableValue& an_object,
    std::function<void(ErrorOr<EncodableValue> reply)> result) {
  result(an_object);
}

void TestPlugin::EchoAsyncList(
    const EncodableList& a_list,
    std::function<void(ErrorOr<EncodableList> reply)> result) {
  result(a_list);
}

void TestPlugin::EchoAsyncMap(
    const EncodableMap& a_map,
    std::function<void(ErrorOr<EncodableMap> reply)> result) {
  result(a_map);
}

void TestPlugin::EchoAsyncEnum(
    const AnEnum& an_enum, std::function<void(ErrorOr<AnEnum> reply)> result) {
  result(an_enum);
}

void TestPlugin::EchoAsyncNullableAllNullableTypes(
    const AllNullableTypes* everything,
    std::function<void(ErrorOr<std::optional<AllNullableTypes>> reply)>
        result) {
  result(everything ? std::optional<AllNullableTypes>(*everything)
                    : std::nullopt);
}

void TestPlugin::EchoAsyncNullableAllNullableTypesWithoutRecursion(
    const AllNullableTypesWithoutRecursion* everything,
    std::function<
        void(ErrorOr<std::optional<AllNullableTypesWithoutRecursion>> reply)>
        result) {
  result(everything
             ? std::optional<AllNullableTypesWithoutRecursion>(*everything)
             : std::nullopt);
}

void TestPlugin::EchoAsyncNullableInt(
    const int64_t* an_int,
    std::function<void(ErrorOr<std::optional<int64_t>> reply)> result) {
  result(an_int ? std::optional<int64_t>(*an_int) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableDouble(
    const double* a_double,
    std::function<void(ErrorOr<std::optional<double>> reply)> result) {
  result(a_double ? std::optional<double>(*a_double) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableBool(
    const bool* a_bool,
    std::function<void(ErrorOr<std::optional<bool>> reply)> result) {
  result(a_bool ? std::optional<bool>(*a_bool) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableString(
    const std::string* a_string,
    std::function<void(ErrorOr<std::optional<std::string>> reply)> result) {
  result(a_string ? std::optional<std::string>(*a_string) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableUint8List(
    const std::vector<uint8_t>* a_uint8_list,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
        result) {
  result(a_uint8_list ? std::optional<std::vector<uint8_t>>(*a_uint8_list)
                      : std::nullopt);
}

void TestPlugin::EchoAsyncNullableObject(
    const EncodableValue* an_object,
    std::function<void(ErrorOr<std::optional<EncodableValue>> reply)> result) {
  result(an_object ? std::optional<EncodableValue>(*an_object) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableList(
    const EncodableList* a_list,
    std::function<void(ErrorOr<std::optional<EncodableList>> reply)> result) {
  result(a_list ? std::optional<EncodableList>(*a_list) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableMap(
    const EncodableMap* a_map,
    std::function<void(ErrorOr<std::optional<EncodableMap>> reply)> result) {
  result(a_map ? std::optional<EncodableMap>(*a_map) : std::nullopt);
}

void TestPlugin::EchoAsyncNullableEnum(
    const AnEnum* an_enum,
    std::function<void(ErrorOr<std::optional<AnEnum>> reply)> result) {
  result(an_enum ? std::optional<AnEnum>(*an_enum) : std::nullopt);
}

void TestPlugin::CallFlutterNoop(
    std::function<void(std::optional<FlutterError> reply)> result) {
  flutter_api_->Noop([result]() { result(std::nullopt); },
                     [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterThrowError(
    std::function<void(ErrorOr<std::optional<flutter::EncodableValue>> reply)>
        result) {
  flutter_api_->ThrowError(
      [result](const std::optional<flutter::EncodableValue>& echo) {
        result(echo);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterThrowErrorFromVoid(
    std::function<void(std::optional<FlutterError> reply)> result) {
  flutter_api_->ThrowErrorFromVoid(
      [result]() { result(std::nullopt); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoAllTypes(
    const AllTypes& everything,
    std::function<void(ErrorOr<AllTypes> reply)> result) {
  flutter_api_->EchoAllTypes(
      everything, [result](const AllTypes& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoAllNullableTypes(
    const AllNullableTypes* everything,
    std::function<void(ErrorOr<std::optional<AllNullableTypes>> reply)>
        result) {
  flutter_api_->EchoAllNullableTypes(
      everything,
      [result](const AllNullableTypes* echo) {
        result(echo ? std::optional<AllNullableTypes>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterSendMultipleNullableTypes(
    const bool* a_nullable_bool, const int64_t* a_nullable_int,
    const std::string* a_nullable_string,
    std::function<void(ErrorOr<AllNullableTypes> reply)> result) {
  flutter_api_->SendMultipleNullableTypes(
      a_nullable_bool, a_nullable_int, a_nullable_string,
      [result](const AllNullableTypes& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoAllNullableTypesWithoutRecursion(
    const AllNullableTypesWithoutRecursion* everything,
    std::function<
        void(ErrorOr<std::optional<AllNullableTypesWithoutRecursion>> reply)>
        result) {
  flutter_api_->EchoAllNullableTypesWithoutRecursion(
      everything,
      [result](const AllNullableTypesWithoutRecursion* echo) {
        result(echo ? std::optional<AllNullableTypesWithoutRecursion>(*echo)
                    : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterSendMultipleNullableTypesWithoutRecursion(
    const bool* a_nullable_bool, const int64_t* a_nullable_int,
    const std::string* a_nullable_string,
    std::function<void(ErrorOr<AllNullableTypesWithoutRecursion> reply)>
        result) {
  flutter_api_->SendMultipleNullableTypesWithoutRecursion(
      a_nullable_bool, a_nullable_int, a_nullable_string,
      [result](const AllNullableTypesWithoutRecursion& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoBool(
    bool a_bool, std::function<void(ErrorOr<bool> reply)> result) {
  flutter_api_->EchoBool(
      a_bool, [result](bool echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoInt(
    int64_t an_int, std::function<void(ErrorOr<int64_t> reply)> result) {
  flutter_api_->EchoInt(
      an_int, [result](int64_t echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoDouble(
    double a_double, std::function<void(ErrorOr<double> reply)> result) {
  flutter_api_->EchoDouble(
      a_double, [result](double echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoString(
    const std::string& a_string,
    std::function<void(ErrorOr<std::string> reply)> result) {
  flutter_api_->EchoString(
      a_string, [result](const std::string& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoUint8List(
    const std::vector<uint8_t>& a_list,
    std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) {
  flutter_api_->EchoUint8List(
      a_list, [result](const std::vector<uint8_t>& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoList(
    const EncodableList& a_list,
    std::function<void(ErrorOr<EncodableList> reply)> result) {
  flutter_api_->EchoList(
      a_list, [result](const EncodableList& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoMap(
    const EncodableMap& a_map,
    std::function<void(ErrorOr<EncodableMap> reply)> result) {
  flutter_api_->EchoMap(
      a_map, [result](const EncodableMap& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoEnum(
    const AnEnum& an_enum, std::function<void(ErrorOr<AnEnum> reply)> result) {
  flutter_api_->EchoEnum(
      an_enum, [result](const AnEnum& echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableBool(
    const bool* a_bool,
    std::function<void(ErrorOr<std::optional<bool>> reply)> result) {
  flutter_api_->EchoNullableBool(
      a_bool,
      [result](const bool* echo) {
        result(echo ? std::optional<bool>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableInt(
    const int64_t* an_int,
    std::function<void(ErrorOr<std::optional<int64_t>> reply)> result) {
  flutter_api_->EchoNullableInt(
      an_int,
      [result](const int64_t* echo) {
        result(echo ? std::optional<int64_t>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableDouble(
    const double* a_double,
    std::function<void(ErrorOr<std::optional<double>> reply)> result) {
  flutter_api_->EchoNullableDouble(
      a_double,
      [result](const double* echo) {
        result(echo ? std::optional<double>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableString(
    const std::string* a_string,
    std::function<void(ErrorOr<std::optional<std::string>> reply)> result) {
  flutter_api_->EchoNullableString(
      a_string,
      [result](const std::string* echo) {
        result(echo ? std::optional<std::string>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableUint8List(
    const std::vector<uint8_t>* a_list,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
        result) {
  flutter_api_->EchoNullableUint8List(
      a_list,
      [result](const std::vector<uint8_t>* echo) {
        result(echo ? std::optional<std::vector<uint8_t>>(*echo)
                    : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableList(
    const EncodableList* a_list,
    std::function<void(ErrorOr<std::optional<EncodableList>> reply)> result) {
  flutter_api_->EchoNullableList(
      a_list,
      [result](const EncodableList* echo) {
        result(echo ? std::optional<EncodableList>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableMap(
    const EncodableMap* a_map,
    std::function<void(ErrorOr<std::optional<EncodableMap>> reply)> result) {
  flutter_api_->EchoNullableMap(
      a_map,
      [result](const EncodableMap* echo) {
        result(echo ? std::optional<EncodableMap>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

void TestPlugin::CallFlutterEchoNullableEnum(
    const AnEnum* an_enum,
    std::function<void(ErrorOr<std::optional<AnEnum>> reply)> result) {
  flutter_api_->EchoNullableEnum(
      an_enum,
      [result](const AnEnum* echo) {
        result(echo ? std::optional<AnEnum>(*echo) : std::nullopt);
      },
      [result](const FlutterError& error) { result(error); });
}

}  // namespace test_plugin
