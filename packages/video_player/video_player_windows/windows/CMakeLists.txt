cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "video_player_windows")
project(${PROJECT_NAME} LANGUAGES CXX)
cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")
set(PLUGIN_SOURCES
  adaptive_source.cpp
  adaptive_source.h
  frame_buffer.cpp
  frame_buffer.h
  media_player.cpp
  media_player.h
  messages.g.cpp
  messages.g.h
  player_event.cpp
  player_event.h
  video_player_plugin.cpp
  video_player_plugin.h
)

add_library(${PLUGIN_NAME} SHARED
  include/video_player_windows/video_player_windows.h
  video_player_windows.cpp
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_20)
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL NOMINMAX)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin
  d3d11 mfplat mf mfuuid ole32 oleaut32 windowsapp)
set(video_player_windows_bundled_libraries "" PARENT_SCOPE)

if (include_${PROJECT_NAME}_tests)
  enable_testing()
  include(FetchContent)
  FetchContent_Declare(googletest URL https://github.com/google/googletest/archive/v1.15.2.zip)
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)
  add_executable(${PROJECT_NAME}_test test/media_player_test.cpp test/player_event_test.cpp ${PLUGIN_SOURCES})
  apply_standard_settings(${PROJECT_NAME}_test)
  target_compile_features(${PROJECT_NAME}_test PRIVATE cxx_std_20)
  target_compile_definitions(${PROJECT_NAME}_test PRIVATE NOMINMAX)
  target_include_directories(${PROJECT_NAME}_test PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
  target_link_libraries(${PROJECT_NAME}_test PRIVATE flutter_wrapper_plugin gtest_main
    d3d11 mfplat mf mfuuid ole32 oleaut32 windowsapp)
  add_custom_command(TARGET ${PROJECT_NAME}_test POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${PROJECT_NAME}_test>)
  include(GoogleTest)
  gtest_discover_tests(${PROJECT_NAME}_test)
endif()
