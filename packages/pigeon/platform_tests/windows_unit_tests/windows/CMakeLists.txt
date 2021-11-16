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
