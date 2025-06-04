# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)

# Set variables
set(PYLON_VERSION "8.0.2.16314")
set(PYLON_ARCHIVE_NAME "pylon-${PYLON_VERSION}_linux-aarch64.tar.gz")
set(PYLON_ARCHIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../deps/${PYLON_ARCHIVE_NAME})
set(PYLON_DOWNLOAD_URL "https://github.com/LightX-Innovations/flutter_packages/releases/download/camera_linux_v0.1/pylon-${PYLON_VERSION}_linux-aarch64.tar.gz")
set(PYLON_ROOT ${CMAKE_BINARY_DIR}/pylon-sdk)

# Download the archive if it does not exist
if(NOT EXISTS "${PYLON_ARCHIVE_PATH}")
    message(STATUS "Downloading Pylon SDK archive...")
    file(DOWNLOAD
        "${PYLON_DOWNLOAD_URL}"
        "${PYLON_ARCHIVE_PATH}"
        SHOW_PROGRESS
        STATUS DOWNLOAD_STATUS
    )
    list(GET DOWNLOAD_STATUS 0 DOWNLOAD_RESULT)
endif()

# Extract the archive only if not already extracted
if(NOT EXISTS "${PYLON_ROOT}")
    message(STATUS "Extracting Pylon SDK to ${PYLON_ROOT}...")
    file(MAKE_DIRECTORY "${PYLON_ROOT}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar -xzf "${PYLON_ARCHIVE_PATH}"
        WORKING_DIRECTORY "${PYLON_ROOT}"
    )
endif()

include_directories(${PYLON_ROOT}/include)
link_directories(${PYLON_ROOT}/lib)

# Project-level configuration.
set(PROJECT_NAME "camera_linux")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "camera_linux_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "camera_plugin.cpp"
  "camera_host_plugin.cpp"
  "camera_texture_image_event_handler.cpp"
 
  "messages.g.cc"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
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
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
cmake_policy(SET CMP0072 NEW)
set(OpenGL_GL_PREFERENCE GLVND)
find_package( OpenGL REQUIRED )
target_link_libraries(${PLUGIN_NAME} PRIVATE OpenGL::GL)
target_link_libraries(${PLUGIN_NAME}
    PRIVATE
    ${PYLON_ROOT}/lib/libpylonbase.so
    ${PYLON_ROOT}/lib/libpylonutility.so
)
find_package(PkgConfig REQUIRED)


# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(camera_linux_bundled_libraries
  "${PYLON_ROOT}/lib/libpylonbase.so"
  "${PYLON_ROOT}/lib/libpylonutility.so"
  PARENT_SCOPE
)
