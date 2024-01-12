cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "video_player_windows")
set(WIL_VERSION "1.0.210803.1")
project(${PROJECT_NAME} LANGUAGES CXX)
include(FetchContent)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

FetchContent_Declare(nuget
  URL "https://dist.nuget.org/win-x86-commandline/v6.0.0/nuget.exe"
  URL_HASH SHA256=04eb6c4fe4213907e2773e1be1bbbd730e9a655a3c9c58387ce8d4a714a5b9e1
  DOWNLOAD_NO_EXTRACT true
)

find_program(NUGET nuget)
if (NOT NUGET)
    message("Nuget.exe not found, trying to download or use cached version.")
    FetchContent_MakeAvailable(nuget)
    set(NUGET ${nuget_SOURCE_DIR}/nuget.exe)
endif()

execute_process(COMMAND
    ${NUGET} install Microsoft.Windows.ImplementationLibrary -Version ${WIL_VERSION} -OutputDirectory ${CMAKE_BINARY_DIR}/packages
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    RESULT_VARIABLE ret)
if (NOT ret EQUAL 0)
    message(FATAL_ERROR "Failed to install nuget package Microsoft.Windows.ImplementationLibrary.${WIL_VERSION}")
endif()

include_directories(BEFORE SYSTEM ${CMAKE_BINARY_DIR}/include)

list(APPEND PLUGIN_SOURCES
  "video_player_plugin.cpp"
  "video_player.h"
  "video_player.cpp"
  "messages.h"
  "messages.cpp"
  "MediaFoundationHelpers.h"
  "MediaEngineWrapper.h"
  "MediaEngineWrapper.cpp"
  "MediaEngineExtension.h"
  "MediaEngineExtension.cpp"
)

add_library(${PLUGIN_NAME} SHARED
  "include/video_player_windows/video_player_plugin.h"
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_link_libraries(${PLUGIN_NAME} PRIVATE ${CMAKE_BINARY_DIR}/packages/Microsoft.Windows.ImplementationLibrary.${WIL_VERSION}/build/native/Microsoft.Windows.ImplementationLibrary.targets)

target_link_libraries(${PLUGIN_NAME} PRIVATE d3d11 Mfplat windowsapp)

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(video_player_bundled_libraries
  ""
  PARENT_SCOPE
)