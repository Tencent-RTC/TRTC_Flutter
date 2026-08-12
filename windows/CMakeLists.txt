# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "tencent_rtc_sdk")
project(${PROJECT_NAME} LANGUAGES C CXX)

add_compile_options(/wd4702)
add_compile_options(/wd4152)
add_compile_options(/wd4819)
# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "tencent_rtc_sdk_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "trtc_plugin.cpp"
  "trtc_plugin.h"
  "view/texture_view_factory.h"
  "view/texture_view_factory.cpp"
  "view/main_thread_dispatcher.h"
  "view/main_thread_dispatcher.cpp"
  "view/video_frame_dispatcher.h"
  "view/video_frame_dispatcher.cpp"
  "view/tx_cloud_video_view_channel.h"
  "view/tx_cloud_video_view_channel.cpp"
)


# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/tencent_rtc_sdk/trtc_plugin_c_api.h"
  "trtc_plugin_c_api.cpp"
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
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/view"
  "${CMAKE_CURRENT_SOURCE_DIR}/../src/dart_api"
  "${CMAKE_CURRENT_SOURCE_DIR}/../src/jsoncpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/../src/trtc_c_api"
  "${CMAKE_CURRENT_SOURCE_DIR}/../src/trtc_plugin_adapter.h"
  )
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin "Ws2_32" "${CMAKE_CURRENT_SOURCE_DIR}/lib/liteav.lib")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(tencent_rtc_sdk_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/lib/txsoundtouch.dll;${CMAKE_CURRENT_SOURCE_DIR}/lib/txffmpeg.dll;${CMAKE_CURRENT_SOURCE_DIR}/lib/liteav.dll;"
  PARENT_SCOPE
)
