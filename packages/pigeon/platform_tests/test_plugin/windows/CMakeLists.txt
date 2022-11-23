# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "test_plugin")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "test_plugin_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "test_plugin.cpp"
  "test_plugin.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/test_plugin/test_plugin_c_api.h"
  "test_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(test_plugin_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===

if (${include_${PROJECT_NAME}_tests})
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
  # Tests.
  test/multiple_arity_test.cpp
  test/non_null_fields_test.cpp
  test/nullable_returns_test.cpp
  test/null_fields_test.cpp
  test/pigeon_test.cpp
  test/primitive_test.cpp
  # Generated sources.
  test/all_datatypes.g.cpp
  test/all_datatypes.g.h
  test/all_void.g.cpp
  test/all_void.g.h
  test/async_handlers.g.cpp
  test/async_handlers.g.h
  test/enum.g.cpp
  test/enum.g.h
  test/host2flutter.g.cpp
  test/host2flutter.g.h
  test/list.g.cpp
  test/list.g.h
  test/message.g.cpp
  test/message.g.h
  test/multiple_arity.g.cpp
  test/multiple_arity.g.h
  test/non_null_fields.g.cpp
  test/non_null_fields.g.h
  test/null_fields.g.cpp
  test/null_fields.g.h
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
  # Test utilities.
  test/utils/echo_messenger.cpp
  test/utils/echo_messenger.h
  test/utils/fake_host_messenger.cpp
  test/utils/fake_host_messenger.h

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
endif()
