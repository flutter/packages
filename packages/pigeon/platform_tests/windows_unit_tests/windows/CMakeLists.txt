cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "windows_unit_tests")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "windows_unit_tests_plugin")

list(APPEND PLUGIN_SOURCES
  "windows_unit_tests_plugin.cpp"
  "windows_unit_tests_plugin.h"
)

add_library(${PLUGIN_NAME} SHARED
  "include/windows_unit_tests/windows_unit_tests_plugin_c_api.h"
  "windows_unit_tests_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(windows_unit_tests_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===

set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()
# TODO(stuartmorgan): Consider using a single shared, pre-checked-in googletest
# instance rather than downloading for each plugin. This approach makes sense
# for a template, but not for a monorepo with many plugins.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/release-1.11.0.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)

FetchContent_MakeAvailable(googletest)

# The plugin's C API is not very useful for unit testing, so build the sources
# directly into the test binary rather than using the DLL.
add_executable(${TEST_RUNNER}
  test/pigeon_test.cpp
  test/all_datatypes.g.cpp
  test/all_datatypes.g.h
  test/all_void.g.cpp
  test/all_void.g.h
  test/async_handlers.g.cpp
  test/async_handlers.g.h
  test/message.g.cpp
  test/message.g.h
  test/enum.g.cpp
  test/enum.g.h
  test/host2flutter.g.cpp
  test/host2flutter.g.h
  test/list.g.cpp
  test/list.g.h
  test/multiple_arity.g.cpp
  test/multiple_arity.g.h
  test/non_null_fields.g.cpp
  test/non_null_fields.g.h
  test/nullable_returns.g.cpp
  test/nullable_returns.g.h
  test/primitive.g.cpp
  test/primitive.g.h
  test/void_arg_flutter.g.cpp
  test/void_arg_flutter.g.h
  test/void_arg_host.g.cpp
  test/void_arg_host.g.h
  test/voidflutter.g.cpp
  test/voidflutter.g.h
  test/voidhost.g.cpp
  test/voidhost.g.h

  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
